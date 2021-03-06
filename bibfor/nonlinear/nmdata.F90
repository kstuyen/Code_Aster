subroutine nmdata(model    , mesh      , mate      , cara_elem , ds_constitutive,&
                  list_load, solver    , ds_conv   , sddyna    , sdpost         ,&
                  sderro   , ds_energy , sdcriq    , ds_print  , ds_algopara    ,&
                  ds_inout , ds_contact, ds_measure, ds_algorom)
!
use NonLin_Datastructure_type
use Rom_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterc/getres.h"
#include "asterfort/dismoi.h"
#include "asterfort/ReadEnergy.h"
#include "asterfort/infdbg.h"
#include "asterfort/getvid.h"
#include "asterfort/ndcrdy.h"
#include "asterfort/ndlect.h"
#include "asterfort/nmcrer.h"
#include "asterfort/nmcrga.h"
#include "asterfort/nmdocn.h"
#include "asterfort/ReadContact.h"
#include "asterfort/ReadPrint.h"
#include "asterfort/ReadInOut.h"
#include "asterfort/ReadMeasure.h"
#include "asterfort/GetIOField.h"
#include "asterfort/verif_affe.h"
#include "asterfort/gettco.h"
#include "asterfort/nmdomt.h"
#include "asterfort/nmdomt_ls.h"
#include "asterfort/nmdopo.h"
#include "asterfort/nmdorc.h"
#include "asterfort/nmetdo.h"
#include "asterfort/nmlect.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=*), intent(out) :: model
    character(len=*), intent(out) :: mesh
    character(len=*), intent(out) :: mate
    character(len=*), intent(out) :: cara_elem
    type(NL_DS_Constitutive), intent(inout) :: ds_constitutive
    character(len=*), intent(out) :: list_load
    character(len=*), intent(out) :: solver
    type(NL_DS_Conv), intent(inout) :: ds_conv
    character(len=19) :: sddyna
    character(len=19) :: sdpost
    character(len=24) :: sderro
    type(NL_DS_Energy), intent(inout) :: ds_energy
    character(len=24) :: sdcriq
    type(NL_DS_Print), intent(inout) :: ds_print
    type(NL_DS_AlgoPara), intent(inout) :: ds_algopara
    type(NL_DS_InOut), intent(inout) :: ds_inout
    type(NL_DS_Contact), intent(inout) :: ds_contact
    type(NL_DS_Measure), intent(inout) :: ds_measure
    type(ROM_DS_AlgoPara), intent(inout) :: ds_algorom
!
! --------------------------------------------------------------------------------------------------
!
! MECA_NON_LINE - Initializations
!
! Read parameters
!
! --------------------------------------------------------------------------------------------------
!
! Out mesh             : name of mesh
! Out model            : name of model
! Out mate             : name of material characteristics (field)
! Out cara_elem        : name of elementary characteristics (field)
! IO  ds_constitutive  : datastructure for constitutive laws management
! Out list_load        : name of datastructure for list of loads
! Out solver           : name of datastructure for solver
! IO  ds_conv          : datastructure for convergence management
! IN  SDDYNA : SD DYNAMIQUE
! OUT SDPOST : SD POUR POST-TRAITEMENTS (CRIT_STAB ET MODE_VIBR)
! OUT SDERRO : SD ERREUR
! IO  ds_energy        : datastructure for energy management
! OUT SDCRIQ : SD CRITERE QUALITE
! IO  ds_print         : datastructure for printing parameters
! IO  ds_algopara      : datastructure for algorithm parameters
! IO  ds_inout         : datastructure for input/output management
! IO  ds_contact       : datastructure for contact management
! IO  ds_measure       : datastructure for measure and statistics management
! IO  ds_algorom       : datastructure for ROM parameters
!
! --------------------------------------------------------------------------------------------------
!
    integer :: ifm, niv
    character(len=8) :: result
    character(len=16) :: k16bid, nomcmd
    aster_logical :: l_etat_init, l_sigm, l_implex
    character(len=24) :: typco
!
! --------------------------------------------------------------------------------------------------
!
    call infdbg('MECA_NON_LINE', ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<MECANONLINE> Read parameters'
    endif
!
! - Get command parameters
!
    call getres(result, k16bid, nomcmd)
!
! - Read parameters for input/output management
!
    call ReadInOut('MECA', result, ds_inout)
!
! - Initial state (EVOL_NOL or stresses)
!
    call GetIOField(ds_inout, 'SIEF_ELGA', l_read_ = l_sigm)
    l_etat_init = ((ds_inout%l_stin_evol).or.(l_sigm))
!
! --- LECTURE DONNEES GENERALES
!
    call nmlect(result, model, mate, cara_elem, list_load, solver)
    call dismoi('NOM_MAILLA', model, 'MODELE', repk=mesh)
!
! --- VERIFICATION DE CARA_ELEM : COEF_RIGI_DRZ INTERDIT EN NON-LINEAIRE
!
    if (nomcmd(6:13) .eq. 'NON_LINE' ) then
        call gettco(cara_elem, typco)
        if (typco .eq. 'CARA_ELEM') then
            call verif_affe(model,cara_elem, non_lin = .true._1)
        endif
    endif
!
! - Read parameters for algorithm management
!
    call nmdomt(ds_algopara, ds_algorom)
!
! - Read parameters for algorithm management (line search)
!
    call nmdomt_ls(ds_algopara)
!
! - Read objects for constitutive laws
!
    l_implex = ds_algopara%method.eq.'IMPLEX'
    call nmdorc(model, mate, l_etat_init,&
                ds_constitutive%compor, ds_constitutive%carcri, ds_constitutive%mult_comp,&
                l_implex)
!
! - Read parameters for convergence
!
    call nmdocn(ds_conv)
!
! --- CREATION SD DYNAMIQUE
!
    call ndcrdy(result, sddyna)
!
! --- LECTURE DES OPERANDES DYNAMIQUES
!
    call ndlect(model, mate, cara_elem, list_load, sddyna)
!
! - Read parameters for post-treatment management (CRIT_STAB and MODE_VIBR)
!
    call nmdopo(sddyna, ds_algopara, sdpost)
!
! - Read parameters for contact management
!
    call ReadContact(ds_contact,ds_conv%iter_glob_maxi)
!
! - Read parameters for energy management
!
    call ReadEnergy(ds_energy)
!
! - Read parameters for measure and statistic management
!
    call ReadMeasure(ds_measure)
!
! --- LECTURE DES DONNEES GESTION ALGORITHME
!
    call nmcrga(sderro)
!
! --- LECTURE DES DONNEES CRITERE QUALITE
!
    if (nomcmd .eq. 'STAT_NON_LINE') then
        call nmcrer(ds_constitutive%carcri, sdcriq)
        call nmetdo(sdcriq)
    endif
!
! - Read parameters for printing
!
    call ReadPrint(ds_print)
!
end subroutine
