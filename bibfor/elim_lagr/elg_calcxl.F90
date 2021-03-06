subroutine elg_calcxl(x1, vlag)
#include "asterf_types.h"
#include "asterf_petsc.h"
!
use elim_lagr_data_module
    implicit none
! person_in_charge: jacques.pellet at edf.fr
! aslint:disable=
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
#include "jeveux.h"
#include "asterc/asmpi_comm.h"
#include "asterfort/asmpi_info.h"
#include "asterfort/assert.h"
#include "asterfort/elg_allocvr.h"
#include "asterfort/infniv.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/utmess.h"
!----------------------------------------------------------------
! Calcul des coefficients de Lagrange pour ELIM_LAGR='OUI'
!     IN  : Vec X1    (solution sur les dds physiques)
!
!     OUT : Vec VLAG  (solution sur les dds Lagrange "1")
!
!     On résout  vlag = A'\ Y de la façon suivante :
!       * calcul de CCT = A*A'
!       * calcul de AY = A*Y
!       * résolution (CG) vlag = A*A' \ AY
!
!     Rq: La méthode originale utilise une factorisation QR
!     préalable de A. Le calcul des multiplicateurs s'effectue alors
!     par des descentes remontées:
!      Les coefficients de Lagrange (1 et 2) sont
!     calculés par :
!       L = (R'*R) \ A*(b - B*x)
!----------------------------------------------------------------
!
#ifdef _HAVE_PETSC
!
    Vec :: x1, vlag
!
!================================================================
    mpi_int :: mpicomm, nbproc, rang
    KSP :: ksp
    PC :: pc
    integer :: ifm, niv
    real(kind=8) :: norm
    aster_logical :: info
    PetscInt :: n1, n2, n3
    PetscInt :: reason
    PetscErrorCode :: ierr
    PetscScalar, parameter :: neg_rone=-1.d0
    PetscOffset :: xidxay, xidxl
    Mat :: cct, atmp
    Vec :: bx, y, ay, xtmp
    PetscInt :: its
    PetscReal :: aster_petsc_real
    integer :: methode
    integer, parameter :: lsqr=1, cg=2

!----------------------------------------------------------------
    call jemarq()
    call infniv(ifm, niv)
    info=niv.eq.2
    !
!   -- COMMUNICATEUR MPI DE TRAVAIL
    call asmpi_comm('GET_WORLD', mpicomm)
    call asmpi_info(rank=rang, size=nbproc)
!
#if PETSC_VERSION_LT(3,5,0)
    aster_petsc_real = PETSC_DEFAULT_DOUBLE_PRECISION
#else
    aster_petsc_real = PETSC_DEFAULT_REAL
#endif
!
!     -- dimensions :
!       n1 : # ddls physiques
!       n2 : # lagranges "1"
!     ----------------------------------------------------------
    call MatGetSize(elg_context(ke)%ctrans, n1, n2, ierr)
!   le système est-il bien  sur-déterminé ?
    ASSERT( n1 > n2 )
!
!     -- vérifs :
    call VecGetSize(x1, n3, ierr)
    ASSERT(n3.eq.n1)
    call VecGetSize(vlag, n3, ierr)
    ASSERT(n3.eq.n2)

!
!
!     -- calcul de BX = B*x :
    call VecDuplicate(x1, bx, ierr)
    call MatMult(elg_context(ke)%matb, x1, bx, ierr)
!
!
!     -- calcul de Y = b - B*x :
    call VecDuplicate(elg_context(ke)%vecb, y, ierr)
    call VecCopy(elg_context(ke)%vecb, y, ierr)
    call VecAXPY(y, neg_rone, bx, ierr)
!
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!         Create the linear solver
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!
    call KSPCreate(mpicomm, ksp, ierr)
!
!   Calcul de A*A'

#if PETSC_VERSION_LT(3,3,0)
    call MatMatMultTranspose(elg_context(ke)%ctrans, elg_context(ke)%ctrans, MAT_INITIAL_MATRIX, &
         PETSC_DEFAULT_DOUBLE_PRECISION, cct, ierr)
#else
    call MatTransposeMatMult(elg_context(ke)%ctrans, elg_context(ke)%ctrans, MAT_INITIAL_MATRIX, &
         aster_petsc_real, cct, ierr)
#endif
    ASSERT( ierr==0 )
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!                      Solve the linear system
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
! Methode CG
! On résout vlag = A'\ y en 2 étapes
!  * AY = Ay
!  * vlag = A A'\ Ay
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!
!   -- Compute AY = A*Y
!
      call elg_allocvr(ay, int(n2))
      call MatMultTranspose(elg_context(ke)%ctrans, y, ay, ierr)
!
!   -- Set linear solver (CG)
!
      call KSPSetType(ksp, KSPCG, ierr)
!
!   -- Set linear system
!
#if PETSC_VERSION_LT(3,5,0)
      call KSPSetOperators(ksp, cct, cct, SAME_PRECONDITIONER, ierr)
#else
      call KSPSetOperators(ksp, cct , cct, ierr)
#endif
!
!   -- Solve the linear system
      call KSPSolve( ksp, ay, vlag, ierr)
!
!   -- Free memory
      call VecDestroy(ay, ierr)
!
!  Check the reason why KSP solver ended
!
    call KSPGetConvergedReason(ksp, reason, ierr)
    if (reason<0) then
 !      call KSPGetOperators(ksp,atmp, petsc_null_object, ierr)
 !      call KSPGetRhs( ksp, xtmp, ierr)
 !      call VecView( xtmp, PETSC_VIEWER_STDOUT_SELF, ierr )
 !      call KSPGetSolution( ksp, xtmp, ierr)
 !      call VecView( xtmp, PETSC_VIEWER_STDOUT_SELF, ierr )
 !      call MatView( atmp, PETSC_VIEWER_STDOUT_SELF, ierr)
      call utmess('F','ELIMLAGR_8')
    endif
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!                     Check solution and clean up
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!  Check the error ||C^T*vlag - y||
!
    if (info) then
      call VecDuplicate(y, xtmp , ierr)
      call MatMult(elg_context(ke)%ctrans, vlag, xtmp, ierr)
      call VecAXPY(xtmp,neg_rone,y ,ierr)
      call VecNorm(xtmp,norm_2,norm,ierr)
      call KSPGetIterationNumber(ksp,its,ierr)

     if (rang .eq. 0) then
         write(6,100) norm,its
     endif
  100 format('CALCXL: Norm of error = ',e11.4,',  iterations = ',i5)
      call VecDestroy(xtmp, ierr)
    endif
!
!  Free work space.  All PETSc objects should be destroyed when they
!  are no longer needed.
    call VecDestroy(bx, ierr)
    call VecDestroy(y, ierr)
    call VecDestroy(ay, ierr)
    call KSPDestroy(ksp, ierr)
    call MatDestroy(cct, ierr)
!
    call jedema()
!
#else
    integer :: x1, vlag
    vlag = x1
    ASSERT(.false.)
#endif
!
end subroutine
