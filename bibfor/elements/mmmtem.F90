subroutine mmmtem(phasep,ndim  ,nne   ,nnm   ,mprojn, &
                  mprojt,wpg   ,ffe   ,ffm   , &
          jacobi,coefac,coefaf,coefff,rese  , &
          nrese, lambda, matrem)
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
! person_in_charge: mickael.abbas at edf.fr
!

    implicit     none
#include "asterfort/assert.h"
#include "asterfort/matini.h"
#include "asterfort/mmmmpb.h"
#include "asterfort/pmat.h"
#include "asterfort/pmavec.h"
#include "asterfort/vecini.h"
    character(len=9) :: phasep
    integer :: ndim, nne, nnm
    real(kind=8) :: mprojn(3, 3), mprojt(3, 3)
    real(kind=8) :: ffe(9), ffm(9)
    real(kind=8) :: wpg, jacobi
    real(kind=8) :: rese(3), nrese
    real(kind=8) :: coefac, coefaf
    real(kind=8) :: lambda, coefff
    real(kind=8) :: matrem(27, 27)
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
!
! CALCUL DE LA MATRICE DEPL_ESCL/DEPL_MAIT
!
! ----------------------------------------------------------------------
!
!
! IN  PHASEP : PHASE DE CALCUL
!              'CONT'      - CONTACT
!              'CONT_PENA' - CONTACT PENALISE
!              'ADHE'      - ADHERENCE
!              'ADHE_PENA' - ADHERENCE PENALISE
!              'GLIS'      - GLISSEMENT
!              'GLIS_PENA' - GLISSEMENT PENALISE
! IN  LNEWTG : .TRUE. SI CALCUL CONTRIBUTION GEOMETRIQUE EN NEWTON GENE.
! IN  NDIM   : DIMENSION DU PROBLEME
! IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
! IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
! IN  MPROJN : MATRICE DE PROJECTION NORMALE [Pn]
! IN  MPROJT : MATRICE DE PROJECTION TANGENTE [Pt]
! IN  WPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
! IN  FFE    : FONCTIONS DE FORMES DEPL. ESCL.
! IN  FFM    : FONCTIONS DE FORMES DEPL. MAIT.
! IN  DFFM   : DERIVEES PREMIERES DES FONCTIONS DE FORME MAITRES
! IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
! IN  COEFAC : COEF_AUGM_CONT
! IN  COEFAF : COEF_AUGM_FROT
! IN  LAMBDA : LAGRANGIEN DE CONTACT
! IN  RESE   : SEMI-MULTIPLICATEUR GTK DE FROTTEMENT
!               GTK = LAMBDAF + COEFAF*VITESSE
! IN  NRESE  : NORME DU SEMI-MULTIPLICATEUR GTK DE FROTTEMENT
! IN  COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
! OUT MATREM : MATRICE ELEMENTAIRE DEPL_E/DEPL_M
!
! ----------------------------------------------------------------------
!
    integer :: i, j, k, l, ii, jj, idim
    real(kind=8) :: g(3, 3), e(3, 3), d(3, 3), matprb(3, 3)
    real(kind=8) :: c1(3), c2(3), c3(3), d1(3), d2(3), d3(3)
!
! ----------------------------------------------------------------------
!
!
! --- INITIALISATIONS
!
    call matini(3, 3, 0.d0, d)
    call matini(3, 3, 0.d0, e)
    call matini(3, 3, 0.d0, g)
    call vecini(3, 0.d0, c1)
    call vecini(3, 0.d0, c2)
    call vecini(3, 0.d0, c3)
    call vecini(3, 0.d0, d1)
    call vecini(3, 0.d0, d2)
    call vecini(3, 0.d0, d3)
!
    do  idim = 1, 3
        c1(idim) = mprojt(idim,1)
        c2(idim) = mprojt(idim,2)
        c3(idim) = mprojt(idim,3)
   end do
!
! --- PRODUIT [E] = [Pt]x[Pt]
!
    call pmat(3, mprojt, mprojt, e)
!
! --- MATRICE DE PROJECTION SUR LA BOULE UNITE
!
    if (phasep(1:4) .eq. 'GLIS') then
        call mmmmpb(rese, nrese, ndim, matprb)
    endif
!
! --- VECTEUR PROJ. BOULE SUR PLAN TGT
!
    if (phasep(1:4) .eq. 'GLIS') then
        call pmavec('ZERO', 3, matprb, c1, d1)
        call pmavec('ZERO', 3, matprb, c2, d2)
        call pmavec('ZERO', 3, matprb, c3, d3)
!
! ----- MATRICE [G] = [{D1}{D2}{D3}]
!
        do 416 idim = 1, 3
            g(idim,1) = d1(idim)
            g(idim,2) = d2(idim)
            g(idim,3) = d3(idim)
416      continue
!
! ----- MATRICE [D] = [Pt]*[G]t
!
        do 423 i = 1, ndim
            do 424 j = 1, ndim
                do 425 k = 1, ndim
                    d(i,j) = g(k,i)*mprojt(k,j) + d(i,j)
425              continue
424          continue
423      continue
    endif
!
! --- CALCUL DES TERMES
!
    if (phasep(1:4) .eq. 'CONT') then
        if (phasep(6:9) .eq. 'PENA') then
            do 200 i = 1, nne
                do 190 j = 1, nnm
                    do 180 k = 1, ndim
                        do 170 l = 1, ndim
                            ii = ndim*(i-1)+l
                            jj = ndim*(j-1)+k
                            matrem(ii,jj) = matrem(ii,jj) - coefac* wpg*jacobi*ffe(i)*mprojn(l,k)&
                                            &*ffm(j)
170                      continue
180                  continue
190              continue
200          continue
        else
                do 701 i = 1, nne
                    do 691 j = 1, nnm
                        do 681 k = 1, ndim
                            do 671 l = 1, ndim
                                ii = ndim*(i-1)+l
                                jj = ndim*(j-1)+k
                                matrem(ii,jj) = matrem(ii,jj) - coefac* wpg*jacobi*ffe(i)*mprojn(&
                                                &l,k)* ffm(j)
671                          continue
681                      continue
691                  continue
701              continue
        endif
    else if (phasep(1:4).eq.'ADHE') then
        if (phasep(6:9) .eq. 'PENA') then
            do 209 i = 1, nne
                do 199 j = 1, nnm
                    do 189 k = 1, ndim
                        do 179 l = 1, ndim
                            ii = ndim*(i-1)+l
                            jj = ndim*(j-1)+k
                            matrem(ii,jj) = matrem(ii,jj) + coefaf* coefff*lambda* wpg*jacobi*ffe&
                                            &(i)*e(k,l)* ffm(j)
179                      continue
189                  continue
199              continue
209          continue
        else
            do 207 i = 1, nne
                do 197 j = 1, nnm
                    do 187 k = 1, ndim
                        do 177 l = 1, ndim
                            ii = ndim*(i-1)+l
                            jj = ndim*(j-1)+k
                            matrem(ii,jj) = matrem(ii,jj) + coefaf* coefff*lambda* wpg*jacobi*ffe&
                                            &(i)*e(k,l)* ffm(j)
177                      continue
187                  continue
197              continue
207          continue
        endif
    else if (phasep(1:4).eq.'GLIS') then
        if (phasep(6:9) .eq. 'PENA') then
            do 401 i = 1, nne
                do 491 j = 1, nnm
                    do 481 k = 1, ndim
                        do 471 l = 1, ndim
                            ii = ndim*(i-1)+l
                            jj = ndim*(j-1)+k
                            matrem(ii,jj) = matrem(ii,jj) + coefaf* coefff*lambda* wpg*jacobi*ffe&
                                            &(i)*d(l,k)* ffm(j)
471                      continue
481                  continue
491              continue
401          continue
        else
            do 801 i = 1, nne
                do 791 j = 1, nnm
                    do 781 k = 1, ndim
                        do 771 l = 1, ndim
                            ii = ndim*(i-1)+l
                            jj = ndim*(j-1)+k
                            matrem(ii,jj) = matrem(ii,jj) + coefaf* coefff*lambda* wpg*jacobi*ffe&
                                            &(i)*d(l,k)* ffm(j)
771                      continue
781                  continue
791              continue
801          continue
        endif
    else
        ASSERT(.false.)
    endif
!
end subroutine
