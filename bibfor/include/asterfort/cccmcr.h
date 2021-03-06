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
    subroutine cccmcr(jcesdd, numma, jrepe, jconx2, jconx1,&
                      jcoord, adcar1, adcar2, ialpha, ibeta,&
                      iepais, jalpha, jbeta, jgamma, ligrmo,&
                      ino, pgl, modeli, codret)
        integer :: jcesdd
        integer :: numma
        integer :: jrepe
        integer :: jconx2
        integer :: jconx1
        integer :: jcoord
        integer :: adcar1(3)
        integer :: adcar2(3)
        integer :: ialpha
        integer :: ibeta
        integer :: iepais
        integer :: jalpha
        integer :: jbeta
        integer :: jgamma
        character(len=19) :: ligrmo
        integer :: ino
        real(kind=8) :: pgl(3, 3)
        character(len=16) :: modeli
        integer :: codret
    end subroutine cccmcr
end interface
