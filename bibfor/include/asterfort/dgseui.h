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
interface
    subroutine dgseui(em, num, ef, nuf, eb,&
                      nub, sytb, h, icisai, syt,&
                      syc, dxd, syf, drd, pelast,&
                      pelasf, icompr)
        real(kind=8) :: em
        real(kind=8) :: num
        real(kind=8) :: ef
        real(kind=8) :: nuf
        real(kind=8) :: eb
        real(kind=8) :: nub
        real(kind=8) :: sytb
        real(kind=8) :: h
        integer :: icisai
        real(kind=8) :: syt
        real(kind=8) :: syc
        real(kind=8) :: dxd
        real(kind=8) :: syf
        real(kind=8) :: drd
        real(kind=8) :: pelast
        real(kind=8) :: pelasf
        integer :: icompr
    end subroutine dgseui
end interface
