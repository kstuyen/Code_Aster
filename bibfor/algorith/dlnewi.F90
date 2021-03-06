subroutine dlnewi(result, force0, force1, lcrea, lamort,&
                  iinteg, neq, imat, masse, rigid,&
                  amort, dep0, vit0, acc0, fexte,&
                  famor, fliai, t0, nchar, nveca,&
                  liad, lifo, modele, mate, carele,&
                  charge, infoch, fomult, numedd, nume,&
                  solveu, criter, chondp, nondp, numrep, ds_energy)
!     ------------------------------------------------------------------
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!     ------------------------------------------------------------------
!     CALCUL MECANIQUE TRANSITOIRE PAR INTEGRATION DIRECTE
!     AVEC METHODES IMPLICITES :                  - THETA-WILSON
!                                                 - NEWMARK
!
!     ------------------------------------------------------------------
!
!  HYPOTHESES :                                                "
!  ----------   SYSTEME CONSERVATIF DE LA FORME  K.U    +    M.U = F
!           OU                                           '     "
!               SYSTEME DISSIPATIF  DE LA FORME  K.U + C.U + M.U = F
!
!     ------------------------------------------------------------------
!  IN  : LCREA     : LOGIQUE INDIQUANT SI IL Y A REPRISE
!  IN  : LAMORT    : LOGIQUE INDIQUANT SI IL Y A AMORTISSEMENT
!  IN  : IINTEG    : ENTIER INDIQUANT LA METHODE D'INTEGRATION
!  IN  : NEQ       : NOMBRE D'EQUATIONS
!  IN  : IMAT      : TABLEAU D'ADRESSES POUR LES MATRICES
!  IN  : MASSE     : MATRICE DE MASSE
!  IN  : RIGID     : MATRICE DE RIGIDITE
!  IN  : AMORT     : MATRICE D'AMORTISSEMENT
!  IN  : T0        : INSTANT DE CALCUL INITIAL
!  IN  : NCHAR     : NOMBRE D'OCCURENCES DU MOT CLE CHARGE
!  IN  : NVECA     : NOMBRE D'OCCURENCES DU MOT CLE VECT_ASSE
!  IN  : LIAD      : LISTE DES ADRESSES DES VECTEURS CHARGEMENT (NVECT)
!  IN  : LIFO      : LISTE DES NOMS DES FONCTIONS EVOLUTION (NVECT)
!  IN  : MODELE    : NOM DU MODELE
!  IN  : MATE      : NOM DU CHAMP DE MATERIAU
!  IN  : CARELE    : CARACTERISTIQUES DES POUTRES ET COQUES
!  IN  : CHARGE    : LISTE DES CHARGES
!  IN  : INFOCH    : INFO SUR LES CHARGES
!  IN  : FOMULT    : LISTE DES FONC_MULT ASSOCIES A DES CHARGES
!  IN  : NUMEDD    : NUME_DDL DE LA MATR_ASSE RIGID
!  IN  : NUME      : NUMERO D'ORDRE DE REPRISE
!  IN  : SOLVEU    : NOM DU SOLVEUR
!  IN  : CHONDP    : NOMS DES ONDES PLANES
!  IN  : NONDP     : NOMBRE D'ONDES PLANES
!  VAR : DEP0      : TABLEAU DES DEPLACEMENTS A L'INSTANT N
!  VAR : VIT0      : TABLEAU DES VITESSES A L'INSTANT N
!  VAR : ACC0      : TABLEAU DES ACCELERATIONS A L'INSTANT N
! IN  NUMREP : NUMERO DE REUSE POUR LA TABLE PARA_CALC
!
! CORPS DU PROGRAMME
! aslint: disable=W1504
!
use NonLin_Datastructure_type
!
implicit none
!
!
! DECLARATION PARAMETRES D'APPELS
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/etausr.h"
#include "asterc/getfac.h"
#include "asterc/getres.h"
#include "asterc/r8prem.h"
#include "asterfort/detrsd.h"
#include "asterfort/dismoi.h"
#include "asterfort/dlarch.h"
#include "asterfort/dlnew0.h"
#include "asterfort/dltcrr.h"
#include "asterfort/dltins.h"
#include "asterfort/dyarch.h"
#include "asterfort/getvid.h"
#include "asterfort/getvr8.h"
#include "asterfort/getvtx.h"
#include "asterfort/infniv.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenuno.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
#include "asterfort/mtcmbl.h"
#include "asterfort/mtdefs.h"
#include "asterfort/mtdscr.h"
#include "asterfort/nmmoam.h"
#include "asterfort/preres.h"
#include "asterfort/sigusr.h"
#include "asterfort/trmult.h"
#include "asterfort/utmess.h"
#include "asterfort/uttcpr.h"
#include "asterfort/uttcpu.h"
#include "asterfort/vtcreb.h"
#include "asterfort/wkvect.h"
#include "asterfort/zerlag.h"
!
    integer :: iinteg, neq, imat(3), nchar, nveca, liad(*), nume, nondp
    integer :: numrep
!
    character(len=8) :: masse, rigid, amort, chondp(nondp)
    character(len=8) :: result
    character(len=19) :: force0, force1
    character(len=19) :: solveu
    character(len=24) :: modele, mate, carele, charge, infoch, fomult, numedd
    character(len=24) :: criter
    character(len=24) :: lifo(*)
!
    real(kind=8) :: dep0(*), vit0(*), acc0(*), t0, fexte(*), famor(*), fliai(*)
!
    aster_logical :: lcrea, lamort, limped, lmodst
    type(NL_DS_Energy), intent(inout) :: ds_energy
!
    character(len=6) :: nompro
    parameter (nompro = 'DLNEWI')
!
    integer :: nbtyar
    parameter ( nbtyar = 6 )
    integer :: igrpa, ipepa, perc, freqpr, last_prperc
    integer :: ibmat, iddeeq, ierr
    integer :: igrel, iexci, iexcl
    integer :: ifimpe
    integer :: idepla
    integer :: ivite1, ivitea, ivita1
    integer :: iacce1, iaccea
    integer :: ialiel, iarchi
    integer :: iwk1, iwk2, iforc2
    integer :: alarm, archiv
    integer :: ibid, iret
    integer :: ifm, niv
    integer :: ifonde, imtres
    integer :: ipas, istop, itypel, istoc, jstoc
    integer :: jbint, jlpas, jmltap, jnbpa
    integer :: jnoacc, jnodep, jnovit, jpsdel
    integer :: jrefs
    integer :: n1, na, nbexci, nbexcl, nbgrel, nbgrpa, nbmat, nbordr
    integer :: nbptpa, nbv, nd, nel, nmodam, npatot, nv
    character(len=3) :: repk
    character(len=4) :: typ1(nbtyar), typmat
    character(len=8) :: k8b, matres, modsta
    character(len=8) :: typcst(3), nomddl
    character(len=8) :: mailla
    character(len=19) :: nolig
    character(len=16) :: typear(nbtyar), nomte, k16bid, typres
    character(len=14) :: numddl
    character(len=19) :: maprec
    character(len=19) :: lisarc
    character(len=24) :: lispas, libint, linbpa
    character(len=24) :: lisins
    character(len=24) :: k24amo
    character(len=24) :: ligrel
    character(len=24) :: vitini
    character(len=24) :: vitent
    character(len=24) :: veanec, vaanec, deeq, vaonde, veonde
    character(len=24) :: valmod, basmod, famomo
    character(len=24) :: nmtres, nmat(3)
    real(kind=8) :: lcoef(3), lastarch
    real(kind=8) :: tps1(4), tps2(4)
    real(kind=8) :: a0, a1, a2, a3, a4, a5, a6, a7, a8
    real(kind=8) :: c0, c1, c2, c3, c4, c5
    real(kind=8) :: beta, gamma, dt, theta, tol, res
    real(kind=8) :: tempm, temps
    integer :: vali(2)
    real(kind=8) :: valr(2)
    aster_logical :: gasymr, gsyrie, ener
    real(kind=8), pointer :: epl1(:) => null()
    real(kind=8), pointer :: fammo(:) => null()
    real(kind=8), pointer :: vien(:) => null()
    real(kind=8), pointer :: vite(:) => null()
!
    data nomddl/'        '/
    data vitini/'&&VITINI'/
    data vitent/'&&VITENT'/
    data k24amo/'&&K24AMO'/
    data valmod,basmod,famomo/'&&VALMOD','&&BASMOD','&&FAMOMO'/
!     -----------------------------------------------------------------
    call jemarq()
!
!====
! 1. LES DONNEES DU CALCUL
!====
! 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
!
    call infniv(ifm, niv)
!
    call getres(k16bid, typres, k8b)
!
! 1.2. ==> NOM DES STRUCTURES
!
    maprec = '&&'//nompro//'.MAPREC    '
    lmodst = .false.
!
! N: SAISIE DES DONNEES AMOR_MODAL
!    (  MOT CLE FACTEUR: AMOR_MODAL  )
    call getfac('AMOR_MODAL', nmodam)
    if (nmodam .ne. 0) then
        call nmmoam(k24amo, ibid)
        valmod=k24amo(1:19)//'.VALM'
        basmod=k24amo(1:19)//'.BASM'
    endif
!
! 1.3. ==> VERIFICATION DE LA PRESENCE D'ELEMENTS AVEC L'OPTION
!         'IMPE_ABSO'
!
    ligrel = modele(1:8)//'.MODELE'
    nolig = ligrel(1:19)
!
    limped = .true.
!
    call jelira(nolig//'.LIEL', 'NUTIOC', nbgrel)
    repk = 'NON'
    do igrel = 1, nbgrel
        call jeveuo(jexnum(nolig//'.LIEL', igrel), 'L', ialiel)
        call jelira(jexnum(nolig//'.LIEL', igrel), 'LONMAX', nel)
        itypel = zi(ialiel-1+nel)
        call jenuno(jexnum('&CATA.TE.NOMTE', itypel), nomte)
        if ((nomte(1:9).eq.'MEFA_FACE') .or. (nomte(1:6).eq.'MEFASE')) then
            repk = 'OUI'
            goto 10
        endif
    end do
!
    if (repk .eq. 'NON') then
        limped = .false.
    endif
!
 10 continue
!
! 1.4. ==> ???
!
    k8b = ' '
    call dismoi('CHAM_MATER', rigid, 'MATR_ASSE', repk=k8b)
    if (k8b .eq. ' ') limped = .false.
!
    if (limped) then
        call utmess('I', 'ALGORITH3_23')
    endif
!
!     --- CHARGEMENT PAR ONDES PLANES
!
! 1.5. ==> CREATION D'UN CHAMP_NO POUR LA VITESSE INITIALE
!
    call vtcreb(vitini, 'V', 'R', nume_ddlz = numedd, nb_equa_outz = neq)
!
    call jeveuo(vitini(1:19)//'.VALE', 'E', vr=vite)
    call vtcreb(vitent, 'V', 'R', nume_ddlz = numedd, nb_equa_outz = neq)
!
    call jeveuo(vitent(1:19)//'.VALE', 'E', vr=vien)
!
! 1.6. ==> CREATION D'UN CHAMP_NO POUR L'AMORTISSEMENT MODAL
    call vtcreb(famomo, 'V', 'R', nume_ddlz = numedd, nb_equa_outz = neq)
    call jeveuo(famomo(1:19)//'.VALE', 'E', vr=fammo)
!
! 1.7. ==> VECTEURS DE TRAVAIL SUR BASE VOLATILE ---
!                  1234567890123456789
    call wkvect('&&'//nompro//'.F1', 'V V R', neq, iwk1)
    call wkvect('&&'//nompro//'.F2', 'V V R', neq, iwk2)
    call wkvect('&&'//nompro//'.FORCE2', 'V V R', neq, iforc2)
    call vtcreb('&&'//nompro//'.DEPL1', 'V', 'R', nume_ddlz = numedd, nb_equa_outz = neq)
!
    call jeveuo('&&'//nompro//'.DEPL1     '//'.VALE', 'E', vr=epl1)
    call wkvect('&&'//nompro//'.VITE1', 'V V R', neq, ivite1)
    call wkvect('&&'//nompro//'.ACCE1', 'V V R', neq, iacce1)
    veanec = '&&VEANEC           '
    vaanec = '?????'
    veonde = '&&VEONDE           '
    vaonde = '?????'
    call wkvect('&&'//nompro//'.FOIMPE', 'V V R', neq, ifimpe)
    call wkvect('&&'//nompro//'.FOONDE', 'V V R', neq, ifonde)
    call wkvect('&&'//nompro//'.DEPLA', 'V V R', neq, idepla)
    call wkvect('&&'//nompro//'.VITEA', 'V V R', neq, ivitea)
    call wkvect('&&'//nompro//'.VITA1', 'V V R', neq, ivita1)
    call wkvect('&&'//nompro//'.ACCEA', 'V V R', neq, iaccea)
!    Verification de presence des modes_statiques
    call getvid(' ', 'MODE_STAT', scal=modsta, nbret=nbv)
    call getfac('EXCIT', nbexci)
    do iexci = 1, nbexci
        call getvtx('EXCIT', 'MULT_APPUI', iocc=iexci, scal=k8b, nbret=nd)
        if (k8b .eq. 'OUI' .and. nbv .eq. 0) then
            call utmess('F', 'ALGORITH13_46')
        endif
    end do
!
! 1.8. ==> ???
!
    if (nbv .ne. 0) then
!
        lmodst = .true.
        call dismoi('NOM_MAILLA', masse, 'MATR_ASSE', repk=mailla)
        call dismoi('NOM_NUME_DDL', masse, 'MATR_ASSE', repk=numddl)
        deeq = numddl//'.NUME.DEEQ'
        call jeveuo(deeq, 'L', iddeeq)
        call getfac('EXCIT', nbexci)
        call wkvect('&&'//nompro//'.FDEP', 'V V K8', nbexci, jnodep)
        call wkvect('&&'//nompro//'.FVIT', 'V V K8', nbexci, jnovit)
        call wkvect('&&'//nompro//'.FACC', 'V V K8', nbexci, jnoacc)
        call wkvect('&&'//nompro//'.MLTP', 'V V I', nbexci, jmltap)
        call wkvect('&&'//nompro//'.IPSD', 'V V R', nbexci*neq, jpsdel)
        do iexci = 1, nbexci
!     --- CAS D'UN ACCELEROGRAMME
            call getvtx('EXCIT', 'MULT_APPUI', iocc=iexci, scal=k8b, nbret=nd)
            if (k8b .eq. 'OUI') then
                zi(jmltap+iexci-1) = 1
                call getvid('EXCIT', 'ACCE', iocc=iexci, scal=zk8(jnoacc+ iexci-1), nbret=na)
                call getvid('EXCIT', 'VITE', iocc=iexci, scal=zk8(jnovit+ iexci-1), nbret=nv)
                call getvid('EXCIT', 'DEPL', iocc=iexci, scal=zk8(jnodep+ iexci-1), nbret=nd)
                call trmult(modsta, iexci, mailla, neq, iddeeq,&
                            zr(jpsdel+ (iexci-1)*neq), numddl)
!     --- MISE A ZERO DES DDL DE LAGRANGE
                call zerlag(neq, zi(iddeeq), vectr=zr(jpsdel+ (iexci-1)*neq))
            else
                zi(jmltap+iexci-1) = 0
            endif
        end do
    else
        jnodep = 1
        jnovit = 1
        jnoacc = 1
        jmltap = 1
        jpsdel = 1
    endif
!
! 1.9. ==> INTIALISATIONS DIVERSES
!
    lcoef(1) = 1.d0
    typcst(1) = 'R'
    typcst(2) = 'R'
    typcst(3) = 'R'
    typmat = 'R'
    if (lamort) then
        nbmat = 3
    else
        nbmat = 2
    endif
    iarchi = nume
    lisins = ' '
    ener   = ds_energy%l_comp
!
! 1.10. ==> --- PARAMETRES D'INTEGRATION ---
!
    if (iinteg .eq. 1) then
        call getvr8('SCHEMA_TEMPS', 'BETA', iocc=1, scal=beta, nbret=n1)
        call getvr8('SCHEMA_TEMPS', 'GAMMA', iocc=1, scal=gamma, nbret=n1)
        res = 0.25d0* (0.5d0+gamma)* (0.5d0*gamma)
        tol = 1.d-8
        if (gamma .lt. (0.5d0-tol) .or. beta .lt. (res-tol)) then
            write (ifm,*) ' >>> NEWMARK <<<'//&
     &      'CAS CONDITIONNELLEMENT STABLE.'
        endif
        if (abs(beta) .lt. r8prem()) then
            call utmess('F', 'ALGORITH9_2')
        endif
    else
        call getvr8('SCHEMA_TEMPS', 'THETA', iocc=1, scal=theta, nbret=n1)
    endif
!
! 1.11. ==> --- LISTE DES INSTANTS DE CALCUL ET LES SORTIES ---
!
    call dltins(nbgrpa, lispas, libint, linbpa, npatot,&
                t0, lisins)
    call jeveuo(lispas, 'L', jlpas)
    call jeveuo(libint, 'L', jbint)
    call jeveuo(linbpa, 'L', jnbpa)
!
!
! 1.12. ==> --- ARCHIVAGE ---
!
    lisarc = '&&'//nompro//'.ARCHIVAGE'
    call dyarch(npatot, lisins, lisarc, nbordr, 1,&
                nbexcl, typ1)
    call jeveuo(lisarc, 'E', jstoc)
!
    typear(1) = 'DEPL'
    typear(2) = 'VITE'
    typear(3) = 'ACCE'
    if (ener) then
        typear(4) = 'FORC_EXTE'
        typear(5) = 'FORC_AMOR'
        typear(6) = 'FORC_LIAI'
    else
        typear(4) = '         '
        typear(5) = '         '
        typear(6) = '         '
    endif
    if (nbexcl .eq. nbtyar) then
        call utmess('F', 'ALGORITH3_14')
    endif
    do iexcl = 1, nbexcl
        if (typ1(iexcl) .eq. 'DEPL') then
            typear(1) = '    '
        else if (typ1(iexcl).eq.'VITE') then
            typear(2) = '    '
        else if (typ1(iexcl).eq.'ACCE') then
            typear(3) = '    '
        endif
    end do
!
!====
! 2. CREATION DU CONCEPT RESULTAT
!====
!
    t0 = zr(jbint)
    call dltcrr(result, neq, nbordr, iarchi, ' ',&
                t0, lcrea, typres, masse, rigid,&
                amort, dep0, vit0, acc0, fexte,&
                famor, fliai, numedd, nume, nbtyar,&
                typear)
!
!====
! 3. CALCUL
!====
!
! 3.1. ==> CREATION DE LA MATRICE KTILD
    matres = '&&KTILD'
    if (lamort) then
        call jeveuo(amort//'           .REFA', 'L', jrefs)
        gasymr=zk24(jrefs-1+9) .eq. 'MR'
    else
        gasymr=.false.
    endif
    call jeveuo(rigid//'           .REFA', 'L', jrefs)
    gsyrie=zk24(jrefs-1+9) .eq. 'MS'
! SI LA MATRICE DE RIGIDITE EST SYMETRIQUE
! ET SI LA LA MATRICE AMORTISSEMENT EST ASYMETRIQUE ON CONSTRUIT
! LA MATRICE KTILDE SUR LE MODELE DE LA MATRICE AMORTISSEMENT
    if (gasymr .and. gsyrie) then
        call mtdefs(matres, amort, 'V', typmat)
    else
        call mtdefs(matres, rigid, 'V', typmat)
    endif
    call mtdscr(matres)
    call jeveuo(matres//'           .&INT', 'E', imtres)
!
! 3.2. ==> BOUCLE SUR LES GROUPES DE PAS DE TEMPS
    istoc = 0
    istop = 0
    ipas = 0
    call uttcpu('CPU.DLNEWI.1', 'INIT', ' ')
    call uttcpu('CPU.DLNEWI.2', 'INIT', ' ')
    do igrpa = 1, nbgrpa
!
! 3.2.1. ==> PREALABLES
!
        call uttcpu('CPU.DLNEWI.1', 'DEBUT', ' ')
        dt = zr(jlpas-1+igrpa)
        nbptpa = zi(jnbpa-1+igrpa)
        t0 = zr(jbint-1+igrpa)
        if (iinteg .eq. 2) then
            a0 = 6.d0/ (theta*dt)/ (theta*dt)
            a1 = 3.d0/theta/dt
            a2 = 2.d0*a1
            a3 = theta*dt/2.d0
            a4 = a0/theta
            a5 = -a2/theta
            a6 = 1.d0 - 3.d0/theta
            a7 = dt/2.d0
            a8 = dt*dt/6.d0
            c0 = a0
            c1 = a2
            c2 = 2.0d0
            c3 = a1
            c4 = 2.0d0
            c5 = a3
        else if (iinteg.eq.1) then
            a0 = 1.d0/beta/dt/dt
            a1 = gamma/beta/dt
            a2 = 1.d0/beta/dt
            a3 = .5d0/beta - 1.d0
            a4 = gamma/beta - 1.d0
            a5 = dt/2.d0* (gamma/beta-2.d0)
            a6 = dt* (1.d0-gamma)
            a7 = gamma*dt
            c0 = a0
            c1 = a2
            c2 = a3
            c3 = a1
            c4 = a4
            c5 = a5
        endif
!
! 3.2.2. ==> CALCUL DE LA MATRICE DE PSEUDO-RAIDEUR
!                  K*  = K + A0*M + A1*C
        lcoef(2) = a0
        lcoef(3) = a1
!
        do ibmat = 1, nbmat
            nmat(ibmat) = zk24(zi(imat(ibmat)+1))
        end do
        nmtres = zk24(zi(imtres+1))
        call mtcmbl(nbmat, typcst, lcoef, nmat, nmtres,&
                    nomddl, ' ', 'ELIM=')
!
! 3.2.3. ==> DECOMPOSITION OU CALCUL DE LA MATRICE DE PRECONDITIONNEMENT
        call preres(solveu, 'V', ierr, maprec, matres,&
                    ibid, -9999)
!
! 3.2.4. ==> BOUCLE SUR LES NBPTPA "PETITS" PAS DE TEMPS
!
        freqpr = 5
        if (niv .eq. 2) freqpr = 1
        last_prperc = 0
!
        do ipepa = 1, nbptpa
            ipas = ipas + 1
            if (ipas .gt. npatot) goto 99
            call uttcpu('CPU.DLNEWI.2', 'DEBUT', ' ')
            istoc = 0
            temps = t0 + dt*ipepa
            tempm = t0 + dt* (ipepa-1)
            archiv = zi(jstoc+ipas-1)
            call dlnew0(result, force0, force1, iinteg, neq,&
                        istoc, iarchi, nbexci, nondp, nmodam,&
                        lamort, limped, lmodst, imat, masse,&
                        rigid, amort, nchar, nveca, liad,&
                        lifo, modele, mate, carele, charge,&
                        infoch, fomult, numedd, zr(idepla), zr(ivitea),&
                        zr(iaccea), dep0, vit0, acc0, fexte,&
                        famor, fliai, epl1, zr(ivite1), zr( iacce1),&
                        zr(jpsdel), fammo, zr(ifimpe), zr(ifonde), vien,&
                        vite, zr(ivita1), zi(jmltap), a0, a2,&
                        a3, a4, a5, a6, a7,&
                        a8, c0, c1, c2, c3,&
                        c4, c5, zk8(jnodep), zk8(jnovit), zk8(jnoacc),&
                        matres, maprec, solveu, criter, chondp,&
                        vitini, vitent, valmod, basmod,&
                        veanec, vaanec, vaonde, veonde, dt,&
                        theta, tempm, temps, iforc2, zr(iwk1),&
                        zr(iwk2), archiv, nbtyar, typear, numrep, ds_energy)
!
            if (archiv .eq. 1) lastarch = temps
            perc = int(100.d0*(real(ipas)/real(npatot)))
            if (perc .ne. last_prperc) then
                if (mod(perc,freqpr) .eq. 0) then
                    call utmess('I', 'DYNAMIQUE_89', ni=2, vali=[perc, ipas], nr=2,&
                                valr=[temps, lastarch])
                    last_prperc = perc
                end if
            end if
!
! 3.2.5. ==> VERIFICATION DU TEMPS DE CALCUL RESTANT
!
            call uttcpu('CPU.DLNEWI.2', 'FIN', ' ')
            call uttcpr('CPU.DLNEWI.2', 4, tps2)
            if (tps2(1) .lt. 5.d0 .or. tps2(4) .gt. tps2(1)) then
                istop = 1
                vali(1) = igrpa
                vali(2) = ipepa
                valr(1) = tps2(4)
                valr(2) = tps2(1)
                goto 99
            endif
!
! ---------- FIN DE LA BOUCLE SUR LES NBPTPA "PETITS" PAS DE TEMPS
        end do
!
        call uttcpu('CPU.DLNEWI.1', 'FIN', ' ')
        call uttcpr('CPU.DLNEWI.1', 4, tps1)
        if (tps1(1) .lt. 5.d0 .and. igrpa .ne. nbgrpa) then
            istop = 1
            vali(1) = igrpa
            vali(2) = ipepa
            valr(1) = tps1(4)
            valr(2) = tps1(1)
            goto 99
        endif
!
! ------- FIN BOUCLE SUR LES GROUPES DE PAS DE TEMPS
!
    end do
!
 99 continue
!
!====
! 4. ARCHIVAGE DU DERNIER INSTANT DE CALCUL POUR LES CHAMPS QUI ONT
!    ETE EXCLUS DE L'ARCHIVAGE AU FIL DES PAS DE TEMPS
!====
!
    if (nbexcl .ne. 0) then
!
        do iexcl = 1, nbexcl
            typear(iexcl) = typ1(iexcl)
        end do
        alarm = 0
        call dlarch(result, neq, istoc, iarchi, ' ',&
                    alarm, temps, nbtyar, typear, masse,&
                    dep0, vit0, acc0, fexte, famor,&
                    fliai)
    endif
!
!====
! 5. LA FIN
!====
!
!     --- VERIFICATION SI INTERRUPTION DEMANDEE PAR SIGNAL USR1
!
    if (etausr() .eq. 1) then
        call sigusr()
    endif
!
    if (istop .eq. 1) then
        call utmess('Z', 'DYNAMIQUE_10', ni=2, vali=vali, nr=2,&
                    valr=valr, num_except=28)
    endif
!
!     --- DESTRUCTION DES OBJETS DE TRAVAIL ---
!
    call jeexin(criter(1:19)//'.CRTI', iret)
    if (iret .ne. 0) then
        call jedetr(criter(1:19)//'.CRTI')
        call jedetr(criter(1:19)//'.CRTR')
        call jedetr(criter(1:19)//'.CRDE')
    endif
    call detrsd('MATR_ASSE', matres)
!
    call jedema()
!
end subroutine
