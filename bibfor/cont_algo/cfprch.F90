subroutine cfprch(ds_contact, ddepla, depdel)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/cfdisd.h"
#include "asterfort/cfdisl.h"
#include "asterfort/copisd.h"
#include "asterfort/infdbg.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/r8inir.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
    type(NL_DS_Contact), intent(in) :: ds_contact
    character(len=19) :: ddepla, depdel
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODE DISCRETE - ALGORITHME)
!
! PREPARATION DES CHAMPS
!
! ----------------------------------------------------------------------
!
! In  ds_contact       : datastructure for contact management
! IN  DDEPLA : INCREMENT DE SOLUTION SANS CORRECTION DU CONTACT
! IN  DEPDEL : INCREMENT DE DEPLACEMENT CUMULE DEPUIS DEBUT DU PAS
!
!
!
!
    integer :: ifm, niv
    integer :: ier, ieq
    integer :: neq
    character(len=24) :: atmu, afmu
    integer :: jatmu, jafmu
    character(len=19) :: ddeplc, ddepl0, ddelt
    character(len=19) :: depl0
    aster_logical :: lgcp, lctfd
    real(kind=8), pointer :: vddelt(:) => null()
    real(kind=8), pointer :: ddep0(:) => null()
    real(kind=8), pointer :: ddepc(:) => null()
    real(kind=8), pointer :: depde(:) => null()
    real(kind=8), pointer :: vdepl0(:) => null()
!
! ----------------------------------------------------------------------
!
    call jemarq()
    call infdbg('CONTACT', ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<CONTACT> ......... CREATION DES CHAMPS INITIAUX'
    endif
!
! --- PARAMETRES
!
    neq = cfdisd(ds_contact%sdcont_solv,'NEQ' )
    lgcp = cfdisl(ds_contact%sdcont_defi,'CONT_GCP')
    lctfd = cfdisl(ds_contact%sdcont_defi,'FROT_DISCRET')
!
! --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
!
    atmu = ds_contact%sdcont_solv(1:14)//'.ATMU'
    afmu = ds_contact%sdcont_solv(1:14)//'.AFMU'
!
! --- ACCES VECTEURS DEPLACEMENTS
! --- DDEPL0: INCREMENT DE SOLUTION SANS CORRECTION DU CONTACT
! --- DDEPLC: INCREMENT DE SOLUTION APRES CORRECTION DU CONTACT
! --- DDELT : INCREMENT DE SOLUTION ITERATION DE CONTACT
!
    ddepl0 = ds_contact%sdcont_solv(1:14)//'.DEL0'
    ddeplc = ds_contact%sdcont_solv(1:14)//'.DELC'
    ddelt = ds_contact%sdcont_solv(1:14)//'.DDEL'
    call jeveuo(ddeplc(1:19)//'.VALE', 'E', vr=ddepc)
    call jeveuo(ddelt (1:19)//'.VALE', 'E', vr=vddelt)
!
! --- RECOPIE DANS DDEPL0 DU CHAMP DE DEPLACEMENTS OBTENU SANS
! --- TRAITER LE CONTACT (LE DDEPLA DONNE PAR STAT_NON_LINE)
! --- CREATION DE DDEPL0 = C-1.B
!
    call copisd('CHAMP_GD', 'V', ddepla, ddepl0)
!
! --- INITIALISATION INCREMENT SOLUTIONS ITERATION DE CONTACT
!
    call r8inir(neq, 0.d0, vddelt, 1)
!
! --- INITIALISATION INCREMENT SOLUTION APRES CORRECTION DU CONTACT
!
    if (lgcp) then
        call copisd('CHAMP_GD', 'V', ddepla, ddeplc)
    else
        call r8inir(neq, 0.d0, ddepc, 1)
    endif
!
! --- CALCUL INCREMENT DE DEPLACEMENT CUMULE DEPUIS DEBUT
! --- DU PAS DE TEMPS SANS CORRECTION DU CONTACT -> DEPL0
!
    if (lctfd) then
        depl0 = ds_contact%sdcont_solv(1:14)//'.DEP0'
        ddepl0 = ds_contact%sdcont_solv(1:14)//'.DEL0'
        call jeveuo(depl0 (1:19)//'.VALE', 'E', vr=vdepl0)
        call jeveuo(ddepl0(1:19)//'.VALE', 'L', vr=ddep0)
        call jeveuo(depdel(1:19)//'.VALE', 'L', vr=depde)
        do ieq = 1, neq
            vdepl0(ieq) = ddep0(ieq)+depde(ieq)
        end do
    endif
!
! --- INTIALISATIONS DES FORCES
!
    call jeexin(afmu, ier)
    if (ier .ne. 0) then
        call jeveuo(afmu, 'E', jafmu)
        call r8inir(neq, 0.d0, zr(jafmu), 1)
    endif
    call jeexin(atmu, ier)
    if (ier .ne. 0) then
        call jeveuo(atmu, 'E', jatmu)
        call r8inir(neq, 0.d0, zr(jatmu), 1)
    endif
!
    call jedema()
!
end subroutine
