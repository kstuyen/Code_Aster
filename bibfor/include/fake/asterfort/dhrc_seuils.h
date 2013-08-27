!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine dhrc_seuils(eps, vint, b, c, ap1,&
                      bp1, cp1, ap2, bp2, cp2,&
                      cstseu, neta1, neta2, seuils)
        real(kind=8) :: eps(6)
        real(kind=8) :: vint(7)
        real(kind=8) :: b(6, 2, 2)
        real(kind=8) :: c(2, 2, 2)
        real(kind=8) :: ap1(6, 6)
        real(kind=8) :: bp1(6, 2)
        real(kind=8) :: cp1(2, 2)
        real(kind=8) :: ap2(6, 6)
        real(kind=8) :: bp2(6, 2)
        real(kind=8) :: cp2(2, 2)
        real(kind=8) :: cstseu(2)
        real(kind=8) :: neta1(2)
        real(kind=8) :: neta2(2)
        real(kind=8) :: seuils(6)
    end subroutine dhrc_seuils
end interface 
