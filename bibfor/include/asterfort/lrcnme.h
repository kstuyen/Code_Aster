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
    subroutine lrcnme(chanom, nochmd, nomamd, nomaas, nomgd,&
                      typent, nbcmpv, ncmpva, ncmpvm, iinst,&
                      numpt, numord, inst, crit, prec,&
                      nrofic, codret)
        character(len=*) :: chanom
        character(len=*) :: nochmd
        character(len=*) :: nomamd
        character(len=8) :: nomaas
        character(len=8) :: nomgd
        integer :: typent
        integer :: nbcmpv
        character(len=*) :: ncmpva
        character(len=*) :: ncmpvm
        integer :: iinst
        integer :: numpt
        integer :: numord
        real(kind=8) :: inst
        character(len=8) :: crit
        real(kind=8) :: prec
        integer :: nrofic
        integer :: codret
    end subroutine lrcnme
end interface
