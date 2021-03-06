subroutine meharm(modele, nh, chharm)
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
    implicit none
#include "asterfort/dismoi.h"
#include "asterfort/mecact.h"
    character(len=*) :: modele
    character(len=24) :: chharm
    character(len=8) :: mailla
!
!    CETTE ROUTINE GENERE UN CHAMP D'HARMONIQUE (CARTE CONSTANTE)
!
!-----------------------------------------------------------------------
    integer :: nh
!-----------------------------------------------------------------------
    call dismoi('NOM_MAILLA', modele, 'MODELE', repk=mailla)
    chharm = '&&MEHARM.NUME_HARM'
    call mecact('V', chharm, 'MAILLA', mailla, 'HARMON',&
                ncmp=1, nomcmp='NH', si=nh)
end subroutine
