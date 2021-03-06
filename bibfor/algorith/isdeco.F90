subroutine isdeco(icod, idec, ndim)
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
!***********************************************************************
!    P. RICHARD     DATE 06/11/90
!-----------------------------------------------------------------------
!  BUT: DECODER UN ENTIER CODE SUR LES 30 PREMIERES PUISSANCES
!          DE DEUX ( PAS DE PUISSANCE 0)
    implicit none
!-----------------------------------------------------------------------
!
!  ICOD(*)  /I/: ENTIER CODE :
!                ICOD(1) : 30 1ERES CMPS CODE SUR LES PUISS DE 2:1 A 30
!                ICOD(2) : 30 CMPS SUIV CODE SUR LES PUISS DE 2:1 A 30
!                ...
!  IDEC     /O/: VECTEUR DES NDIM PREMIERES CMPS
!  NDIM     /I/: NOMBRE DE CMPS A DECODER
!
!-----------------------------------------------------------------------
!
    integer :: ndim, necmax
    integer :: idec(ndim), icod(*)
    integer :: nec, iec, i, ipui, k
    parameter (necmax = 10)
    integer :: ifin(necmax)
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
    nec = (ndim-1)/30 + 1
!
! --- IFIN DONNE POUR CHAQUE ENTIER CODE LE NOMBRE MAX DE CMPS
! --- QUE L'ON PEUT TROUVER SUR CET ENTIER :
!     ------------------------------------
    do 10 iec = 1, nec-1
        ifin(iec) = 30
10  end do
    ifin(nec) = ndim - 30*(nec-1)
!
    k = 0
    do 20 iec = 1, nec
        ipui = 1
        do 30 i = 1, ifin(iec)
            k = k+1
            ipui = ipui*2
            if (iand(icod(iec),ipui) .eq. ipui) then
                idec(k)=1
            else
                idec(k)=0
            endif
30      continue
20  end do
!
end subroutine
