subroutine tbnuli(tabin, npacri, lipacr, vi, vr,&
                  vc, vk, lprec, lcrit, nume)
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/utmess.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
!
    integer :: npacri, vi(*), nume
    real(kind=8) :: vr(*), lprec(*)
    complex(kind=8) :: vc(*)
    character(len=*) :: tabin, lipacr(*), vk(*), lcrit(*)
! ----------------------------------------------------------------------
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
!     RECUPERATION D'UN NUMERO DE LIGNE
! ----------------------------------------------------------------------
! IN  : TABIN  : NOM DE LA TABLE DONT ON VEUT RECUPERER UNE LIGNE
! IN  : NPACRI : NOMBRE DE PARAMETRES IMPLIQUES DANS LES CRITERES
! IN  : LIPACR : LISTE DES PARAMETRES CRITERES
! IN  : VI     : LISTE DES CRITERES POUR LES PARAMETRES "I"
! IN  : VR     : LISTE DES CRITERES POUR LES PARAMETRES "R"
! IN  : VC     : LISTE DES CRITERES POUR LES PARAMETRES "C"
! IN  : VK     : LISTE DES CRITERES POUR LES PARAMETRES "K"
! IN  : LPREC  : PRECISION POUR LES PARAMETRES "R"
! IN  : LCRIT  : CRITERE POUR LES PARAMETRES "R"
! OUT : NUME   : = 0 , LA LIGNE N'A PAS PU ETRE RECUPERE
!                = I , ON A RECUPERE LA LIGNE
!                < 0 , PLUSIEURS LIGNES RECUPEREES
! ----------------------------------------------------------------------
! ----------------------------------------------------------------------
    integer :: iret, nbpara, nblign, nbpu, i, j, k, n
    integer :: jvale, itrouv, ki, kr, kc, kk, jvall
    real(kind=8) :: prec, refr
    character(len=4) :: type, crit
    character(len=19) :: nomtab
    character(len=24) :: nomjv, nomjvl, inpar, jnpar
    character(len=24) :: valk
    aster_logical :: lok
    integer, pointer :: numero(:) => null()
    character(len=24), pointer :: tblp(:) => null()
    integer, pointer :: tbnp(:) => null()
! ----------------------------------------------------------------------
!
    call jemarq()
!
    nume = 0
    nomtab = tabin
!
!     --- VERIFICATION DE LA TABLE ---
!
    call jeexin(nomtab//'.TBBA', iret)
    if (iret .eq. 0) then
        call utmess('F', 'UTILITAI4_64')
    endif
!
    call jeveuo(nomtab//'.TBNP', 'E', vi=tbnp)
    nbpara = tbnp(1)
    nblign = tbnp(2)
    if (nbpara .eq. 0) then
        call utmess('F', 'UTILITAI4_65')
    endif
    if (nblign .eq. 0) goto 9999
!
!     --- VERIFICATION QUE LES PARAMETRES EXISTENT DANS LA TABLE ---
!
    call jeveuo(nomtab//'.TBLP', 'L', vk24=tblp)
    do 10 i = 1, npacri
        inpar = lipacr(i)
        do 12 j = 1, nbpara
            jnpar = tblp(1+4*(j-1))
            if (inpar .eq. jnpar) goto 10
 12     continue
        valk = inpar
        call utmess('F', 'UTILITAI6_89', sk=valk)
 10 end do
!
    nomjv = tblp(3)
    call jelira(nomjv, 'LONUTI', nbpu)
    AS_ALLOCATE(vi=numero, size=nbpu)
    do 18 i = 1, nbpu
        numero(i) = i
 18 end do
!
    ki = 0
    kr = 0
    kc = 0
    kk = 0
    do 20 i = 1, npacri
        itrouv = 0
        inpar = lipacr(i)
        do 22 j = 1, nbpara
            jnpar = tblp(1+4*(j-1))
            if (inpar .eq. jnpar) then
                type = tblp(1+4*(j-1)+1)
                nomjv = tblp(1+4*(j-1)+2)
                nomjvl = tblp(1+4*(j-1)+3)
                call jeveuo(nomjv, 'L', jvale)
                call jeveuo(nomjvl, 'L', jvall)
                if (type(1:1) .eq. 'I') then
                    ki = ki + 1
                    do 30 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 30
                        if (zi(jvale+n-1) .eq. vi(ki)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 30                 continue
                else if (type(1:1) .eq. 'R') then
                    kr = kr + 1
                    prec = lprec(kr)
                    crit = lcrit(kr)
                    do 31 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 31
                        refr = zr(jvale+n-1)
                        if (crit .eq. 'RELA') then
                            lok = (abs(vr(kr)-refr) .le. prec*abs( refr))
                        else if (crit .eq. 'EGAL') then
                            lok = ( vr(kr) .eq. refr )
                        else
                            lok = ( abs(vr(kr) - refr) .le. prec )
                        endif
                        if (lok) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 31                 continue
                else if (type(1:1) .eq. 'C') then
                    kc = kc + 1
                    do 32 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 32
                        if (zc(jvale+n-1) .eq. vc(kc)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 32                 continue
                else if (type(1:3) .eq. 'K80') then
                    kk = kk + 1
                    do 33 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 33
                        if (zk80(jvale+n-1) .eq. vk(kk)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 33                 continue
                else if (type(1:3) .eq. 'K32') then
                    kk = kk + 1
                    do 34 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 34
                        if (zk32(jvale+n-1) .eq. vk(kk)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 34                 continue
                else if (type(1:3) .eq. 'K24') then
                    kk = kk + 1
                    do 35 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 35
                        if (zk24(jvale+n-1) .eq. vk(kk)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 35                 continue
                else if (type(1:3) .eq. 'K16') then
                    kk = kk + 1
                    do 36 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 36
                        if (zk16(jvale+n-1) .eq. vk(kk)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 36                 continue
                else if (type(1:2) .eq. 'K8') then
                    kk = kk + 1
                    do 37 k = 1, nbpu
                        n = numero(k)
                        numero(k) = 0
                        if (zi(jvall+n-1) .eq. 0) goto 37
                        if (zk8(jvale+n-1) .eq. vk(kk)) then
                            itrouv = itrouv + 1
                            numero(itrouv) = n
                        endif
 37                 continue
                endif
            endif
 22     continue
        nbpu = itrouv
 20 end do
!
    if (nbpu .eq. 1) then
        nume = numero(1)
    else if (nbpu .gt. 1) then
        nume = -nbpu
    endif
!
    AS_DEALLOCATE(vi=numero)
!
9999 continue
    call jedema()
end subroutine
