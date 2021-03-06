subroutine lkcomp(fami, kpg, ksp, typmod, imate, instam, instap, &
                  deps, sigm, vinm,&
                  option, sigp, vinp, dside, retcom,&
                  invi)
!
    implicit none
#include "asterc/r8prem.h"
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/lcdevi.h"
#include "asterfort/lcdive.h"
#include "asterfort/lceqma.h"
#include "asterfort/lcprmv.h"
#include "asterfort/lcprsc.h"
#include "asterfort/lcsove.h"
#include "asterfort/lkcrip.h"
#include "asterfort/lkcriv.h"
#include "asterfort/lkdgde.h"
#include "asterfort/lkelas.h"
#include "asterfort/lkgamp.h"
#include "asterfort/lklmat.h"
#include "asterfort/lkoptg.h"
#include "asterfort/r8inir.h"
#include "asterfort/trace.h"
#include "asterfort/utmess.h"
#include "asterfort/get_varc.h"
    integer :: retcom, imate, invi
    character(len=*), intent(in) :: fami
    integer, intent(in) :: kpg
    integer, intent(in) :: ksp
    character(len=8) :: typmod(*)
    character(len=16) :: option
    real(kind=8) :: instam, instap
    real(kind=8) :: deps(6)
    real(kind=8) :: sigm(6), vinm(invi)
    real(kind=8) :: sigp(6), vinp(invi)
    real(kind=8) :: dside(6, 6)
! ======================================================================
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
! =================================================================
! --- MODELE LETK : LAIGLE ET KLEINE (CIH)  MODELE VISCOPLASTIQUE--
! =================================================================
! --- BUT : ROUTINE PRINCIPALE---------------------------
! =================================================================
! IN  NDIM    : DIMENSION DE L'ESPACE
! IN  MOD     : TYPE DE MODELISATION
! IN  IMATE   : ADRESSE DU MATERIAU CODE
! IN  COMPOR  : COMPORTEMENT
! IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
! IN  INSTAM  : INSTANT DU CALCUL PRECEDENT
! IN  INSTAP  : INSTANT DU CALCUL
! IN  DEPS    : INCREMENT DE DEFORMATION
! IN  SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
! IN  VINM    : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
! IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
! OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
! OUT VINP    : VARIABLES INTERNES A L'INSTANT ACTUEL
! OUT DSIDE   : MATRICE CARREE (INUTILISE POUR RAPH_MECA)
! OUT RETCOM  : CODE RETOUR POUR LE REDECOUPAGE DU PAS DE TEMPS
!               ATTENTION LES TENSEURS ET MATRICES SONT RANGES DANS
!               L'ORDRE :  XX,YY,ZZ,SQRT(2)*XY,SQRT(2)*XZ,SQRT(2)*YZ
!=======================================================================
!=======================================================================
! --- ATTENTION : CHANGEMENT DE SIGNES DES CHAMPS DE CONTRAINTES ET DES
! ----DEFORMATIONS - DANS CE MODELE CONVENTION MECANIQUE DES SOLS A L
! ----OPPPOSE DE CELLES DE LA MECANIQUE DES MILIEUX CONTINUS - EN
! ----COMPRESSION LA CONTRAINTE EST POSITIVE ET EN CONTRACTANCE :
! ----DEFORMATION VOLUMIQUE POSITIVE
!=======================================================================
!=======================================================================
    integer :: nbmat, ndt, ndi, nvi, val, varv, i, k, matr
    integer :: iret
    integer :: indal
    aster_logical ::  l_temp
    real(kind=8) :: mun, un, zero, deux, trois
!      REAL*8        LGLEPS
    parameter    (nbmat  = 90 )
    real(kind=8) :: materd(nbmat, 2), materf(nbmat, 2)
    real(kind=8) :: dt, alpha, coef
    real(kind=8) :: sigml(6), sigpl(6), depml(6), depsth(6)
    real(kind=8) :: i1ml, sml(6), siim
    real(kind=8) :: iel, i1el, sel1(6)
    real(kind=8) :: dvml, devml(6), tm, tp, tref
    real(kind=8) :: dvml1, devml1(6)
    real(kind=8) :: sel(6), sigel(6)
    real(kind=8) :: seuilv, seuilp
    real(kind=8) :: ucrvm, seuvm, ucrpm, seupm
    real(kind=8) :: depsv(6), dgamv, dxivm, xipic
    real(kind=8) :: depsp(6), dgamp, xivm, dxip, dxiv
    real(kind=8) :: seuivm, ucrivm, ucrip, ucriv, irrev(6)
    real(kind=8) :: dsig(6), vecd(6)
    real(kind=8) :: de(6, 6), kk, mu
    real(kind=8) :: kron(6), vintr
    real(kind=8) :: somme
    character(len=3) :: matcst
! =================================================================
! --- INITIALISATION DE PARAMETRES --------------------------------
! =================================================================
    parameter       (mun   = -1.d0 )
    parameter       (un    =  1.d0 )
    parameter       (zero  =  0.d0 )
    parameter       (deux  =  2.d0 )
    parameter       (trois =  3.d0 )
!      PARAMETER       (LGLEPS =  1.0D-8 )
! =================================================================
    common /tdim/   ndt , ndi
! =================================================================
    data   kron /un , un , un , zero ,zero ,zero/
!
    dt = instap - instam
    retcom = 0
    call r8inir(6, 0.d0, depsp, 1)
    call r8inir(6, 0.d0, depsv, 1)
    dgamp = zero
    dgamv = zero
    dxip = zero
    dxiv = zero
    seuivm= zero
!
! - Get temperatures
!
    call get_varc(fami, kpg, ksp , 'T',&
                  tm , tp , tref, l_temp)

! =================================================================
! --- RECUPERATION DES PARAMETRES DU MODELE -----------------------
! --- LES COEFFICIENTS MATERIAU N EVOLUENT PAS AVEC LE TEMPS-------
! =================================================================
!
    matcst = 'OUI'
    call lklmat(typmod(1), imate, nbmat, tm, materd,&
                materf, matcst, ndt, ndi, nvi,&
                indal)
    ASSERT(invi.eq.nvi)
!      SIGC   = MATERD(3,2)
    xipic = materd(18,2)
    xivm = materd(20,2)
! =================================================================
! --- CONVENTIONS DE SIGNE DU MODELE LAIGLE VISCOPLASTIQUE --------
! =================================================================
!
    do i = 1, ndt
        sigml(i) = mun * sigm(i)
        depml(i) = mun * deps(i)
    end do
! =================================================================
! --- DEFINITION DES INVARIANTS ET DU DEVIATEUR A L'INSTANT MOINS--
! =================================================================
!
    i1ml = trace(ndi,sigml)
!
    call lcdevi(sigml, sml)
!
    call lcprsc(sml, sml, siim)
!
    siim = sqrt(siim)
!
! =================================================================
! ---PRISE EN COMPTE DE LA DILATATION THERMIQUE--------------------
! =================================================================
!
    alpha = materd(3,1)
!
    if (l_temp) then
        coef = alpha*(tp-tref) - alpha*(tm-tref)
    else
        coef = zero
    endif
!
! =================================================================
! --- DEFINITION DES DEFORMATIONS VOLUMIQUES ET DEVIATORIQUES -----
! =================================================================
    dvml = 0.d0
!
    do k = 1, ndt
        depsth(k) = depml(k)
    end do
    do k = 1, 3
        depsth(k) = depsth(k) - coef
        dvml = dvml + depsth(k)
    end do
    do k = 1, ndt
        devml(k) = depsth(k) - dvml/3.d0 * kron(k)
    end do
!
! =================================================================
! --- VERIFICATION D'UN ETAT INITIAL PLASTIQUEMENT ADMISSIBLE -----
! =================================================================
    somme = zero
    do i = 1, nvi
        somme = somme + vinm(i)
    end do
    if (abs(somme) .lt. r8prem()) then
        call lkcrip(i1ml, sml, vinm, nbmat, materd,&
                    ucrpm, seupm)
        if (seupm/materd(4,1) .gt. 1.0d-6) then
            call utmess('F', 'ALGORITH2_2')
        endif
    endif
! =================================================================
! --- PREDICTION ELASTIQUE ----------------------------------------
! =================================================================
    call lkelas(ndi, ndt, nbmat, materd, depsth,&
                sigml, de, kk, mu)
!
    iel = i1ml + trois*kk*dvml
!
    do i = 1, ndt
        sel(i) = sml(i) + deux* mu *devml(i)
    end do
!
    do i = 1, ndt
        sigel(i) = sel(i) + iel/trois*kron(i)
    end do
!
!
    if (option(1:9) .eq. 'RAPH_MECA' .or. option(1:9) .eq. 'FULL_MECA') then
! =================================================================
! --- CRITERE VISQUEUX --------------------------------------------
! =================================================================
! =================================================================
! --- CALCUL DE fv(SIGE, XIVM) ---CRITERE VISQUEUX MAX-------------
! =================================================================
        call lkcriv(xivm, iel, sel, vinm, nbmat,&
                    materd, ucrivm, seuivm)
!
!           IF (UCRIVM.LT.ZERO)  CALL UTMESS('F','COMPOR1_27')
!
!---- VARV : EN DESSOUS DU CRITERE VISQUEUX MAX : CONTRACTANCE: VARV=0
!---- VARV : AU DESSUS DU CRITERE VISQUEUX MAX  : DILATANCE:    VARV=1
!
!---- VAL  : INDICATEUR POUR LES LOIS DE DILALANCE
!----      : EN DESSOUS DU PIC ET POUR LA VISCOSITE : VAL = 0
!----      : AU DESSUS DU PIC  : VAL = 1
!
        if (seuivm .lt. zero) then
            varv = 0
        else
            varv = 1
        endif
!
        vintr = vinm(3)
!
! =================================================================
! --- CALCUL DE fv(SIGE, XIVM) ---CRITERE VISCOPLASTIQUE ---------
! =================================================================
        call lkcriv(vintr, iel, sel, vinm, nbmat,&
                    materd, ucriv, seuilv)
!
! --- VERIFICATION DU SIGNE DE U A L INSTANT MOINS AVANT ENTREE
! --- DANS LKDGDE
!
        call lkcriv(vintr, i1ml, sml, vinm, nbmat,&
                    materd, ucrvm, seuvm)
!
! =================================================================
! --- PAS DE VISCOSITE  -------------------------------------------
! =================================================================
        if (seuilv .lt. zero) then
            val = 0
            dgamv = zero
            dxiv = zero
            dvml1 = zero
!
            do i = 1, ndt
                depsv(i) = zero
                devml1(i) = zero
            end do
!
!---- XIV A T + DT ------------------------------------------------
!
            vinp(3) = vinm(3)
!
!---- GAMMAV A T + DT ---------------------------------------------
!
            vinp(4) = vinm(4)
!
! --  INDICATEUR DE VISCOSITE
            vinp(6) = 0.d0
!
        else
! =================================================================
! --- VISCOSITE  --------------------------------------------------
! =================================================================
            val = 0
!
! -------------CALCUL DE DEPSV ET DE GAMMAV ----CRITERE VISQUEUX---
            call lkdgde(val, vintr, dt, seuilv, ucrvm,&
                        i1ml, sml, vinm, nbmat, materd,&
                        depsv, dgamv, iret)
            if (iret .eq. 1) then
                retcom = 1
                goto 999
            endif
!
            dvml1 = trace(ndi,depsv)
            call lcdevi(depsv, devml1)
!
! -------------DELTA XIV
!
            dxivm = xivm - vinm(3)
            dxiv = min(dgamv,dxivm)
!
!---- XIV A T + DT ------------------------------------------------
!
            vinp(3) = vinm(3) + dxiv
!
!---- GAMMAV A T + DT ---------------------------------------------
!
            vinp(4) = vinm(4) + dgamv
!
! --  INDICATEUR DE VISCOSITE
            vinp(6) = 1.d0
!
        endif
!
! --- MISE A JOUR DE LA PREDICTION DE LA CONTRAINTE ---------------
!
        i1el = iel - trois*kk*dvml1
!
        do i = 1, ndt
            sel1(i) = sel(i) - deux* mu *devml1(i)
        end do
! =================================================================
! --- CRITERE ELASTOPLASTIQUE  ------------------------------------
! =================================================================
! --- VERIFICATION DU SIGNE DE U A L INSTANT MOINS AVANT ENTREE
! --- DANS LKGAMP et LKOPTG
!
        call lkcrip(i1ml, sml, vinm, nbmat, materd,&
                    ucrpm, seupm)
!
! =================================================================
! --- CALCUL DE fp(SIGE, XIPM) ---CRITERE ELASTOPLASTIQUE ---------
! =================================================================
        call lkcrip(i1el, sel1, vinm, nbmat, materd,&
                    ucrip, seuilp)
!
        if ((ucrip .lt. zero) .or. (ucrpm .lt. zero)) then
            retcom = 1
            goto 999
        endif
!
!==================================================================
!--------- ELASTICITE ---------------------------------------------
!==================================================================
        if (seuilp .lt. zero) then
            dgamp = zero
!
            do i = 1, ndt
                depsp(i) = zero
            end do
!
!---- REACTUALISATION DES CONTRAINTES -----------------------------
!
            do i = 1, ndt
                sigel(i) = sel1(i) + i1el/trois*kron(i)
                sigpl(i) = sigel(i)
            end do
!
! -------- DELTA XIP
!
            if (varv .eq. 0) then
!
!--------- CONTRACTANCE
!---------- ELASTICITE EN DESSOUS DU CRITERE VISQUEUX MAX
                dxip = zero
                vinp(5) = 0.0d0
!
            else if (varv.eq.1) then
!
! -------- DILATANCE
!---------- ELASTICITE EN DESSUS DU CRITERE VISQUEUX MAX
!
                dxip = dgamv
                vinp(5) = 1.0d0
!
            endif
!
!---- XIP A T + DT ------------------------------------------------
!
            vinp(1) = vinm(1) + dxip
!
!---- GAMMAP A T + DT ---------------------------------------------
!
            vinp(2) = vinm(2)
!
! --  INDICATEUR DE PLASTICITE
            vinp(7) = 0.d0
!
        else
! =================================================================
! -------- PLASTIFICATION -----------------------------------------
! =================================================================
            if (vinm(1) .lt. xipic) then
                val = 0
            else
                val = 1
            endif
!
! ------- CALCUL DE  GAMMAP -------------CRITERE ELASTOPLASTIQUE--
!
            call lkgamp(val, varv, i1ml, sml, ucrpm,&
                        seupm, vinm, nbmat, materd, de,&
                        depsth, depsv, dgamv, depsp, dgamp,&
                        iret)
!
            if (iret .eq. 1) then
                retcom = 1
                goto 999
            endif
!
! -------- DELTA XIP
!
            if (varv .eq. 0) then
!
!--------- CONTRACTANCE
!--------- PLASTIFICATION ET EN DESSOUS DU CRITERE VISQUEUX MAX
!
                dxip = dgamp
                vinp(5) = 0.0d0
!
            else if (varv.eq.1) then
!
! -------- DILATANCE
!--------- PLASTIFICATION ET EN DESSUS DU CRITERE VISQUEUX MAX
!
                dxip = dgamp + dgamv
                vinp(5) = 1.0d0
!
            endif
! =================================================================
! --- REACTUALISATION DES CONTRAINTES  ----------------------------
! =================================================================
! --- DEFORMATIONS IRREVERSIBLES ----------------------------------
!
            call lcsove(depsv, depsp, irrev)
!
            call lcdive(depsth, irrev, vecd)
!
            call lcprmv(de, vecd, dsig)
!
            do i = 1, ndt
                sigpl(i) = sigml(i) + dsig(i)
            end do
!
!==================================================================
!--------- REACTUALISATION DES VARIABLES INTERNES PLASTIQUES ------
!==================================================================
!---- XIP A T + DT ------------------------------------------------
!
            vinp(1) = vinm(1) + dxip
!
!---- GAMMAP A T + DT ---------------------------------------------
!
            vinp(2) = vinm(2) + dgamp
!
! --  INDICATEUR DE PLASTICITE
!
            vinp(7) = 1.d0
        endif
    endif
!
! =================================================================
! --- TERMES DE L OPERATEUR TANGENT -------------------------------
! =================================================================
    if (option(11:14) .eq. 'ELAS') then
        call lkelas(ndi, ndt, nbmat, materd, depsth,&
                    sigml, de, kk, mu)
        call lceqma(de, dside)
    endif
    if (option(1:14) .eq. 'RIGI_MECA_TANG' .or. option(1:9) .eq. 'FULL_MECA') then
        if (option(1:14) .eq. 'RIGI_MECA_TANG') then
            if ((vinm(7) .eq. 0.d0) .and. (vinm(6) .eq. 0.d0)) then
                matr = 0
            else if ((vinm(7) .eq. 1.d0).or.(vinm(6) .eq. 1.d0)) then
                matr = 1
            endif
        endif
        if (option(1:9) .eq. 'FULL_MECA') then
            if ((vinp(7) .eq. 0.d0) .and. (vinp(6) .eq. 0.d0)) then
                matr = 0
            else if ((vinp(7) .eq. 1.d0).or.(vinp(6) .eq. 1.d0)) then
                matr = 1
            endif
        endif
        call r8inir(6*6, 0.d0, dside, 1)
        call lkelas(ndi, ndt, nbmat, materd, depsth,&
                    sigml, de, kk, mu)
!
        if (matr .eq. 0) then
!
!
            do i = 1, ndt
                do k = 1, ndt
                    dside(i,k) = de(i,k)
                end do
            end do
!
        else
!
            if (vinm(1) .lt. xipic) then
                val = 0
            else
                val = 1
            endif
!
            if (seuivm .lt. zero) then
                varv = 0
            else
                varv = 1
            endif
!
            vintr=vinm(3)
!
            call lkcrip(i1ml, sml, vinm, nbmat, materd,&
                        ucrpm, seupm)
!
            call lkcriv(vintr, i1ml, sml, vinm, nbmat,&
                        materd, ucrvm, seuvm)
!
            call lkcriv(vintr, iel, sel, vinm, nbmat,&
                        materd, ucriv, seuilv)
!
            call lkoptg(val, varv, dt, nbmat, materd,&
                        i1ml, sml, iel, sel, ucrpm,&
                        ucrvm, ucriv, seuilv, vinm, de,&
                        depsv, dside, iret)
!
!
            if (iret .eq. 1) then
                retcom = 1
                goto 999
            endif
!
        endif
!
    endif
!==================================================================
!--------- CONTRAINTES DE SORTIE:
! -------- RETABLISSEMENT DES SIGNES POUR ASTER --
!==================================================================
    do i = 1, ndt
        sigp(i) = mun * sigpl(i)
        deps(i) = mun * depsth(i)
    end do
! =================================================================
999 continue
end subroutine
