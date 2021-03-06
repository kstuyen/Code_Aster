subroutine dismpn(questi, nomobz, repi, repkz, ierd)
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
    implicit none
!     --     DISMOI(PROF_CHNO)
!     ARGUMENTS:
!     ----------
#include "jeveux.h"
#include "asterfort/dismlg.h"
#include "asterfort/jedema.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenuno.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
!
    integer :: repi, ierd, n1
    character(len=*) :: questi
    character(len=*) :: nomobz, repkz
    character(len=32) :: repk
    character(len=19) :: nomob
! ----------------------------------------------------------------------
!     IN:
!       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
!       NOMOBZ : NOM D'UN OBJET DE TYPE PROF_CHNO
!     OUT:
!       REPI   : REPONSE ( SI ENTIERE )
!       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
!       IERD   : CODE RETOUR (0--> OK, 1 --> PB)
!
!     LISTE DES QUESTIONS ADMISSIBLES:
!        'NB_DDLACT'
! ----------------------------------------------------------------------
!     VARIABLES LOCALES:
!     ------------------
    character(len=19) :: noligr
!
!
!
!-----------------------------------------------------------------------
    integer :: i,  nbddlb, nbnos, nequ, nlili
    character(len=24), pointer :: refn(:) => null()
!-----------------------------------------------------------------------
    call jemarq()
    nomob = nomobz
    repk = ' '
    repi = 0
    ierd = 0
!
    if (questi .eq. 'NB_DDLACT') then
!     --------------------------------
        call jelira(nomob//'.NUEQ', 'LONMAX', nequ)
        call jelira(nomob//'.LILI', 'NUTIOC', nlili)
        nbddlb=0
        do i = 2, nlili
            call jenuno(jexnum(nomob//'.LILI', i), noligr)
            call dismlg('NB_NO_SUP', noligr, nbnos, repk, ierd)
            nbddlb=nbddlb+ nbnos
        end do
        repi=nequ-3*(nbddlb/2)
!
!
    else if (questi.eq.'NB_EQUA') then
!     --------------------------------
        call jelira(nomob//'.NUEQ', 'LONMAX', repi)
!
!
    else if (questi.eq.'NOM_GD') then
!     --------------------------------
!       QUESTION POURRIE !! (VALABLE SUR NUME_EQUA)
!       CETTE QUESTION NE DEVRAIT PAS ETRE UTILISEE
        call jeveuo(nomob//'.REFN', 'L', vk24=refn)
        repk = refn(2) (1:8)
!
!
    else if (questi.eq.'NOM_MODELE') then
!     --------------------------------
!       QUESTION POURRIE !!
!       CETTE QUESTION NE DEVRAIT PAS ETRE UTILISEE
        call jelira(nomob//'.LILI', 'NOMUTI', n1)
        if (n1 .lt. 2) goto 98
!
        call jenuno(jexnum(nomob//'.LILI', 2), noligr)
        if (noligr(1:8) .eq. 'LIAISONS') goto 98
!
        call dismlg(questi, noligr, repi, repk, ierd)
        goto 99
!
 98     continue
        repk= ' '
        ierd=1
 99     continue
!
!
    else
        ierd=1
    endif
!
    repkz = repk
    call jedema()
end subroutine
