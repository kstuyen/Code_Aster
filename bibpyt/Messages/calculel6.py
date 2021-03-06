# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: josselin.delmas at edf.fr

cata_msg = {


    2: _(u"""
  Problème d'extraction : Résultat généralisé %(k1)s
"""),

    3: _(u"""
  Le paramètre n'existe pas.
"""),

    4: _(u"""
  0 ligne trouvée pour les NOM_PARA.
"""),

    5: _(u"""
  Plusieurs lignes trouvées.
"""),

    6: _(u"""
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    7: _(u"""
Erreur utilisateur dans la commande TEST_TABLE :
  On n'a pas pu trouver dans la table la valeur à tester.

Conseils :
  Plusieurs raisons peuvent expliquer l'échec du test :
    * Le paramètre testé n'existe pas dans la table
    * Les filtres utilisés sont tels qu'aucune ligne ne les vérifie
    * Dans une occurrence du mot clé filtre, l'utilisateur s'est trompé de mot clé
      pour indiquer la valeur :
        * VALE    -> réel
        * VALE_I  -> entier
        * VALE_K  -> chaîne de caractères
        * VALE_C  -> complexe

"""),

    8: _(u"""
  Le type du paramètre (%(k1)s) ne correspond pas au mot-clé VALE_* utilisé.
"""),


    10: _(u"""
  L'option %(k1)s est inconnue.
"""),

    11: _(u"""
  Erreur d'utilisation :
    Vous avez dépassé une des limites de la programmation concernant les champs de matériaux :
    On ne pas utiliser plus de 9999 matériaux différents
"""),

    15: _(u"""
  L'élément diagonal u( %(i1)d , %(i2)d ) de la factorisation est nul. %(k1)s
  la solution et les estimations d'erreurs ne peuvent être calculées. %(k2)s
"""),

    17: _(u"""
 recherche nombre de composante: erreur:  %(k1)s grandeur numéro  %(i1)d  de nom  %(k2)s
"""),

    20: _(u"""
 recherche nombre de composante: erreur: grandeur ligne numéro  %(i1)d  de nom  %(k1)s
 grandeur colonne numéro  %(i2)d
  de nom  %(k2)s
 grandeur mère numéro  %(i3)d
  de nom  %(k3)s
"""),

    21: _(u"""
 recherche nombre de composante: erreur: grandeur %(i1)d a un code inconnu:  %(i2)d
"""),

    22: _(u"""
 recherche nombre d entiers codes  %(k1)s grandeur numéro  %(i1)d  de nom  %(k2)s
"""),

    25: _(u"""
 recherche nombre d entiers codes grandeur ligne numéro  %(i1)d  de nom  %(k1)s
 grandeur colonne numéro  %(i2)d de nom  %(k2)s
 grandeur mère numéro  %(i3)d de nom  %(k3)s
"""),

    26: _(u"""
 recherche nombre d entiers codes grandeur %(i1)d a un code inconnu:  %(i2)d
"""),


    42: _(u"""
 La prise en compte de l'erreur sur une condition aux limites
 de type ECHANGE_PAROI n'a pas été encore implantée
"""),

    43: _(u"""
 le mot clé EXCIT contient plusieurs occurrences de type %(k1)s
 seule la dernière sera prise en compte
"""),

    46: _(u"""
 champ de température vide pour le numéro d'ordre : %(i1)d
"""),

    47: _(u"""
 champ FLUX_ELNO vide pour numéro d'ordre :  %(i1)d
"""),

    49: _(u"""
 erreurs données composante inconnue  %(k1)s  pour la grandeur  %(k2)s
"""),


    54: _(u"""
 Problème d'utilisation du parallélisme :
   Les fonctionnalités de parallélisme utilisées ici (calculs distribués) conduisent à créer
   des structures de données "incomplètes" (i.e. partiellement calculées sur chaque processeur).

   Malheureusement, dans la suite des traitements, le code a besoin que les structures de données soient
   "complètes". On est donc obligé d'arrêter le calcul.

 Conseils pour l'utilisateur :
   1) Il faut émettre une demande d'évolution du code pour que le calcul demandé aille à son terme.
   2) En attendant, il ne faut pas utiliser la "distribution" des structures de donnée.
      Aujourd'hui, cela veut dire :
        - éviter de se retrouver avec une "partition" du modèle dans la commande où le problème a été
          détecté.
        - pour cela, juste avant l'appel à la commande problématique, il faut appeler la commande :
          MODI_MODELE(reuse=MO, MODELE=MO, DISTRIBUTION=_F(METHODE='CENTRALISE'))
"""),

    55: _(u"""
 Problème d'utilisation du parallélisme :
   On cherche à faire la combinaison linéaire de plusieurs matrices. Certaines de ces matrices
   ne sont pas calculées complètement et d'autres le sont. On ne peut donc pas les combiner.

 Conseils pour l'utilisateur :
   1) Il faut émettre une demande d'évolution du code pour que le calcul demandé aille à son terme.
      Aide pour le développeur : Noms de deux matrices incompatibles : %(k1)s  et %(k2)s
   2) En attendant, il ne faut pas utiliser la "distribution" des structures de donnée.
      Aujourd'hui, cela veut dire :
        - éviter de se retrouver avec une "partition" du modèle dans la commande où le problème a été
          détecté.
        - pour cela, juste avant l'appel à la commande problématique, il faut appeler la commande :
          MODI_MODELE(reuse=MO, MODELE=MO, DISTRIBUTION=_F(METHODE='CENTRALISE'))
"""),




    57: _(u"""
 Erreur d'utilisation (préparation des variables de commande) :
 Pour la variable de commande %(k1)s, il y a une incohérence du
 nombre de "sous-points" entre le CARA_ELEM %(k2)s (%(i1)d)
 et le CHAM_MATER %(k3)s (%(i2)d) pour la maille %(k4)s qui est de type %(k5)s.

 Conseil :
 N'avez-vous pas défini plusieurs CARA_ELEM conduisant à des nombres de
 "sous-points" différents (COQUE_NCOU, TUYAU_NCOU, ...) ?
"""),




    61: _(u"""
    Le type de la fonction est invalide : %(k1)s
"""),

    62: _(u"""
Erreur lors de l'interpolation de la fonction %(k1)s sur la maille %(k3)s, il manque le paramètre %(k2)s
"""),


    63: _(u"""
 Erreur lors de l'interpolation de la fonction %(k1)s :
 Code retour: %(i1)d
"""),

    64: _(u"""
 Variables internes en nombre différent aux instants '+' et '-' pour la maille %(k1)s
 Instant '-' : %(i1)d
 Instant '+' : %(i2)d
"""),

    68: _(u"""
 la liste des composantes fournies est incorrecte.
 composantes dans catalogue:
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    69: _(u"""
   %(k1)s
"""),

    70: _(u"""
 composantes:
"""),

    71: _(u"""
   %(k1)s
"""),

    77: _(u"""
Problème lors de la création du champ par éléments (%(k1)s).
  Ce champ est associé au paramètre %(k3)s de l'option: '%(k2)s'
  Certaines valeurs fournies par l'utilisateur n'ont pas été recopiées dans le champ final.

  Le problème a 2 causes possibles :
   * L'affectation est faite de façon trop "large", par exemple en utilisant le mot clé TOUT='OUI'.
   * Certains éléments ne supportent pas l'affectation demandée.

Risques et conseils :
  Si le problème se produit dans la commande CREA_CHAMP :
    * Il est conseillé de vérifier le champ produit avec le mot clé INFO=2.
    * Les mots clés OPTION et NOM_PARA peuvent avoir une influence sur le résultat.

"""),

    78: _(u"""
  Problème lors du calcul de la pesanteur sur un élément de "câble poulie" :
  Le chargement doit être déclaré "suiveur".
  Il faut utiliser le mot clé : EXCIT / TYPE_CHARGE='SUIV'
"""),


    79: _(u"""
  Problème lors du calcul de l'option %(k1)s pour les éléments X-FEM :
  le champ produit est incomplet sur les éléments X-FEM.

  Risque & Conseils :
  Ce champ ne pourra pas être utilisé sur des éléments non X-FEM.
  Il vaut mieux utiliser les commandes de post-traitement spécifique
  POST_MAIL_XFEM et POST_CHAM_XFEM avant la commande CALC_CHAMP.
"""),

    80 : _(u"""
  L'amortissement du MACR_ELEM %(k1)s n'a pas encore été calculé.
 """),

    81 : _(u"""
  Il manque des amortissements.
  """),

    82: _(u"""
  Le groupe de noeuds %(k1)s n'appartient pas au maillage %(k2)s.
"""),

    83 : _(u"""
  L'option %(k1)s n'est pas traitée pour un résultat de type FOURIER_ELAS
(produit par MACRO_ELAS_MULT). Il faut faire après MACRO_ELAS_MULT une
 recombinaison de Fourier par l'opérateur COMB_FOURIER.
"""),

    85: _(u"""
  Paramètre %(k1)s inexistant dans la table.
"""),

    86: _(u"""
  Objet %(k1)s inexistant.
"""),

    87: _(u"""
  Objet %(k1)s non testable.
"""),

    89: _(u"""
  Le champ %(k1)s est à valeurs de type %(k2)s et la valeur de référence de
  type %(k3)s.
"""),

    90: _(u"""
  Le champ de type %(k1)s sont interdits.
"""),

    91: _(u"""
  Le ddl %(k1)s n'existe pas dans la grandeur %(k2)s.
"""),

    92: _(u"""
  On ne trouve pas le noeud %(k1)s.
"""),

    93: _(u"""
  On ne trouve pas le ddl.
"""),

    94: _(u"""
  Pas d'accès au résultat.
"""),

    95: _(u"""
  Type de la valeur de référence incompatible avec le type des valeurs du champ.
"""),



    97: _(u"""
  Mot-clé POINT interdit pour le champ au noeud issu de %(k1)s à l'ordre %(i1)d:
    -> champ : %(k2)s %(k3)s
"""),

    98: _(u"""
  Composante généralisée non trouvée.
"""),

    99: _(u"""
  Pas d'accès au résultat généralisé %(k1)s
"""),

}
