subroutine liscom(nomo, codarr, lischa)
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/dismoi.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/lisico.h"
#include "asterfort/lislch.h"
#include "asterfort/lislco.h"
#include "asterfort/lisnnb.h"
#include "asterfort/utmess.h"
    character(len=19) :: lischa
    character(len=1) :: codarr
    character(len=8) :: nomo
!
! ----------------------------------------------------------------------
!
! ROUTINE UTILITAIRE (LISTE_CHARGES)
!
! VERIFICATION DE LA COHERENCE DES MODELES
!
! ----------------------------------------------------------------------
!
!
! IN  NOMO   : NOM DU MODELE
! IN  CODARR : TYPE DE MESSAGE INFO/ALARME/ERREUR SI PAS COMPATIBLE
! IN  LISCHA : SD LISTE DES CHARGES
!
! ----------------------------------------------------------------------
!
    integer :: ichar, nbchar
    character(len=8) :: modch2, charge, modch1
    integer :: genrec
    aster_logical :: lveag, lveas
!
! ----------------------------------------------------------------------
!
    call jemarq()
!
! --- NOMBRE DE CHARGES
!
    call lisnnb(lischa, nbchar)
    if (nbchar .eq. 0) goto 999
!
! --- VERIF. PREMIERE CHARGE
!
    ichar = 1
    call lislch(lischa, ichar, charge)
    call lislco(lischa, ichar, genrec)
    lveag = lisico('VECT_ASSE_GENE',genrec)
    lveas = lisico('VECT_ASSE' ,genrec)
    if (nomo .ne. ' ') then
        if (.not.lveag .and. .not.lveas) then
            call dismoi('NOM_MODELE', charge, 'CHARGE', repk=modch1)
            if (modch1 .ne. nomo) then
                call utmess(codarr, 'CHARGES5_5', sk=charge)
            endif
        endif
    endif
!
! --- BOUCLE SUR LES CHARGES
!
    do ichar = 2, nbchar
        call lislch(lischa, ichar, charge)
        call lislco(lischa, ichar, genrec)
        lveag = lisico('VECT_ASSE_GENE',genrec)
        lveas = lisico('VECT_ASSE' ,genrec)
        if (nomo .ne. ' ') then
            if (.not.lveag .and. .not.lveas) then
                call dismoi('NOM_MODELE', charge, 'CHARGE', repk=modch2)
                if (modch1 .ne. modch2) then
                    call utmess(codarr, 'CHARGES5_6')
                endif
            endif
        endif
    end do
!
999 continue
!
    call jedema()
end subroutine
