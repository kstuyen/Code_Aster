subroutine cpnch20(main,numa,coor,ind,nomnoe, conneo)
!
implicit none
!
#include "jeveux.h"
#include "asterfort/codent.h"
#include "asterfort/jecroc.h"
#include "asterfort/jeexin.h"
#include "asterfort/jexnom.h"
#include "asterfort/jexnum.h"
#include "asterfort/jeveuo.h"
#include "asterfort/lxlgut.h"
#include "asterfort/utmess.h"
#include "asterfort/jemarq.h"
#include "asterfort/jedema.h"
#include "asterfort/reerel.h"
#include "asterfort/assert.h"
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
    integer, intent(in) :: ind
    integer, intent(in) :: numa
    real(kind=8),intent(out) :: coor(3, *)
    character(len=8), intent(in) :: main
    character(len=24), intent(in) :: nomnoe
    integer, intent(in) :: conneo(*)
!
!
! ----------------------------------------------------------------------
!         CREATION DU NOEUD SUPPLEMENTAIRE 
!         SUR LE VOLUME 'DE LA ZONE DE CONTACT ESCLAVE'
! ----------------------------------------------------------------------
! IN        NUMA    NUMERO DE LA MAILLE COURANTE
! IN        IND     INDICE DU PREMIER NOEUD AJOUTE
! IN/JXVAR  NOMNOE  REPERTOIRE DE NOMS DES NOEUDS
! VAR       COOR    COORDONNEES DES NOEUDS
! IN        CONNEO  CONNECTIVIT2 DES ORDRE DES NOEUDS DU VOLUME 
!                   ET DE LA FACE CORRESPONDANTE
! ----------------------------------------------------------------------
!
!
    integer :: lino(20), jtab, lgnd, iret
    integer :: inc1, inc2
    real(kind=8) ::xe(3), xp(3), tabar(20*3)
!
    character(len=8) :: nomnd,eletyp
    character(len=24) :: valk
    character(len=6) :: knume
   
! ----------------------------------------------------------------------
!
! - INSERTION DES NOUVEAUX NOEUDS
    do inc1=1,16
! ------ NOM DU NOEUD CREE
        call codent(ind+inc1-1, 'G', knume)
        lgnd = lxlgut(knume)
        if (lgnd+2 .gt. 8) then
            call utmess('F', 'ALGELINE_16')
        endif
        nomnd = 'DL' // knume
! ------ DECLARATION DU NOEUD CREE
        call jeexin(jexnom(nomnoe, nomnd), iret)
        if (iret .eq. 0) then
            call jecroc(jexnom(nomnoe, nomnd))
        else
            valk = nomnd
            call utmess('F', 'ALGELINE4_5', sk=valk)
        endif
    end do
!
! - CALCUL DES COORDONNEES DES NOUVEAUX NOEUDS
    call jeveuo(jexnum(main//'.CONNEX',numa),'L',jtab)
    do  inc1=1, 20
        lino(inc1)= zi(jtab+inc1-1) 
    end do
    do inc1=1,20
        do inc2=1,3
            tabar((inc1-1)*3+inc2) =  coor(inc2,lino(inc1))      
        end do
    end do
    eletyp='H20' 
    if (conneo(1) .ne. 0 .and. conneo(2) .ne. 0 .and. conneo(3) .ne. 0 .and. conneo(4) .ne. 0) then
! ==== SOMMETS ====================================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(1)-1) = xp(1)
        coor(2,ind+conneo(1)-1) = xp(2)
        coor(3,ind+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(2)-1) = xp(1)
        coor(2,ind+conneo(2)-1) = xp(2)
        coor(3,ind+conneo(2)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(3)-1) = xp(1)
        coor(2,ind+conneo(3)-1) = xp(2)
        coor(3,ind+conneo(3)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(4)-1) = xp(1)
        coor(2,ind+conneo(4)-1) = xp(2)  
        coor(3,ind+conneo(4)-1) = xp(3)
! ==== NOEUDS MILIEUX 1=============================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(9)-1) = xp(1)
        coor(2,ind+conneo(9)-1) = xp(2)
        coor(3,ind+conneo(9)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(10)-1) = xp(1)
        coor(2,ind+conneo(10)-1) = xp(2)
        coor(3,ind+conneo(10)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(11)-1) = xp(1)
        coor(2,ind+conneo(11)-1) = xp(2)
        coor(3,ind+conneo(11)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(12)-1) = xp(1)
        coor(2,ind+conneo(12)-1) = xp(2)  
        coor(3,ind+conneo(12)-1) = xp(3)
! ==== NOEUDS MILIEUX 2=============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(1)-1) = xp(1)
        coor(2,ind+8+conneo(1)-1) = xp(2)
        coor(3,ind+8+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(2)-1) = xp(1)
        coor(2,ind+8+conneo(2)-1) = xp(2)
        coor(3,ind+8+conneo(2)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(3)-1) = xp(1)
        coor(2,ind+8+conneo(3)-1) = xp(2)
        coor(3,ind+8+conneo(3)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(4)-1) = xp(1)
        coor(2,ind+8+conneo(4)-1) = xp(2)  
        coor(3,ind+8+conneo(4)-1) = xp(3)
! ==== NOEUDS MILIEUX 3============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = -4.d0/6.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(1)-1) = xp(1)
        coor(2,ind+12+conneo(1)-1) = xp(2)
        coor(3,ind+12+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = -4.d0/6.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(2)-1) = xp(1)
        coor(2,ind+12+conneo(2)-1) = xp(2)
        coor(3,ind+12+conneo(2)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = 4.d0/6.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(3)-1) = xp(1)
        coor(2,ind+12+conneo(3)-1) = xp(2)
        coor(3,ind+12+conneo(3)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = 4.d0/6.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(4)-1) = xp(1)
        coor(2,ind+12+conneo(4)-1) = xp(2)  
        coor(3,ind+12+conneo(4)-1) = xp(3)
!==================================================================================================
!==================================================================================================
    elseif (conneo(1) .ne. 0 .and. conneo(2) .ne. 0 .and.&
            conneo(6) .ne. 0 .and. conneo(5) .ne. 0) then
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(1)-1) = xp(1)
        coor(2,ind+conneo(1)-1) = xp(2)
        coor(3,ind+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(2)-1) = xp(1)
        coor(2,ind+conneo(2)-1) = xp(2)
        coor(3,ind+conneo(2)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(6)-1) = xp(1)
        coor(2,ind+conneo(6)-1) = xp(2)
        coor(3,ind+conneo(6)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(5)-1) = xp(1)
        coor(2,ind+conneo(5)-1) = xp(2)  
        coor(3,ind+conneo(5)-1) = xp(3)
! ==== NOEUDS MILIEUX 1=============================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(9)-1) = xp(1)
        coor(2,ind+conneo(9)-1) = xp(2)
        coor(3,ind+conneo(9)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(14)-1) = xp(1)
        coor(2,ind+conneo(14)-1) = xp(2)
        coor(3,ind+conneo(14)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(17)-1) = xp(1)
        coor(2,ind+conneo(17)-1) = xp(2)
        coor(3,ind+conneo(17)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(13)-1) = xp(1)
        coor(2,ind+conneo(13)-1) = xp(2)  
        coor(3,ind+conneo(13)-1) = xp(3)
! ==== NOEUDS MILIEUX 2=============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = -1.d0/2.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(1)-1) = xp(1)
        coor(2,ind+8+conneo(1)-1) = xp(2)
        coor(3,ind+8+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = -1.d0/2.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(2)-1) = xp(1)
        coor(2,ind+8+conneo(2)-1) = xp(2)
        coor(3,ind+8+conneo(2)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = -1.d0/2.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(6)-1) = xp(1)
        coor(2,ind+8+conneo(6)-1) = xp(2)
        coor(3,ind+8+conneo(6)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = -1.d0/2.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(5)-1) = xp(1)
        coor(2,ind+8+conneo(5)-1) = xp(2)  
        coor(3,ind+8+conneo(5)-1) = xp(3)
! ==== NOEUDS MILIEUX 3============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = 1.d0/2.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(1)-1) = xp(1)
        coor(2,ind+12+conneo(1)-1) = xp(2)
        coor(3,ind+12+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = 1.d0/2.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(2)-1) = xp(1)
        coor(2,ind+12+conneo(2)-1) = xp(2)
        coor(3,ind+12+conneo(2)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = 1.d0/2.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(6)-1) = xp(1)
        coor(2,ind+12+conneo(6)-1) = xp(2)
        coor(3,ind+12+conneo(6)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = 1.d0/2.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(5)-1) = xp(1)
        coor(2,ind+12+conneo(5)-1) = xp(2)  
        coor(3,ind+12+conneo(5)-1) = xp(3)
!==================================================================================================
!==================================================================================================
    elseif (conneo(2) .ne. 0 .and. conneo(3) .ne. 0 .and.&
            conneo(7) .ne. 0 .and. conneo(6) .ne. 0) then
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(2)-1) = xp(1)
        coor(2,ind+conneo(2)-1) = xp(2)
        coor(3,ind+conneo(2)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(3)-1) = xp(1)
        coor(2,ind+conneo(3)-1) = xp(2)
        coor(3,ind+conneo(3)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(7)-1) = xp(1)
        coor(2,ind+conneo(7)-1) = xp(2)
        coor(3,ind+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(6)-1) = xp(1)
        coor(2,ind+conneo(6)-1) = xp(2)  
        coor(3,ind+conneo(6)-1) = xp(3)
! ==== NOEUDS MILIEUX 1=============================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(10)-1) = xp(1)
        coor(2,ind+conneo(10)-1) = xp(2)
        coor(3,ind+conneo(10)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(15)-1) = xp(1)
        coor(2,ind+conneo(15)-1) = xp(2)
        coor(3,ind+conneo(15)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(18)-1) = xp(1)
        coor(2,ind+conneo(18)-1) = xp(2)
        coor(3,ind+conneo(18)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(14)-1) = xp(1)
        coor(2,ind+conneo(14)-1) = xp(2)  
        coor(3,ind+conneo(14)-1) = xp(3)
! ==== NOEUDS MILIEUX 2=============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = -1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(2)-1) = xp(1)
        coor(2,ind+8+conneo(2)-1) = xp(2)
        coor(3,ind+8+conneo(2)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = 1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(3)-1) = xp(1)
        coor(2,ind+8+conneo(3)-1) = xp(2)
        coor(3,ind+8+conneo(3)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(7)-1) = xp(1)
        coor(2,ind+8+conneo(7)-1) = xp(2)
        coor(3,ind+8+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(6)-1) = xp(1)
        coor(2,ind+8+conneo(6)-1) = xp(2)  
        coor(3,ind+8+conneo(6)-1) = xp(3)
! ==== NOEUDS MILIEUX 3============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = -4.d0/6.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(2)-1) = xp(1)
        coor(2,ind+12+conneo(2)-1) = xp(2)
        coor(3,ind+12+conneo(2)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = 4.d0/6.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(3)-1) = xp(1)
        coor(2,ind+12+conneo(3)-1) = xp(2)
        coor(3,ind+12+conneo(3)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = 4.d0/6.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(7)-1) = xp(1)
        coor(2,ind+12+conneo(7)-1) = xp(2)
        coor(3,ind+12+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = -4.d0/6.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(6)-1) = xp(1)
        coor(2,ind+12+conneo(6)-1) = xp(2)  
        coor(3,ind+12+conneo(6)-1) = xp(3)
!==================================================================================================
!==================================================================================================
    elseif (conneo(4) .ne. 0 .and. conneo(8) .ne. 0 .and.&
            conneo(7) .ne. 0 .and. conneo(3) .ne. 0) then
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(4)-1) = xp(1)
        coor(2,ind+conneo(4)-1) = xp(2)
        coor(3,ind+conneo(4)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(8)-1) = xp(1)
        coor(2,ind+conneo(8)-1) = xp(2)
        coor(3,ind+conneo(8)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(7)-1) = xp(1)
        coor(2,ind+conneo(7)-1) = xp(2)
        coor(3,ind+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(3)-1) = xp(1)
        coor(2,ind+conneo(3)-1) = xp(2)  
        coor(3,ind+conneo(3)-1) = xp(3)
! ==== NOEUDS MILIEUX 1=============================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(16)-1) = xp(1)
        coor(2,ind+conneo(16)-1) = xp(2)
        coor(3,ind+conneo(16)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(19)-1) = xp(1)
        coor(2,ind+conneo(19)-1) = xp(2)
        coor(3,ind+conneo(19)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(15)-1) = xp(1)
        coor(2,ind+conneo(15)-1) = xp(2)
        coor(3,ind+conneo(15)-1) = xp(3)
    ! --- NOEUD 4
       xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(11)-1) = xp(1)
        coor(2,ind+conneo(11)-1) = xp(2)  
        coor(3,ind+conneo(11)-1) = xp(3)
! ==== NOEUDS MILIEUX 2=============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 1.d0/2.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(4)-1) = xp(1)
        coor(2,ind+8+conneo(4)-1) = xp(2)
        coor(3,ind+8+conneo(4)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 1.d0/2.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(8)-1) = xp(1)
        coor(2,ind+8+conneo(8)-1) = xp(2)
        coor(3,ind+8+conneo(8)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 1.d0/2.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(7)-1) = xp(1)
        coor(2,ind+8+conneo(7)-1) = xp(2)
        coor(3,ind+8+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
       xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 1.d0/2.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(3)-1) = xp(1)
        coor(2,ind+8+conneo(3)-1) = xp(2)  
        coor(3,ind+8+conneo(3)-1) = xp(3)
! ==== NOEUDS MILIEUX 3============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = -1.d0/2.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(4)-1) = xp(1)
        coor(2,ind+12+conneo(4)-1) = xp(2)
        coor(3,ind+12+conneo(4)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = -1.d0/2.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(8)-1) = xp(1)
        coor(2,ind+12+conneo(8)-1) = xp(2)
        coor(3,ind+12+conneo(8)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = -1.d0/2.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(7)-1) = xp(1)
        coor(2,ind+12+conneo(7)-1) = xp(2)
        coor(3,ind+12+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = -1.d0/2.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(3)-1) = xp(1)
        coor(2,ind+12+conneo(3)-1) = xp(2)  
        coor(3,ind+12+conneo(3)-1) = xp(3)
!==================================================================================================
!==================================================================================================
    elseif (conneo(1) .ne. 0 .and. conneo(5) .ne. 0 .and.&
            conneo(8) .ne. 0 .and. conneo(4) .ne. 0) then
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(1)-1) = xp(1)
        coor(2,ind+conneo(1)-1) = xp(2)
        coor(3,ind+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(5)-1) = xp(1)
        coor(2,ind+conneo(5)-1) = xp(2)
        coor(3,ind+conneo(5)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(8)-1) = xp(1)
        coor(2,ind+conneo(8)-1) = xp(2)
        coor(3,ind+conneo(8)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(4)-1) = xp(1)
        coor(2,ind+conneo(4)-1) = xp(2)  
        coor(3,ind+conneo(4)-1) = xp(3)
! ==== NOEUDS MILIEUX 1=============================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(13)-1) = xp(1)
        coor(2,ind+conneo(13)-1) = xp(2)
        coor(3,ind+conneo(13)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(20)-1) = xp(1)
        coor(2,ind+conneo(20)-1) = xp(2)
        coor(3,ind+conneo(20)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(16)-1) = xp(1)
        coor(2,ind+conneo(16)-1) = xp(2)
        coor(3,ind+conneo(16)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 0.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(12)-1) = xp(1)
        coor(2,ind+conneo(12)-1) = xp(2)  
        coor(3,ind+conneo(12)-1) = xp(3)
! ==== NOEUDS MILIEUX 2=============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = -1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(1)-1) = xp(1)
        coor(2,ind+8+conneo(1)-1) = xp(2)
        coor(3,ind+8+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(5)-1) = xp(1)
        coor(2,ind+8+conneo(5)-1) = xp(2)
        coor(3,ind+8+conneo(5)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(8)-1) = xp(1)
        coor(2,ind+8+conneo(8)-1) = xp(2)
        coor(3,ind+8+conneo(8)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/2.d0
        xe(2) = 1.d0/3.d0
        xe(3) = -1.d0/3.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(4)-1) = xp(1)
        coor(2,ind+8+conneo(4)-1) = xp(2)  
        coor(3,ind+8+conneo(4)-1) = xp(3)
! ==== NOEUDS MILIEUX 3============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = -4.d0/6.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(1)-1) = xp(1)
        coor(2,ind+12+conneo(1)-1) = xp(2)
        coor(3,ind+12+conneo(1)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = -4.d0/6.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(5)-1) = xp(1)
        coor(2,ind+12+conneo(5)-1) = xp(2)
        coor(3,ind+12+conneo(5)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = 4.d0/6.d0
        xe(3) = 4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(8)-1) = xp(1)
        coor(2,ind+12+conneo(8)-1) = xp(2)
        coor(3,ind+12+conneo(8)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = 1.d0/2.d0
        xe(2) = 4.d0/6.d0
        xe(3) = -4.d0/6.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(4)-1) = xp(1)
        coor(2,ind+12+conneo(4)-1) = xp(2)  
        coor(3,ind+12+conneo(4)-1) = xp(3)
!==================================================================================================
!==================================================================================================
    elseif (conneo(5) .ne. 0 .and. conneo(6) .ne. 0 .and.&
            conneo(7) .ne. 0 .and. conneo(8) .ne. 0) then
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(5)-1) = xp(1)
        coor(2,ind+conneo(5)-1) = xp(2)
        coor(3,ind+conneo(5)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(6)-1) = xp(1)
        coor(2,ind+conneo(6)-1) = xp(2)
        coor(3,ind+conneo(6)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(7)-1) = xp(1)
        coor(2,ind+conneo(7)-1) = xp(2)
        coor(3,ind+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(8)-1) = xp(1)
        coor(2,ind+conneo(8)-1) = xp(2)  
        coor(3,ind+conneo(8)-1) = xp(3)
! ==== NOEUDS MILIEUX 1=============================================================================
    ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(17)-1) = xp(1)
        coor(2,ind+conneo(17)-1) = xp(2)
        coor(3,ind+conneo(17)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(18)-1) = xp(1)
        coor(2,ind+conneo(18)-1) = xp(2)
        coor(3,ind+conneo(18)-1) = xp(3)
    ! --- NOEUD 3 
         xp(1:3) = 0.d0
        xe(1) = 0.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(19)-1) = xp(1)
        coor(2,ind+conneo(19)-1) = xp(2)
        coor(3,ind+conneo(19)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 0.d0
        xe(3) = 0.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+conneo(20)-1) = xp(1)
        coor(2,ind+conneo(20)-1) = xp(2)  
        coor(3,ind+conneo(20)-1) = xp(3)
! ==== NOEUDS MILIEUX 2=============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(5)-1) = xp(1)
        coor(2,ind+8+conneo(5)-1) = xp(2)
        coor(3,ind+8+conneo(5)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = -1.d0/3.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(6)-1) = xp(1)
        coor(2,ind+8+conneo(6)-1) = xp(2)
        coor(3,ind+8+conneo(6)-1) = xp(3)
    ! --- NOEUD 3 
        xp(1:3) = 0.d0
        xe(1) = 1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(7)-1) = xp(1)
        coor(2,ind+8+conneo(7)-1) = xp(2)
        coor(3,ind+8+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -1.d0/3.d0
        xe(2) = 1.d0/3.d0
        xe(3) = 1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+8+conneo(8)-1) = xp(1)
        coor(2,ind+8+conneo(8)-1) = xp(2)  
        coor(3,ind+8+conneo(8)-1) = xp(3)
! ==== NOEUDS MILIEUX 3============================================================================
        ! --- NOEUD 1 
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = -4.d0/6.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(5)-1) = xp(1)
        coor(2,ind+12+conneo(5)-1) = xp(2)
        coor(3,ind+12+conneo(5)-1) = xp(3)
    ! --- NOEUD 2 
        xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = -4.d0/6.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(6)-1) = xp(1)
        coor(2,ind+12+conneo(6)-1) = xp(2)
        coor(3,ind+12+conneo(6)-1) = xp(3)
    ! --- NOEUD 3 
         xp(1:3) = 0.d0
        xe(1) = 4.d0/6.d0
        xe(2) = 4.d0/6.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(7)-1) = xp(1)
        coor(2,ind+12+conneo(7)-1) = xp(2)
        coor(3,ind+12+conneo(7)-1) = xp(3)
    ! --- NOEUD 4
        xp(1:3) = 0.d0
        xe(1) = -4.d0/6.d0
        xe(2) = 4.d0/6.d0
        xe(3) = -1.d0/2.d0
        call reerel(eletyp, 20, 3, tabar, xe, xp)
        coor(1,ind+12+conneo(8)-1) = xp(1)
        coor(2,ind+12+conneo(8)-1) = xp(2)  
        coor(3,ind+12+conneo(8)-1) = xp(3)
!==================================================================================================
!==================================================================================================
!
    else 
        ASSERT(.false.)
    endif

!
end subroutine
