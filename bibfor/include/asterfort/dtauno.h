!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
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
#include "asterf_types.h"
!
interface
    subroutine dtauno(jrwork, lisnoe, nbnot, nbordr, ordini,&
                      nnoini, nbnop, tspaq, nommet, nomcri,&
                      nomfor, grdvie, forvie,forcri, nommai, cnsr,&
                      nommap, post, valpar, vresu)
        integer :: nbnot
        integer :: jrwork
        integer :: lisnoe(nbnot)
        integer :: nbordr
        integer :: ordini
        integer :: nnoini
        integer :: nbnop
        integer :: tspaq
        character(len=16) :: nommet
        character(len=16) :: nomcri
        character(len=16) :: nomfor
        character(len=16) :: grdvie
        character(len=16) :: forvie
        character(len=16) :: forcri
        character(len=8) :: nommai
        character(len=19) :: cnsr
        character(len=8) :: nommap
        aster_logical :: post
        real(kind=8) :: valpar(35)
        real(kind=8) :: vresu(24)
    end subroutine dtauno
end interface
