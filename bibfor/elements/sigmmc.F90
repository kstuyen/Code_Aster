subroutine sigmmc(fami, nno, ndim, nbsig, npg,&
                  ipoids, ivf, idfde, xyz, depl,&
                  instan, repere, mater, nharm, sigma)
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
!.======================================================================
    implicit none
!
!      SIGMMC   -- CALCUL DES  CONTRAINTES AUX POINTS D'INTEGRATION
!                  POUR LES ELEMENTS ISOPARAMETRIQUES
!
!   ARGUMENT        E/S  TYPE         ROLE
!    NNO            IN     I        NOMBRE DE NOEUDS DE L'ELEMENT
!    NDIM           IN     I        DIMENSION DE L'ELEMENT (2 OU 3)
!    NBSIG          IN     I        NOMBRE DE CONTRAINTES ASSOCIE
!                                   A L'ELEMENT
!    NPG            IN     I        NOMBRE DE POINTS D'INTEGRATION
!                                   DE L'ELEMENT
!    IPOIDS         IN     I        POIDS D'INTEGRATION
!    IVF            IN     I        FONCTIONS DE FORME
!    IDFDE          IN     I        DERIVEES DES FONCTIONS DE FORME
!    XYZ(1)         IN     R        COORDONNEES DES CONNECTIVITES
!    DEPL(1)        IN     R        VECTEUR DES DEPLACEMENTS SUR
!                                   L'ELEMENT
!    INSTAN         IN     R        INSTANT DE CALCUL (0 PAR DEFAUT)
!    REPERE(7)      IN     R        VALEURS DEFINISSANT LE REPERE
!                                   D'ORTHOTROPIE
!    MATER          IN     I        MATERIAU
!    NHARM          IN     R        NUMERO D'HARMONIQUE
!    SIGMA(1)       OUT    R        CONTRAINTES AUX POINTS D'INTEGRATION
!
!.========================= DEBUT DES DECLARATIONS ====================
! -----  ARGUMENTS
#include "jeveux.h"
#include "asterfort/bmatmc.h"
#include "asterfort/dbudef.h"
#include "asterfort/dmatmc.h"
#include "asterfort/lteatt.h"
    real(kind=8) :: xyz(1), depl(1), repere(7), sigma(1)
    real(kind=8) :: instan, nharm
    character(len=*) :: fami
! -----  VARIABLES LOCALES
    integer :: igau, i, nno
    real(kind=8) :: b(486), d(36), jacgau, xyzgau(3)
    character(len=2) :: k2bid
!.========================= DEBUT DU CODE EXECUTABLE ==================
!
! --- INITIALISATIONS :
!     -----------------
!-----------------------------------------------------------------------
    integer :: idfde, idim, ipoids, ivf, mater, nbinco, nbsig
    integer :: ndim, ndim2, npg
    real(kind=8) :: zero
!-----------------------------------------------------------------------
    k2bid = '  '
    zero = 0.0d0
    nbinco = ndim*nno
    ndim2 = ndim
    if (lteatt('FOURIER','OUI')) then
        ndim2 = 2
    endif
!
    sigma(1:nbsig*npg) = zero
!
! --- CALCUL DES CONTRAINTES AUX POINTS D'INTEGRATION
! ---  BOUCLE SUR LES POINTS D'INTEGRATION
!      -----------------------------------
    do igau = 1, npg
!
!  --      COORDONNEES ET TEMPERATURE AU POINT D'INTEGRATION
!  --      COURANT
!          -------
        xyzgau(1) = zero
        xyzgau(2) = zero
        xyzgau(3) = zero
!
        do i = 1, nno
            do idim = 1, ndim2
                xyzgau(idim) = xyzgau(idim) + zr(ivf+i+nno*(igau-1)-1) *xyz(idim+ndim2*(i-1))
            end do
        end do
!
!  --      CALCUL DE LA MATRICE B RELIANT LES DEFORMATIONS DU
!  --      PREMIER ORDRE AUX DEPLACEMENTS AU POINT D'INTEGRATION
!  --      COURANT : (EPS_1) = (B)*(UN)
!          ----------------------------
        call bmatmc(igau, nbsig, xyz, ipoids, ivf,&
                    idfde, nno, nharm, jacgau, b)
!
!  --      CALCUL DE LA MATRICE DE HOOKE (LE MATERIAU POUVANT
!  --      ETRE ISOTROPE, ISOTROPE-TRANSVERSE OU ORTHOTROPE)
!          -------------------------------------------------
        call dmatmc(fami, mater, instan, '+',&
                    igau, 1, repere, xyzgau, nbsig,&
                    d)
!
!  --      CALCUL DE LA CONTRAINTE AU POINT D'INTEGRATION COURANT
!          ------------------------------------------------------
        call dbudef(depl, b, d, nbsig, nbinco,&
                    sigma(1+nbsig*(igau-1)))
    end do
!
!.============================ FIN DE LA ROUTINE ======================
end subroutine
