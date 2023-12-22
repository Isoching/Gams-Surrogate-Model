*For HDMR testing
OPTION optcr=1e-4;
OPTION optca=1e-4;
OPTION ITERLIM = 1e8;
OPTION ResLim = 1e8;
OPTION threads=8;
OPTION NLP = BARON;
set
i 2 input     /i1*i3/
*The Highest order
k adjust parameter /k1*k2/
j 1 output    /j1/
n test set    /n1*n750/
;

alias (i,ip);
alias (k,kp);

Parameter a(i,k) coefficient ;
$call GDXXRW.exe G:\project\resultHD\Output.xlsx par=a rng=a!a1 rdim=1 cdim=1
$GDXIN Output.gdx
$LOAD a
$GDXIN

Parameter b(i,ip,k,kp) coefficient ;
$call GDXXRW.exe G:\project\resultHD\Output.xlsx par=b rng=b!a1 rdim=3 cdim=1
$GDXIN Output.gdx
$LOAD b
$GDXIN

Scalar c ;
$call GDXXRW.exe G:\project\resultHD\Output.xlsx par=c rng=c!a1 rdim=0 cdim=0
$GDXIN Output.gdx
$LOAD c
$GDXIN
Display a,b,c;

variables
test_loss
y_predicted(n,j)
loss(n)
;
Parameter xt(n,i) x for test set;
$call GDXXRW.exe G:\project\project5000.xlsx par=xt rng=xt!a1 rdim=1 cdim=1
$GDXIN project5000.gdx
$LOAD xt
$GDXIN

Parameter yt(n,j) y for test set;
$call GDXXRW.exe G:\project\project5000.xlsx par=yt rng=yt!a1 rdim=1 cdim=1
$GDXIN project5000.gdx
$LOAD yt
$GDXIN
Display xt,yt;

equations
eq1(n,j)
eq2
eq3(n)
;
eq1(n,j)..   y_predicted(n,j) =e= c + sum((i,k),a(i,k)*power(xt(n,i),ord(k)))
                            + sum((i,ip,k,kp)$(ord(i)<ord(ip)),b(i,ip,k,kp)*power(xt(n,i),ord(k))*power(xt(n,ip),ord(kp)));

eq2..        test_loss =e= sum((n,j),power((y_predicted(n,j) - yt(n,j)),2)) / 750  ;
eq3(n)..     loss(n) =e= sum(j,power((y_predicted(n,j) - yt(n,j)),2))  ;

model BioReactor /all/;
solve BioReactor using nlp minimizing test_loss;
display test_loss.l, loss.l, y_predicted.l, yt

execute_unload "y_predicted.gdx" y_predicted.l;
execute 'gdxxrw.exe yt.gdx o=G:\project\HDMRtest\val2.xlsx var=y_predicted.l rng=y_predicted!';
execute_unload "loss.gdx" loss.l;
execute 'gdxxrw.exe loss.gdx o=G:\project\HDMRtest\val2.xlsx var=loss.l rng=loss!';

$ontext$
Parameter xo(n,i) original x value in the nth test;
*$call GDXXRW.exe D:\peaks\case1_test.xlsx trace=3 par=xo rng=xo!a1 rdim=1 cdim=1
*$GDXIN case1_test.gdx
*$LOAD xo
*$GDXIN

Parameter y(n,j) y value in the nth test;
*$call GDXXRW.exe D:\peaks\case1_test.xlsx trace=3 par=y rng=y!a1 rdim=1 cdim=1
*$GDXIN case1_test.gdx
*$LOAD y
*$GDXIN
display  xo, y;
$offtext
