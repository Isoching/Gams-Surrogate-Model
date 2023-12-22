*For HDMR testing
*OPTION optcr=1e-1;
*OPTION optca=1e-1;
OPTION ITERLIM = 1e8;
OPTION ResLim = 1e8;
OPTION threads=8;
OPTION NLP = BARON;
*OPTION NLP = Antigone;
set
i input          /i1*i3/
*The Highest order
k adjust parameter (order) /k1*k13/
j output         /j1/
n test set       /n1*n750/
;
alias (i,ip);
alias (k,kp);

parameters
maxx(i) /i1 300, i2 80, i3 354/
minx(i) /i1 5, i2 5, i3 6/;

Parameter a(i,k) coefficient  ;
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

Parameters  xtt(n,i) xo after scaling to [0 1];
xtt(n,i) = (xt(n,i)-minx(i)) / (maxx(i)-minx(i));
Display xtt;

variables
xo(i)    original input x
x(i)     x after scaling to [0 1]
obj      to find the global maximum of productivity
FAME_prod(j)   prediction y
y_predicted(n)
test_loss
loss(n)
;

xo.up('i1') = 300; xo.lo('i1') = 5;
xo.up('i2') = 80; xo.lo('i2')  = 5;
xo.up('i3') = 354; xo.lo('i3') = 6;
x.lo(i)=0; x.up(i)=1;
*FAME_prod.lo(j) = -10;  FAME_prod.up(j) = 10;

equations
eq1(i)
eq2
eq3
eq5(n)
eq7
eq8(n)
;
eq1(i)..  x(i) =e= (xo(i)-minx(i))/(maxx(i)-minx(i));

eq2..  FAME_prod('j1') =e= c + sum((i,k),a(i,k)*power(x(i),ord(k)))
                      + sum((i,ip,k,kp)$(ord(i)<ord(ip)),b(i,ip,k,kp)*power(x(i),ord(k))*power(x(ip),ord(kp)));
*                      + sum(k,c(k)*power(x(n,'i1'),ord(k))*power(x(n,'i2'),ord(k))*power(x(n,'i3'),ord(k))) ;

eq3..  obj =e= sum(j,FAME_prod(j)) ;

eq5(n)..  y_predicted(n) =e= c + sum((i,k),a(i,k)*power(xtt(n,i),ord(k)))
                        + sum( (i,ip,k,kp)$(ord(i)<ord(ip)), b(i,ip,k,kp)*power(xtt(n,i),ord(k))*power(xtt(n,ip),ord(kp)) );

eq7..     test_loss =e= sum(n,power((yt(n,'j1')-y_predicted(n)),2))/750 ;
eq8(n)..  loss(n) =e= yt(n,'j1')-y_predicted(n)  ;

model BioReactor /all/;
solve BioReactor using nlp maximizing obj;
*solve BioReactor using nlp minimizing obj;
display obj.l, x.l, xo.l, loss.l, test_loss.l, y_predicted.l;

execute_unload "y_predicted.gdx" y_predicted.l;
execute 'gdxxrw.exe y_predicted.gdx o=G:\project\resultHD\HDMRtest\val13.xlsx var=y_predicted.l rng=y_predicted!';
execute_unload "loss.gdx" loss.l;
execute 'gdxxrw.exe loss.gdx o=G:\project\resultHD\HDMRtest\val13.xlsx var=loss.l rng=loss!';

$ontext$
eq4(nd)..  yd_predicted(nd) =e= c + sum((i,k),a(i,k)*power(xd(nd,i),ord(k)))
                        + sum((i,ip,k,kp)$(ord(i)<ord(ip)),b(i,ip,k,kp)*power(xd(nd,i),ord(k))*power(xd(nd,ip),ord(kp)));


eq6..     dev_loss =e= sum((nd,j),power((yd(nd)-yd_predicted(nd)),2))/750 ;


yd_predicted.lo(nd) = -100 ;  yd_predicted.up(nd) = 100 ;
yt_predicted.lo(nt) = -100 ;  yt_predicted.up(nt) = 100 ;

dev_loss
test_loss
yd_predicted(nd)

Parameter xd(nd,i) x for dev set;
*$call GDXXRW.exe G:\project\project5000.xlsx par=xd rng=xd!a1 rdim=1 cdim=1
*$GDXIN project5000.gdx
*$LOAD xd
*$GDXIN

Parameter yd(nd) y for dev set;
*$call GDXXRW.exe G:\project\project5000.xlsx par=yd rng=yd!a1 rdim=1 cdim=0
*$GDXIN project5000.gdx
*$LOAD yd
*$GDXIN

nd dev set       /nd1*nd750/
nt dev set       /nt1*nt750/
$offtext$
