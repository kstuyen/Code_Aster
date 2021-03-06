!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine nmcalv(typvec         , modelz, lischa, mate      , carele,&
                      ds_constitutive, numedd, comref, ds_measure, instam,&
                      instap         , valinc, solalg, sddyna    , option,&
                      vecele)
        use NonLin_Datastructure_type        
        character(len=6) :: typvec
        character(len=*) :: modelz
        character(len=19) :: lischa
        character(len=24) :: mate
        character(len=24) :: carele
        type(NL_DS_Constitutive), intent(in) :: ds_constitutive
        character(len=24) :: numedd
        character(len=24) :: comref
        type(NL_DS_Measure), intent(inout) :: ds_measure
        real(kind=8) :: instam
        real(kind=8) :: instap
        character(len=19) :: valinc(*)
        character(len=19) :: solalg(*)
        character(len=19) :: sddyna
        character(len=16) :: option
        character(len=19) :: vecele
    end subroutine nmcalv
end interface
