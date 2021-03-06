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
    subroutine gdmrig(kp, nno, ajacob, pjacob, en,&
                      enprim, x0pg, rot0, rotk, granc,&
                      pn, pm, rigi)
        integer :: kp
        integer :: nno
        real(kind=8) :: ajacob
        real(kind=8) :: pjacob
        real(kind=8) :: en(3, 2)
        real(kind=8) :: enprim(3, 2)
        real(kind=8) :: x0pg(3)
        real(kind=8) :: rot0(3, 3)
        real(kind=8) :: rotk(3, 3)
        real(kind=8) :: granc(6)
        real(kind=8) :: pn(3)
        real(kind=8) :: pm(3)
        real(kind=8) :: rigi(18, 18)
    end subroutine gdmrig
end interface
