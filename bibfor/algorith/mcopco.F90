subroutine mcopco(noma, newgeo, ndim, nummai, ksi1,&
                  ksi2, geom)
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    implicit none
#include "jeveux.h"
!
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
#include "asterfort/mmelty.h"
#include "asterfort/mmvalp.h"
    character(len=8) :: noma
    character(len=19) :: newgeo
    integer :: ndim, nummai
    real(kind=8) :: ksi1, ksi2
    real(kind=8) :: geom(3)
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODE CONTINUE - APPARIEMENT - UTILITAIRE)
!
! CALCUL DES COORDONNEES D'UN NOEUD SUR UNE MAILLE A PARTIR
! DE SES COORDONNEES PARAMETRIQUES
!
! ----------------------------------------------------------------------
!
!
! IN  NOMA   : NOM DU MAILLAGE
! IN  NEWGEO : COORDONNEES DE TOUS LES NOEUDS
! IN  NUMMAI : NUMERO ABSOLU DE LA MAILLE DANS LE MAILLAGE
! IN  KSI1   : COORDONNEE PARAMETRIQUE KSI DU PROJETE
! IN  KSI2   : COORDONNEE PARAMETRIQUE ETA DU PROJETE
! OUT GEOM   : COORDONNEES DU NOEUD
!
!
!
!
    integer ::  jdes
    integer :: nno, ino, no(9)
    real(kind=8) :: coor(27)
    character(len=8) :: alias
    real(kind=8), pointer :: vale(:) => null()
!
! ----------------------------------------------------------------------
!
    call jemarq()
!
! --- ACCES AUX CHAMPS
!
    call jeveuo(newgeo(1:19)//'.VALE', 'L', vr=vale)
    call jeveuo(jexnum(noma//'.CONNEX', nummai), 'L', jdes)
!
! --- INITIALISATIONS
!
    geom(1:3) = 0.d0
!
! --- INFOS SUR LA MAILLE
!
    call mmelty(noma, nummai, alias, nno)
!
! --- NUMEROS ABSOLUS DES NOEUDS DE LA MAILLE
!
    do ino = 1, nno
        no(ino) = zi(jdes+ino-1)
    end do
!
! --- COORDONNEES DES NOEUDS DE LA MAILLE
!
    do ino = 1, nno
        coor(3*(ino-1)+1) = vale(1+3*(no(ino)-1))
        coor(3*(ino-1)+2) = vale(1+3*(no(ino)-1)+1)
        coor(3*(ino-1)+3) = vale(1+3*(no(ino)-1)+2)
    end do
!
! --- CALCUL DES COORDONNEES
!
    call mmvalp(ndim, alias, nno, 3, ksi1,&
                ksi2, coor, geom)
!
    call jedema()
end subroutine
