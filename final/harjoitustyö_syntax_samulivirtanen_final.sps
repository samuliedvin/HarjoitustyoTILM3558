* Encoding: UTF-8.
DATASET ACTIVATE DataSet1.
USE ALL.

* Valitaan datasta 600 random muuttujaa.

do if $casenum=1.
compute #s_$_1=600.
compute #s_$_2=2199.
end if.
do if  #s_$_2 > 0.
compute filter_$=uniform(1)* #s_$_2 < #s_$_1.
compute #s_$_1=#s_$_1 - filter_$.
compute #s_$_2=#s_$_2 - 1.
else.
compute filter_$=0.
end if.
VARIABLE LABELS filter_$ '600 from the first 2199 cases (SAMPLE)'.
FORMATS filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.

* Jaetaan data sukupuolen perusteella normaalijakaumatestausta varten

SORT CASES  BY supu.
SPLIT FILE SEPARATE BY supu.

* Tehdään kuviot ja taulukot

EXAMINE VARIABLES=pala BY ahtas
  /PLOT BOXPLOT NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* jako pois, ei tarvita enää.

SPLIT FILE OFF.

* Tehdään unianova

UNIANOVA pala BY supu ahtas
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(ahtas*supu)
  /PRINT=DESCRIPTIVE HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /DESIGN=supu ahtas supu*ahtas.

 * Katsotaan vielä monivertailut estimoiduista keskiarvoista (sidak)

UNIANOVA pala BY supu ahtas
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /PLOT=PROFILE(ahtas*supu)
  /EMMEANS=TABLES(supu) COMPARE ADJ(SIDAK)
  /EMMEANS=TABLES(ahtas) COMPARE ADJ(SIDAK)
  /EMMEANS=TABLES(supu*ahtas) 
  /PRINT=ETASQ DESCRIPTIVE HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /DESIGN=supu ahtas supu*ahtas.

* REGRESSIOANALYYSI

* Tutkitaan sirontakuvioita sekä selittävien että selitettävän muuttujan välillä 

GRAPH
  /SCATTERPLOT(MATRIX)=rkyks asmenot alaika pala
  /MISSING=LISTWISE.

* Lasketaan korrelaatiokertoimia.

CORRELATIONS
  /VARIABLES=alaika asmenot rkyks pala
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.
NONPAR CORR
  /VARIABLES=alaika asmenot rkyks pala
  /PRINT=SPEARMAN TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* Lasketaan lineaarinen malli

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pala
  /METHOD=ENTER alaika asmenot rkyks
  /SAVE ZRESID.

* Tästä välistä puuttuu nyt 1.3. tehtävän syntaksi (ei ole ajettu!)

* KATSO LÄPI MYÖHEMMIN

* Eli normaalijakauma testaus


SET SEED=511178.

DATASET ACTIVATE DataSet2.
USE ALL.
do if $casenum=1.
compute #s_$_1=700.
compute #s_$_2=1299.
end if.
do if  #s_$_2 > 0.
compute filter_$=uniform(1)* #s_$_2 < #s_$_1.
compute #s_$_1=#s_$_1 - filter_$.
compute #s_$_2=#s_$_2 - 1.
else.
compute filter_$=0.
end if.
VARIABLE LABELS filter_$ '700 from the first 1299 cases (SAMPLE)'.
FORMATS filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.

EXAMINE VARIABLES=Functional_M2 Functional_M1 BY D2
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

NPAR TESTS
  /FRIEDMAN=Functional_M1 Functional_M2
  /MISSING LISTWISE.

NPAR TESTS
  /WILCOXON=Functional_M1 WITH Functional_M2 (PAIRED)
  /MISSING ANALYSIS.

GLM Functional_M1 Functional_M2 BY D2 
  /WSFACTOR=mittaus 2 Polynomial 
  /METHOD=SSTYPE(3) 
  /PLOT=PROFILE(mittaus*D2) 
  /EMMEANS=TABLES(mittaus) 
  /PRINT=DESCRIPTIVE 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=mittaus 
  /DESIGN=D2.


* 2.1.

SET SEED=511178.


DATASET ACTIVATE DataSet1.
USE ALL.
do if $casenum=1.
compute #s_$_1=800.
compute #s_$_2=1318.
end if.
do if  #s_$_2 > 0.
compute filter_$=uniform(1)* #s_$_2 < #s_$_1.
compute #s_$_1=#s_$_1 - filter_$.
compute #s_$_2=#s_$_2 - 1.
else.
compute filter_$=0.
end if.
VARIABLE LABELS filter_$ '800 from the first 1318 cases (SAMPLE)'.
FORMATS filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.

FREQUENCIES VARIABLES=d2 k23 d32
  /ORDER=ANALYSIS.



CROSSTABS
  /TABLES=d32 BY k23 BY d2
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT
  /COUNT ROUND CELL.



HILOGLINEAR d2(1 2) d32(1 2) k23(0 1) 
  /METHOD=BACKWARD
  /CRITERIA MAXSTEPS(10) P(.05) ITERATION(20) DELTA(.5)
  /PRINT=FREQ RESID
  /DESIGN.

DATASET ACTIVATE DataSet1.
CROSSTABS
  /TABLES=d2 BY k23
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ 
  /CELLS=COUNT ROW SRESID 
  /COUNT ROUND CELL.


*2.2. Logistinen regressiomalli

LOGISTIC REGRESSION VARIABLES d32
  /METHOD=ENTER d2 ika 
  /CONTRAST (d2)=Simple
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).

LOGISTIC REGRESSION VARIABLES d32
  /METHOD=ENTER d2 ika 
  /CONTRAST (d2)=Simple
  /PRINT=GOODFIT CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).


**********************************
*
* 3. MONIMUUTTUJAMENETELMÄT
*
**********************************


SET SEED=511178.

DATASET ACTIVATE DataSet1.
USE ALL.
do if $casenum=1.
compute #s_$_1=1200.
compute #s_$_2=2453.
end if.
do if  #s_$_2 > 0.
compute filter_$=uniform(1)* #s_$_2 < #s_$_1.
compute #s_$_1=#s_$_1 - filter_$.
compute #s_$_2=#s_$_2 - 1.
else.
compute filter_$=0.
end if.
VARIABLE LABELS filter_$ '1200 from the first 2453 cases (SAMPLE)'.
FORMATS filter_$ (f1.0).
FILTER  BY filter_$.
EXECUTE.

***********************
* Muuttujien ryhmittely
***********************

*1. Muodosta pääkomponenttianalyysilla luokitelluista muuttujista (41 kpl : autom_lainan_perinta_luok - kulutusluotot1_luok) pääkomponentteja ominaisarvokriteerin mukaan. ( Promax-rotaatio)



FACTOR
  /VARIABLES autom_lainan_perinta_luok lainojen_lukumaara_luok asuntoluotot1_luok 
    automaattinostoja_luok vakuutus_a_luok asuntolaina_a_kpl_luok asuntolaina_b_kpl_luok 
    vakuutus_b_luok vakuutus_c_luok korkeakork_kpl_luok rahasto_a1_luok pankkikorttilkm_luok 
    luottokortteja_yhteensa_luok maaraaikaistileja_luok maksuautomaattitapahtumia_luok 
    kayttotili_tal_luok kayttotili_vel_luok asuntolaina_c_kpl_luok osakkeet_euroa_1_luok 
    eri_osakesarjoja_luok rahasto_b1_luok ottoja_luok pkorttimaksuja_luok panoja_luok 
    asuntolaina_d_kpl_luok palveluja_kpl_luok rahastolajeja_luok lainarastit_luok saastotililla_luok 
    asuntolaina_e_kpl_luok suoraveloituksia_luok netissa_maksut_luok maksupalvelussa_maksut_luok 
    tiskilla_maksut_luok tilinylityspaivat_luok toimeksianto_a_kpl_luok kv_maksukortit_luok 
    rahasto_c1_luok korttiluotot1_luok kulutusluotot1_luok
  /MISSING LISTWISE 
  /ANALYSIS autom_lainan_perinta_luok lainojen_lukumaara_luok asuntoluotot1_luok 
    automaattinostoja_luok vakuutus_a_luok asuntolaina_a_kpl_luok asuntolaina_b_kpl_luok 
    vakuutus_b_luok vakuutus_c_luok korkeakork_kpl_luok rahasto_a1_luok pankkikorttilkm_luok 
    luottokortteja_yhteensa_luok maaraaikaistileja_luok maksuautomaattitapahtumia_luok 
    kayttotili_tal_luok kayttotili_vel_luok asuntolaina_c_kpl_luok osakkeet_euroa_1_luok 
    eri_osakesarjoja_luok rahasto_b1_luok ottoja_luok pkorttimaksuja_luok panoja_luok 
    asuntolaina_d_kpl_luok palveluja_kpl_luok rahastolajeja_luok lainarastit_luok saastotililla_luok 
    asuntolaina_e_kpl_luok suoraveloituksia_luok netissa_maksut_luok maksupalvelussa_maksut_luok 
    tiskilla_maksut_luok tilinylityspaivat_luok toimeksianto_a_kpl_luok kv_maksukortit_luok 
    rahasto_c1_luok korttiluotot1_luok kulutusluotot1_luok
  /PRINT INITIAL SIG KMO AIC EXTRACTION ROTATION
  /FORMAT SORT
  /CRITERIA MINEIGEN(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION PROMAX(4)
  /SAVE REG(ALL)
  /METHOD=CORRELATION.

*************
* 3.2. Havaintojen ryhmittely

* 3.2.1. Käytä näitä uusia muuttujia klusterianalyysissä, jossa muodostat asiakasryhmiä K-means menetelmällä lähtien kahdesta klusterista viiteen tai kuuteen klusteriin saakka. Kuvaile muodostamiasi ryhmiä.
*************



QUICK CLUSTER FAC1_1 FAC2_1 FAC3_1 FAC4_1 FAC5_1 FAC6_1 FAC7_1 FAC8_1 FAC9_1 FAC10_1 FAC11_1 
    FAC12_1 FAC13_1 FAC14_1
  /MISSING=LISTWISE
  /CRITERIA=CLUSTER(2) MXITER(10) CONVERGE(0)
  /METHOD=KMEANS(NOUPDATE)
  /SAVE CLUSTER
  /PRINT INITIAL.

QUICK CLUSTER FAC1_1 FAC2_1 FAC3_1 FAC4_1 FAC5_1 FAC6_1 FAC7_1 FAC8_1 FAC9_1 FAC10_1 FAC11_1 
    FAC12_1 FAC13_1 FAC14_1
  /MISSING=LISTWISE
  /CRITERIA=CLUSTER(3) MXITER(10) CONVERGE(0)
  /METHOD=KMEANS(NOUPDATE)
  /SAVE CLUSTER
  /PRINT INITIAL.

QUICK CLUSTER FAC1_1 FAC2_1 FAC3_1 FAC4_1 FAC5_1 FAC6_1 FAC7_1 FAC8_1 FAC9_1 FAC10_1 FAC11_1 
    FAC12_1 FAC13_1 FAC14_1
  /MISSING=LISTWISE
  /CRITERIA=CLUSTER(4) MXITER(10) CONVERGE(0)
  /METHOD=KMEANS(NOUPDATE)
  /SAVE CLUSTER
  /PRINT INITIAL.

QUICK CLUSTER FAC1_1 FAC2_1 FAC3_1 FAC4_1 FAC5_1 FAC6_1 FAC7_1 FAC8_1 FAC9_1 FAC10_1 FAC11_1 
    FAC12_1 FAC13_1 FAC14_1
  /MISSING=LISTWISE
  /CRITERIA=CLUSTER(5) MXITER(10) CONVERGE(0)
  /METHOD=KMEANS(NOUPDATE)
  /SAVE CLUSTER
  /PRINT INITIAL.

