!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
interface
   subroutine xprupw_fmm(cmnd, noma, fispre, vcn, grlr, &
                     noesom, lcmin, cnsln, grln, cnslt, &
                     grlt, isozro, nodtor,eletor, liggrd, &
                     vpoint , cnsbl ,deltat ,cnsbet ,listp, nbrinit)
       character(len=8)  :: cmnd
       character(len=8)  :: noma
       character(len=8)  :: fispre
       character(len=24) :: vcn
       character(len=24) :: grlr
       character(len=19) :: noesom
       real(kind=8)      :: lcmin
       character(len=19) :: cnsln
       character(len=19) :: grln
       character(len=19) :: cnslt
       character(len=19) :: grlt
       character(len=19) :: isozro
       character(len=19) :: nodtor
       character(len=19) :: eletor
       character(len=19) :: liggrd
       character(len=19) :: vpoint
       character(len=19) :: cnsbl
       real(kind=8)      :: deltat
       character(len=19) :: cnsbet
       character(len=19) :: listp
       integer           :: nbrinit
   end subroutine
end interface
