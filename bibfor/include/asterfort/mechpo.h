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
    subroutine mechpo(souche, charge, modele, chdep2, chdynr,&
                      suropt, lpain, lchin, nbopt, typcoe,&
                      alpha, calpha)
        character(len=*) :: souche
        character(len=*) :: charge
        character(len=*) :: modele
        character(len=*) :: chdep2
        character(len=*) :: chdynr
        character(len=*) :: suropt
        character(len=*) :: lpain(*)
        character(len=*) :: lchin(*)
        integer :: nbopt
        character(len=*) :: typcoe
        real(kind=8) :: alpha
        complex(kind=8) :: calpha
    end subroutine mechpo
end interface
