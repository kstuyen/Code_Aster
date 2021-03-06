# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: natacha.bereux at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def assemblage_prod(self,NUME_DDL,MATR_ASSE,VECT_ASSE,**args):
  if ((not MATR_ASSE) and (not VECT_ASSE)):  raise AsException("Aucun concept a assembler")
  if not NUME_DDL :  raise AsException("Impossible de typer les concepts resultats")
  if NUME_DDL.is_typco():
    self.type_sdprod(NUME_DDL,nume_ddl_sdaster)

  if MATR_ASSE !=None:
      for m in MATR_ASSE:
        opti=m['OPTION']
        if opti in ( "RIGI_MECA","RIGI_FLUI_STRU",
                     "MASS_MECA" , "MASS_FLUI_STRU" ,"RIGI_GEOM" ,"RIGI_ROTA",
                     "AMOR_MECA","IMPE_MECA","ONDE_FLUI","MASS_MECA_DIAG",
                     "MECA_GYRO","RIGI_GYRO" ) : t=matr_asse_depl_r

        if opti in ( "RIGI_ACOU","MASS_ACOU","AMOR_ACOU",) : t=matr_asse_pres_c

        if opti in ( "RIGI_THER","RIGI_THER_CONV" ,
                     "RIGI_THER_CONV_D",) : t=matr_asse_temp_r

        if opti == "RIGI_MECA_HYST"   : t= matr_asse_depl_c

        self.type_sdprod(m['MATRICE'],t)

  if VECT_ASSE !=None:
      for v in VECT_ASSE:
        self.type_sdprod(v['VECTEUR'],cham_no_sdaster)

  return None

ASSEMBLAGE=MACRO(nom="ASSEMBLAGE",
                      op=OPS('Macro.assemblage_ops.assemblage_ops'),
                      sd_prod=assemblage_prod,
                      regles=(AU_MOINS_UN('MATR_ASSE','VECT_ASSE'),),
                      fr=tr("Calcul des matrices et vecteurs assemblés "),
         MODELE          =SIMP(statut='o',typ=modele_sdaster),
         CHAM_MATER      =SIMP(statut='f',typ=cham_mater),
         INST            =SIMP(statut='f',typ='R',defaut=0.),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
         CHARGE          =SIMP(statut='f',typ=(char_meca,char_ther,char_acou),validators=NoRepeat(),max='**'),
         CHAR_CINE       =SIMP(statut='f',typ=(char_cine_meca,char_cine_ther,char_cine_acou) ),
         NUME_DDL        =SIMP(statut='o',typ=(nume_ddl_sdaster,CO)),

         MATR_ASSE       =FACT(statut='f',max='**',
             MATRICE         =SIMP(statut='o',typ=CO),
             OPTION          =SIMP(statut='o',typ='TXM',
                                   into=("RIGI_MECA","MASS_MECA","MASS_MECA_DIAG",
                                         "AMOR_MECA","RIGI_MECA_HYST","IMPE_MECA",
                                         "ONDE_FLUI","RIGI_FLUI_STRU","MASS_FLUI_STRU",
                                         "RIGI_ROTA","RIGI_GEOM","MECA_GYRO","RIGI_GYRO",
                                         "RIGI_THER","RIGI_ACOU","MASS_ACOU","AMOR_ACOU",)
                                   ),

             b_gyro = BLOC( condition = """is_in("OPTION", ('RIGI_GYRO', 'MECA_GYRO'))""",
               GROUP_MA       =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             ),

             b_rigi_meca = BLOC( condition = """equal_to("OPTION", 'RIGI_MECA')""",
               MODE_FOURIER    =SIMP(statut='f',typ='I',defaut= 0),
             ),

             b_rigi_geom = BLOC( condition = """equal_to("OPTION", 'RIGI_GEOM')""",
               SIEF_ELGA       =SIMP(statut='o',typ=cham_elem),
               MODE_FOURIER    =SIMP(statut='f',typ='I',defaut= 0),
             ),

             b_rigi_ther = BLOC( condition = """equal_to("OPTION", 'RIGI_THER')""",
               MODE_FOURIER    =SIMP(statut='f',typ='I',defaut= 0),
             ),
#
         ), # fin MATR_ASSE
#
         VECT_ASSE       =FACT(statut='f',max='**',
             VECTEUR         =SIMP(statut='o',typ=CO),
             OPTION          =SIMP(statut='o',typ='TXM',into=("CHAR_MECA","CHAR_ACOU","CHAR_THER") ),
           b_char_meca     =BLOC(condition = """equal_to("OPTION", 'CHAR_MECA')""", fr=tr("chargement mécanique"),
              CHARGE       =SIMP(statut='f',typ=char_meca,validators=NoRepeat(),max='**'),
              MODE_FOURIER =SIMP(statut='f',typ='I',defaut= 0 ),
              ),

           b_char_ther     =BLOC(condition = """equal_to("OPTION", 'CHAR_THER')""", fr=tr("chargement thermique"),
              CHARGE           =SIMP(statut='f',typ=char_ther,validators=NoRepeat(),max='**'),
              ),

           b_char_acou     =BLOC(condition = """equal_to("OPTION", 'CHAR_ACOU')""", fr=tr("chargement acoustique"),
              CHARGE           =SIMP(statut='f',typ=char_acou,validators=NoRepeat(),max='**'),
              ),
#
         ), # fin VECT_ASSE
#
         TITRE           =SIMP(statut='f',typ='TXM'),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
);
