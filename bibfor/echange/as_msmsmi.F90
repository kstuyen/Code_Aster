subroutine as_msmsmi(fid, iterat, nom, dim, desc,&
                     typrep, nocomp, unit, cret)
! person_in_charge: nicolas.sellenet at edf.fr
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
    implicit none
#include "asterf_types.h"
#include "asterf.h"
#include "asterfort/utmess.h"
#include "med/msmsmi.h"
    character(len=*) :: nom
    character(len=*) :: desc
    character(len=16) :: nocomp(3), unit(3)
    aster_int :: fid, dim, cret, typrep, iterat
#ifdef _DISABLE_MED
    call utmess('F', 'FERMETUR_2')
#else
!
#if med_int_kind != aster_int_kind
    med_int :: fid4, dim4, cret4, typre4, itera4
    fid4 = fid
    itera4 = iterat
    call msmsmi(fid4, itera4, nom, dim4, dim4,&
                desc, typre4, nocomp, unit, cret4)
    dim = dim4
    typrep = typre4
    cret = cret4
#else
    call msmsmi(fid, iterat, nom, dim, dim,&
                desc, typrep, nocomp, unit, cret)
#endif
!
#endif
end subroutine
