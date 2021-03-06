subroutine apksp(kptsc)
!
#include "asterf_types.h"
#include "asterf_petsc.h"
!
! COPYRIGHT (C) 1991 - 2017  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
! person_in_charge: natacha.bereux at edf.fr
! aslint:disable=
use petsc_data_module
!
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/infniv.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    integer :: kptsc
!----------------------------------------------------------------
!
!  CREATION DU SOLVEUR DE KRYLOV PETSC (INSTANCE NUMERO KPTSC)
!
!----------------------------------------------------------------
!
#ifdef _HAVE_PETSC
!
!     VARIABLES LOCALES
    integer :: nmaxit, ifm, niv
!
    character(len=24) :: algo
    character(len=19) :: nomat, nosolv
    character(len=14) :: nonu
!
    real(kind=8) :: resire
    real(kind=8), pointer :: slvr(:) => null()
    character(len=24), pointer :: slvk(:) => null()
    integer, pointer :: slvi(:) => null()
!
!----------------------------------------------------------------
!     Variables PETSc
    PetscErrorCode :: ierr
    PetscInt :: maxits
    PetscReal :: rtol, atol, dtol, aster_petsc_real
    Mat :: a
    KSP :: ksp
#if PETSC_VERSION_LT(3,7,0)
#else
    PetscViewerAndFormat :: vf
#endif
!=================================================================
    call jemarq()
!
    call infniv(ifm, niv)
!
#if PETSC_VERSION_LT(3,5,0)
    aster_petsc_real = PETSC_DEFAULT_DOUBLE_PRECISION
#else
    aster_petsc_real = PETSC_DEFAULT_REAL
#endif
!     -- LECTURE DU COMMUN
    nomat = nomat_courant
    nonu = nonu_courant
    nosolv = nosols(kptsc)
    a = ap(kptsc)
    ksp = kp(kptsc)
!
    call jeveuo(nosolv//'.SLVK', 'L', vk24=slvk)
    call jeveuo(nosolv//'.SLVR', 'L', vr=slvr)
    call jeveuo(nosolv//'.SLVI', 'L', vi=slvi)
    algo = slvk(6)
    resire = slvr(2)
    nmaxit = slvi(2)
!
!     -- choix de l'algo KSP :
!     ------------------------
    if (algo .eq. 'CG') then
        call KSPSetType(ksp, KSPCG, ierr)
        ASSERT(ierr.eq.0)
    else if (algo.eq.'CR') then
        call KSPSetType(ksp, KSPCR, ierr)
        ASSERT(ierr.eq.0)
    else if (algo.eq.'GMRES') then
        call KSPSetType(ksp, KSPGMRES, ierr)
    else if (algo.eq.'GMRES_LMP') then
        call KSPSetType(ksp, KSPGMRES, ierr)
        ASSERT(ierr.eq.0)
! On indique qu'on veut récupérer les Ritz à la fin de la résolution
! afin de construire le préconditionneur de second niveau LMP
        call KSPSetComputeRitz(ksp, petsc_true, ierr)
    else if (algo.eq.'GCR') then
        call KSPSetType(ksp, KSPGCR, ierr)
        ASSERT(ierr.eq.0)
    else if (algo.eq.'FGMRES') then
        call KSPSetType(ksp, KSPFGMRES, ierr)
    else
        ASSERT(.false.)
    endif
    ASSERT(ierr.eq.0)
!
!     -- paramètres numériques :
!     --------------------------
!
!     -- nb iter max :
    if (nmaxit .le. 0) then
        maxits = PETSC_DEFAULT_INTEGER
    else
        maxits = nmaxit
    endif
!
    rtol = resire
    atol = aster_petsc_real
    dtol = aster_petsc_real
!
    call KSPSetTolerances(ksp, rtol, atol, dtol, maxits, ierr)
    ASSERT(ierr.eq.0)

    call KSPSetUp( ksp, ierr )
    ASSERT( ierr == 0 )
!
!     - pour suivre les itérations de Krylov
!     --------------------------------------
    if (niv .ge. 2) then
#if PETSC_VERSION_LT(3,7,0)
        call KSPMonitorSet(ksp, KSPMonitorTrueResidualNorm, PETSC_NULL_OBJECT,&
                           PETSC_NULL_FUNCTION, ierr)
#else
         call PetscViewerAndFormatCreate(PETSC_VIEWER_STDOUT_WORLD, PETSC_VIEWER_DEFAULT, vf,ierr)
         call KSPMonitorSet(ksp,KSPMonitorTrueResidualNorm, vf, PetscViewerAndFormatDestroy,&
                            ierr)
#endif
        ASSERT(ierr.eq.0)
    endif
!
    call jedema()
!
#else
kptsc=0
ASSERT(.false.)
#endif
!
end subroutine
