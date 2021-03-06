subroutine as_mmhcyr(fid, maa, conn, csize, switch,&
                     typent, typgeo, typcon, cret)
! person_in_charge: nicolas.sellenet at edf.fr
!     L'ARGUMENT CSIZE N'EST PAS DANS L'API MED
!
! COPYRIGHT (C) 1991 - 2017  EDF R&D                WWW.CODE-ASTER.ORG
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
    implicit none
#include "asterf_types.h"
#include "asterf.h"
#include "asterfort/conv_int.h"
#include "asterfort/utmess.h"
#include "med/mmhcyr.h"
    character(len=*) :: maa
    aster_int :: fid, typent, typgeo, cret
    aster_int :: typcon, switch, csize, mdnont, mdnoit
    aster_int :: conn(*)
#ifdef _DISABLE_MED
    call utmess('F', 'FERMETUR_2')
#else
!
#if med_int_kind != aster_int_kind
    med_int :: fid4, typen4, typge4, cret4
    med_int :: typco4, switc4, mdnon4, mdnoi4
    med_int, allocatable :: conn4(:)
    mdnont = -1
    mdnoit = -1
    fid4 = fid
    typen4 = typent
    typge4 = typgeo
    typco4 = typcon
    switc4 = switch
    mdnon4 = mdnont
    mdnoi4 = mdnoit
    allocate ( conn4(csize) )
    call mmhcyr(fid4, maa, mdnon4, mdnoi4, typen4,&
                typge4, typco4, switc4, conn4, cret4)
    call conv_int('med->ast', csize, vi_ast=conn, vi_med=conn4)
    cret = cret4
    deallocate (conn4)
#else
    mdnont = -1
    mdnoit = -1
    call mmhcyr(fid, maa, mdnont, mdnoit, typent,&
                typgeo, typcon, switch, conn, cret)
#endif
!
#endif
end subroutine
