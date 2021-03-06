subroutine mmgeom(ndim  ,nne   ,nnm   ,ffe   ,ffm   , &
                  geomae,geomam,tau1  ,tau2  , &
          norm  ,mprojn,mprojt,geome ,geomm )
!
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    implicit     none
#include "jeveux.h"
#include "asterfort/mmcaln.h"
#include "asterfort/vecini.h"
#include "asterfort/assert.h"
    integer :: ndim, nne, nnm
    real(kind=8) :: ffe(9), ffm(9)
    real(kind=8) :: norm(3), tau1(3), tau2(3)
    real(kind=8) :: mprojn(3, 3), mprojt(3, 3)
    real(kind=8) :: geomm(3), geome(3)
    real(kind=8) :: geomae(9, 3), geomam(9, 3)
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
!
! CALCUL DES INCREMENTS - GEOMETRIE
!
! ----------------------------------------------------------------------
!
!
! DEPDEL - INCREMENT DE DEPLACEMENT DEPUIS DEBUT DU PAS DE TEMPS
! DEPMOI - DEPLACEMENT DEBUT DU PAS DE TEMPS
! GEOMAx - GEOMETRIE ACTUALISEE GEOM_INIT + DEPMOI
!
!
! IN  NDIM   : DIMENSION DU PROBLEME
! IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
! IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
! IN  FFE    : FONCTIONS DE FORMES DEPL. ESCL.
! IN  FFM    : FONCTIONS DE FORMES DEPL. MAIT.
! IN  DDFFM  : DERIVEES SECONDES DES FONCTIONS DE FORME MAITRES
! IN  GEOMAE : GEOMETRIE ACTUALISEE SUR NOEUDS ESCLAVES
! IN  GEOMAM : GEOMETRIE ACTUALISEE SUR NOEUDS MAITRES
! IN  TAU1   : PREMIER VECTEUR TANGENT
! IN  TAU2   : SECOND VECTEUR TANGENT
! OUT NORM   : NORMALE INTERIEURE
! OUT GEOME  : COORDONNEES ACTUALISEES DU POINT DE CONTACT
! OUT GEOMM  : COORDONNEES ACTUALISEES DU PROJETE DU POINT DE CONTACT
!
! ----------------------------------------------------------------------
!
    integer :: idim, inoe, inom
!
! ----------------------------------------------------------------------
!
!
!
! --- INITIALISATIONS
!
    call vecini(3, 0.d0, geome)
    call vecini(3, 0.d0, geomm)
!
! --- COORDONNEES ACTUALISEES DU POINT DE CONTACT
!
    do  idim = 1, ndim
        do 12 inoe = 1, nne
            geome(idim) = geome(idim) + ffe(inoe)*geomae(inoe,idim)
12      continue
  end do
!
! --- COORDONNEES ACTUALISEES DE LA PROJECTION DU POINT DE CONTACT
!
    do  idim = 1, ndim
        do 22 inom = 1, nnm
            geomm(idim) = geomm(idim) + ffm(inom)*geomam(inom,idim)
22      continue
  end do
!
! --- CALCUL DE LA NORMALE ET DES MATRICES DE PROJECTION
!
    call mmcaln(ndim  ,tau1  ,tau2  ,norm  ,mprojn, &
                mprojt)



end subroutine
