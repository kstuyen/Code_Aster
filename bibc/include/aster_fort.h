/*           CONFIGURATION MANAGEMENT OF EDF VERSION                  */
/* ================================================================== */
/* COPYRIGHT (C) 1991 - 2012  EDF R&D              WWW.CODE-ASTER.ORG */
/*                                                                    */
/* THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR      */
/* MODIFY IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS     */
/* PUBLISHED BY THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE */
/* LICENSE, OR (AT YOUR OPTION) ANY LATER VERSION.                    */
/* THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL,    */
/* BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF     */
/* MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU   */
/* GENERAL PUBLIC LICENSE FOR MORE DETAILS.                           */
/*                                                                    */
/* YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE  */
/* ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,      */
/*    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.     */
/* ================================================================== */

#ifndef ASTER_FORT_H
#define ASTER_FORT_H

#include "aster.h"

/* *********************************************************************
 *
 * Définition des interfaces aux routines fortran appelées depuis le C.
 *
 * *********************************************************************/

/* routines UTILITAIRES */
#define CALL_R8VIDE() CALL0(R8VIDE,r8vide)
extern DOUBLE DEF0(R8VIDE,r8vide);

#define CALL_R8PI() CALL0(R8PI,r8pi)
extern DOUBLE DEF0(R8PI,r8pi);

#define CALL_ISNNEM() CALL0(ISNNEM,isnnem)
extern INTEGER DEF0(ISNNEM,isnnem);

#define CALL_ULOPEN(a,b,c,d,e) CALLPSSSS(ULOPEN,ulopen,a,b,c,d,e)
extern void DEFPSSSS(ULOPEN,ulopen,INTEGER *,char *,STRING_SIZE,char *,STRING_SIZE,
                     char *,STRING_SIZE,char *,STRING_SIZE);

#define CALL_FCLOSE(a) CALLP(FCLOSE,fclose,a)
extern void DEFP(FCLOSE,fclose,INTEGER *);

#define CALL_DISMOI(a,b,c,d,e,f,g) CALLSSSSPSP(DISMOI,dismoi,a,b,c,d,e,f,g)
extern void DEFSSSSPSP(DISMOI, dismoi, char *,STRING_SIZE, char *,STRING_SIZE,
                       char *,STRING_SIZE, char *,STRING_SIZE, INTEGER *,
                       char *,STRING_SIZE, INTEGER *);

#define CALL_MATFPE(a) CALLP(MATFPE,matfpe,a)
extern void DEFP(MATFPE, matfpe, INTEGER *);

#define CALL_OPTDEP(a,b,c) CALLSSP(OPTDEP, optdep, a, b, c)
extern void DEFSSP(OPTDEP, optdep, char *,STRING_SIZE, char *,STRING_SIZE, INTEGER *);


/* routines SUPERVISEUR */
#define CALL_EXPASS(a)  CALLP(EXPASS,expass,a)
extern void DEFP(EXPASS,expass, INTEGER*);

#define CALL_OPSEXE(a)  CALLP(OPSEXE,opsexe,a)
extern void DEFP(OPSEXE,opsexe, INTEGER*) ;

#define CALL_IMPERS() CALL0(IMPERS,impers)
extern void DEF0(IMPERS,impers);

#define CALL_ONERRF(a,b,c) CALLSSP(ONERRF,onerrf,a,b,c)
extern void DEFSSP(ONERRF,onerrf,char *,STRING_SIZE, _OUT char *,STRING_SIZE, _OUT INTEGER *);

#define CALL_GCNCON(a,b) CALLSS(GCNCON,gcncon,a,b)
extern void DEFSS(GCNCON,gcncon,char *,STRING_SIZE,char *,STRING_SIZE);

#define CALL_DEBUT() CALL0(DEBUT,debut)
extern void DEF0(DEBUT,debut);

#define CALL_IBMAIN(a) CALLP(IBMAIN,ibmain,a)
extern void DEFP(IBMAIN,ibmain, INTEGER*);

#define CALL_POURSU() CALL0(POURSU,poursu)
extern void DEF0(POURSU,poursu);


/* routines JEVEUX */
#define CALL_JEMARQ() CALL0(JEMARQ, jemarq)
extern void DEF0(JEMARQ,jemarq);

#define CALL_JEDEMA() CALL0(JEDEMA, jedema)
extern void DEF0(JEDEMA,jedema);

#define CALL_JEDETR(a) CALLS(JEDETR, jedetr, a)
extern void DEFS(JEDETR, jedetr, char *, STRING_SIZE);

#define CALL_JEDETC(a, b, c) CALLSSP(JEDETC, jedetc, a, b, c)
extern void DEFSSP(JEDETC, jedetc, char *, STRING_SIZE, char *, STRING_SIZE, INTEGER*);

#define CALL_JELST3(a,b,c,d)  CALLSSPP(JELST3,jelst3,a,b,c,d)
extern void DEFSSPP(JELST3,jelst3, char*, STRING_SIZE, char*, STRING_SIZE, INTEGER*, INTEGER*);

#define CALL_JELIRA(a,b,c,d)  CALLSSPS(JELIRA,jelira,a,b,c,d)
extern void DEFSSPS(JELIRA,jelira, char*, STRING_SIZE, char*, STRING_SIZE, INTEGER*,
                    char*, STRING_SIZE );

#define CALL_JEEXIN(a,b)  CALLSP(JEEXIN,jeexin,a,b)
extern void DEFSP(JEEXIN,jeexin, char*, STRING_SIZE, INTEGER* );


/* routines d'accès aux OBJETS JEVEUX (vecteurs, collections, champs) */
#define CALL_GETCON(nomsd,iob,ishf,ilng,ctype,lcon,iaddr,nomob) \
    CALLSPPPPPPS(GETCON,getcon,nomsd,iob,ishf,ilng,ctype,lcon,iaddr,nomob)
extern void DEFSPPPPPPS(GETCON,getcon,char *,STRING_SIZE,INTEGER *,INTEGER *,INTEGER *,
                        INTEGER *,INTEGER *,char **,char *,STRING_SIZE);

#define CALL_PUTCON(nomsd,nbind,ind,valr,valc,num,iret) \
    CALLSPPPPPP(PUTCON,putcon,nomsd,nbind,ind,valr,valc,num,iret)
extern void DEFSPPPPPP(PUTCON,putcon,char *,STRING_SIZE,INTEGER *,INTEGER *,DOUBLE *,
                       DOUBLE *,INTEGER *,INTEGER *);

#define CALL_TAILSD(nom, nomsd, val, nbval) CALLSSPP(TAILSD,tailsd,nom, nomsd, val, nbval)
extern void DEFSSPP(TAILSD,tailsd,char *,STRING_SIZE,char *,STRING_SIZE,INTEGER *, INTEGER *);

#define CALL_PRCOCH(nomce,nomcs,nomcmp,ktype,itopo,nval,groups) \
    CALLSSSSPPS(PRCOCH,prcoch,nomce,nomcs,nomcmp,ktype,itopo,nval,groups)
extern void DEFSSSSPPS(PRCOCH,prcoch,char *,STRING_SIZE,char *,STRING_SIZE,char *,STRING_SIZE,
                       char *,STRING_SIZE,INTEGER *,INTEGER *,char *,STRING_SIZE);

/* routine d'acces aux parametres memoire */
#define CALL_UTGTME(a,b,c,d) CALLPSPP(UTGTME,utgtme,a,b,c,d)
extern void DEFPSPP(UTGTME, utgtme, INTEGER *, char *,  STRING_SIZE,  DOUBLE *, INTEGER *);

#define CALL_UTPTME(a,b,c,d) CALLPSPP(UTPTME,utptme,a,b,c,d)
extern void DEFPSPP(UTpTME, utptme, INTEGER *, char *,  STRING_SIZE,  DOUBLE *, INTEGER *);

/* routines de manipulation de la SD RESULTAT */
extern void DEFSPPSPPPSP(RSACPA,rsacpa,char *, STRING_SIZE, INTEGER *, INTEGER *,
          char *, STRING_SIZE, INTEGER *, INTEGER *, DOUBLE *, char *, STRING_SIZE, INTEGER *);
#define CALL_RSACPA(nomsd, numva, icode, nomva, ctype, ival, rval, kval, ier) \
    CALLSPPSPPPSP(RSACPA,rsacpa, nomsd, numva, icode, nomva, ctype, ival, rval, kval, ier)

/* particulier car on passe les longueurs des chaines en dur */
extern void DEFSPSPPPS(RSACCH,rsacch,char *, STRING_SIZE, INTEGER *, char *,STRING_SIZE,
    INTEGER *, INTEGER *, INTEGER *, char *,STRING_SIZE);
#ifdef _STRLEN_AT_END
#define CALL_RSACCH(nomsd, numch, nomch, nbord, liord, nbcmp, liscmp) \
          F_FUNC(RSACCH,rsacch)(nomsd,numch,nomch,nbord,liord,nbcmp,liscmp, strlen(nomsd),16,8)
#else
#define CALL_RSACCH(nomsd, numch, nomch, nbord, liord, nbcmp, liscmp) \
          F_FUNC(RSACCH,rsacch)(nomsd,strlen(nomsd),numch, nomch,16,nbord, liord, nbcmp, liscmp,8)
#endif

/* routines interface MPI */
#define CALL_MPICHK(a,b) CALLPP(MPICHK,mpichk,a,b)
extern void DEFPP(MPICHK,mpichk,INTEGER *, INTEGER *);

#define CALL_MPICMW() CALL0(MPICMW,mpicmw)
extern void DEF0(MPICMW,mpicmw);

#define CALL_MPISTP(a) CALLP(MPISTP,mpistp,a)
extern void DEFP(MPISTP,mpistp,INTEGER *);

/* routines intrinseques fortran */
#define CALL_ABORTF() CALL0(ABORTF,abortf)
extern void DEF0(ABORTF,abortf);

/* routines de manipulation de la SD MATERIAU */
#define CALL_RCVALE(a,b,c,d,e,f,g,h,i,j) CALLSSPSPPSPPP(RCVALE,rcvale,a,b,c,d,e,f,g,h,i,j)
extern void DEFSSPSPPSPPP(RCVALE, rcvale, char *,STRING_SIZE, char *,STRING_SIZE, INTEGER *,
    char *,STRING_SIZE, DOUBLE *, INTEGER *, char *,STRING_SIZE, DOUBLE *, INTEGER *, INTEGER *);


/* routines d'impression des MESSAGES */
#define CALL_AFFICH(a,b) CALLSS(AFFICH,affich,a,b)
extern void DEFSS(AFFICH,affich,char *,STRING_SIZE,char *,STRING_SIZE);

#define CALL_U2MESS(cod, idmess) CALLSS(U2MESS, u2mess, cod, idmess)
extern void DEFSS(U2MESS, u2mess, char *, STRING_SIZE, char *, STRING_SIZE);

/* particulier car on fixe les longueurs des chaines valk */
#define VALK_SIZE 128
extern void DEFSSPSPPPP(U2MESG, u2mesg, char *, STRING_SIZE, char *, STRING_SIZE, INTEGER *,
    char *, STRING_SIZE, INTEGER *, INTEGER *, INTEGER *, DOUBLE *);
#ifdef _STRLEN_AT_END
#define CALL_U2MESG(cod, idmess, nk, valk, ni, vali, nr, valr) \
    F_FUNC(U2MESG, u2mesg)(cod, idmess, nk, valk, ni, vali, nr, valr, strlen(cod),
                           strlen(idmess), VALK_SIZE)
#else
#define CALL_U2MESG(cod, idmess, nk, valk, ni, vali, nr, valr) \
    F_FUNC(U2MESG, u2mesg)(cod, strlen(cod), idmess, strlen(idmess), nk, valk, VALK_SIZE,
                           ni, vali, nr, valr)
#endif


/* routines UTILITAIRES pour MED */
#define CALL_MDNOMA(a,b,c,d) CALLSPSP(MDNOMA,mdnoma,a,b,c,d)
extern void DEFSPSP(MDNOMA,mdnoma,char *,STRING_SIZE,INTEGER *,char *,STRING_SIZE,INTEGER *);

#define CALL_MDNOCH(a,b,c,d,e,f,g) CALLSPPSSSP(MDNOCH,mdnoch,a,b,c,d,e,f,g)
extern void DEFSPPSSSP(MDNOCH,mdnoch,char *,STRING_SIZE,INTEGER *,INTEGER *,char *,STRING_SIZE,
                       char *,STRING_SIZE,char *,STRING_SIZE,INTEGER *);


/* FIN ASTER_FORT_H */
#endif
