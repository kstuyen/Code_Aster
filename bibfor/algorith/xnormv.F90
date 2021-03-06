subroutine xnormv(dime, xx, norme)
    implicit none
#include "blas/ddot.h"
    integer ::  dime
    real(kind=8) :: xx(dime)
    real(kind=8) :: norme
! ----------------------------------------------------------------------
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!     BUT : NORME UN VECTEUR DE R3 ET RETOURNE SA NORME INITIALE
!     RQUE : SI LA NORME EST NULLE, LE VECTEUR XX N'EST PAS NORME
! ======================================================================
!
    integer ::  j
! ======================================================================
    norme = ddot(dime, xx, 1, xx, 1)
    if (norme .ne. 0.0d0) then
        norme = dsqrt(norme)
        do j=1,dime
          xx(j) = xx(j)/norme
        enddo
    endif
end subroutine
