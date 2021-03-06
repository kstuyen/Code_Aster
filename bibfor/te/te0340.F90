subroutine te0340(option, nomte)
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
#include "jeveux.h"
#include "asterfort/cgfint.h"
#include "asterfort/cginit.h"
#include "asterfort/cgtang.h"
#include "asterfort/elref2.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/tecach.h"
#include "asterfort/tecael.h"
#include "asterfort/utmess.h"
#include "blas/dcopy.h"
    character(len=16) :: option, nomte
! ......................................................................
!    - FONCTION REALISEE:  CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
!                          POUR LES ELEMENTS D'INTERFACE
!    - ARGUMENTS:
!        DONNEES:      OPTION       -->  OPTION DE CALCUL
!                      NOMTE        -->  NOM DU TYPE ELEMENT
!      INSPIRE DE TE0360
! ......................................................................
!
    character(len=8) :: typmod(2), nomail, lielrf(10)
    integer :: nno1, nno2, npg, imatuu, lgpg, lgpg1, lgpg2
    integer :: iw, ivf1, idf1, igeom, imate
    integer :: npgn, iwn, ivf1n, idf1n, jgnn
    integer :: ivf2, idf2, nnos, jgn, ino, i, nddl1
    integer :: ivarim, ivarip, iinstm, iinstp
    integer :: iddlm, iddld, icompo, icarcr
    integer :: ivectu, icontp
    integer :: ivarix
    integer :: jtab(7), iadzi, iazk24, jcret, codret
    integer :: ndim, iret, ntrou, vali(2)
    integer :: iu(3, 3), iuc(3), im(3), isect, icontm
    real(kind=8) :: tang(3, 3), a, geom(3, 3)
!
!
! - FONCTIONS DE FORME
!
    call elref2(nomte, 2, lielrf, ntrou)
    call elrefe_info(elrefe=lielrf(1),fami='RIGI',ndim=ndim,nno=nno1,nnos=nnos,&
  npg=npg,jpoids=iw,jvf=ivf1,jdfde=idf1,jgano=jgn)
    call elrefe_info(elrefe=lielrf(1),fami='NOEU',ndim=ndim,nno=nno1,nnos=nnos,&
  npg=npgn,jpoids=iwn,jvf=ivf1n,jdfde=idf1n,jgano=jgnn)
    call elrefe_info(elrefe=lielrf(2),fami='RIGI',ndim=ndim,nno=nno2,nnos=nnos,&
  npg=npg,jpoids=iw,jvf=ivf2,jdfde=idf2,jgano=jgn)
    ndim=3
    nddl1 = 5
!
! - DECALAGE D'INDICE POUR LES ELEMENTS D'INTERFACE
    call cginit(nomte, iu, iuc, im)
!
! - TYPE DE MODELISATION
!
    typmod(1) = '1D'
    typmod(2) = ' '
    codret = 0
!
! - PARAMETRES EN ENTREE
!
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PMATERC', 'L', imate)
    call jevech('PVARIMR', 'L', ivarim)
    call jevech('PDEPLMR', 'L', iddlm)
    call jevech('PDEPLPR', 'L', iddld)
    call jevech('PCONTMR', 'L', icontm)
    call jevech('PCOMPOR', 'L', icompo)
    call jevech('PCARCRI', 'L', icarcr)
    call jevech('PCAGNBA', 'L', isect)
!
!     MISE A JOUR EVENTUELLE DE LA GEOMETRIE
!
    if (zk16(icompo+2).eq. 'PETIT') then
        do ino = 1, nno1
            do i = 1, ndim
                geom(i,ino) = zr(igeom-1+(ino-1)*ndim+i)
            enddo
        enddo
    elseif (zk16(icompo+2) .eq. 'PETIT_REAC') then
        do ino = 1, nno1
            do i = 1, ndim
                geom(i,ino) = zr(igeom-1+(ino-1)*ndim+i)&
                            + zr(iddlm-1+(ino-1)*nddl1+i)&
                            + zr(iddld-1+(ino-1)*nddl1+i)
            enddo
        enddo
    else
        call utmess('F', 'ALGORITH17_2', sk=zk16(icompo+2))
    endif
!
!     DEFINITION DES TANGENTES
!
    call cgtang(3, nno1, npgn, geom, zr(idf1n),&
                tang)
!
!     SECTION DE LA BARRE
    a = zr(isect)
!
! - ON VERIFIE QUE PVARIMR ET PVARIPR ONT LE MEME NOMBRE DE V.I. :
!
    call tecach('OOO', 'PVARIMR', 'L', iret, nval=7,&
                itab=jtab)
    lgpg1 = max(jtab(6),1)*jtab(7)
!
    if ((option(1:4).eq.'RAPH') .or. (option(1:4).eq.'FULL')) then
        call tecach('OOO', 'PVARIPR', 'E', iret, nval=7,&
                    itab=jtab)
        lgpg2 = max(jtab(6),1)*jtab(7)
!
        if (lgpg1 .ne. lgpg2) then
            call tecael(iadzi, iazk24)
            nomail = zk24(iazk24-1+3) (1:8)
            vali(1)=lgpg1
            vali(2)=lgpg2
            call utmess('A', 'CALCULEL6_64', sk=nomail, ni=2, vali=vali)
        endif
    endif
    lgpg = lgpg1
!
!
! - VARIABLES DE COMMANDE
!
    call jevech('PINSTMR', 'L', iinstm)
    call jevech('PINSTPR', 'L', iinstp)
!
!
! PARAMETRES EN SORTIE
!
    if (option(1:4) .eq. 'RIGI' .or. option(1:4) .eq. 'FULL') then
        call jevech('PMATUNS', 'E', imatuu)
    else
        imatuu=1
    endif
!
    if (option(1:4) .eq. 'RAPH' .or. option(1:4) .eq. 'FULL') then
        call jevech('PVECTUR', 'E', ivectu)
        call jevech('PCONTPR', 'E', icontp)
        call jevech('PVARIPR', 'E', ivarip)
!
!      ESTIMATION VARIABLES INTERNES A L'ITERATION PRECEDENTE
        call jevech('PVARIMP', 'L', ivarix)
        call dcopy(npg*lgpg, zr(ivarix), 1, zr(ivarip), 1)
    else
        ivectu=1
        icontp=1
        ivarip=1
    endif
!
!
! - FORCES INTERIEURES ET MATRICE TANGENTE
!
!
    call cgfint(ndim, nno1, nno2, npg, zr(iw),&
                zr(ivf1), zr(ivf2), zr(idf1), geom, tang,&
                typmod, option, zi(imate), zk16(icompo), lgpg,&
                zr(icarcr), zr(iinstm), zr(iinstp), zr(iddlm), zr(iddld),&
                iu, iuc, im, a, zr(icontm),&
                zr(ivarim), zr(icontp), zr(ivarip), zr( imatuu), zr(ivectu),&
                codret)
!
    if (option(1:4) .eq. 'FULL' .or. option(1:4) .eq. 'RAPH') then
        call jevech('PCODRET', 'E', jcret)
        zi(jcret) = codret
    endif
!
end subroutine
