*For Peaks Function HDMR surrogate embeded
OPTION optcr=1e-2;
OPTION optca=1e-2;
OPTION ITERLIM = 1e8;
OPTION ResLim = 1e8;
OPTION threads=8;
OPTION NLP = Baron;
$ontext
constraints£º
Input X£¬Output trying to find f(X)=Y, minimize the cost(loss) function
   e.g: x1,x2,x3,x4,x5  y      using HDMR
   f(x)=c + a(1,1)x1+a(2,1)x2+a(3,1)x3+...+a(1,2)x1^2+...+b(1,1,2,1)x1*x2 +..     x1*x2*x3    x1*x2  x1*x3  x2*x3

high dimensional modeling repesentation
   f(x)=c+sum((i,k),a(i,k)*power(x(i),k))+sum((i,ip,k,kp),b(i,ip,k,kp)*power(x(i),k)*power(x(ip),kp))

to get£ºc,a(i,k) and  b(i,ip,k,kp)

objective£º min (f(X)-Y)^2
            min|f(x)-Y|

x^2    a(1,2)=1, others a and b =0
$offtext

set
i 2 input          /i1*i2/
k adjust parameter /k1*k13/
n 3500 data set    /n1*n3500/
j 1 output         /j1/;

alias (i,ip);
alias (k,kp);

Parameter xo(n,i) original x value in the nth test;
$call GDXXRW.exe G:\project\ProjectIC\peaks\case1_train.xlsx trace=3 par=xo rng=xo!a1 rdim=1 cdim=1
$GDXIN case1_train.gdx
$LOAD xo
$GDXIN

Parameter y(n,j) y value in the nth test;
$call GDXXRW.exe G:\project\ProjectIC\peaks\case1_train.xlsx trace=3 par=y rng=y!a1 rdim=1 cdim=1
$GDXIN case1_train.gdx
$LOAD y
$GDXIN
display  xo, y;

parameters
minx(i) /i1 -3, i2  -3/
maxx(i) /i1 3,  i2   3/;

parameters  x(n,i) xo after scaling to [-1 1];
*x(n,i)=(xo(n,i)+maxx(i)-2*minx(i))/(maxx(i)-minx(i));
x(n,i) = ((xo(n,i)-minx(i))*2 / (maxx(i)-minx(i))) - 1 ;
*x(n,i) =  xo(n,i);
display x;
positive variables
ay(n)
by(n);

variables
a(i,k)        Exponential (a1 * x1**3) coefficient
b(i,ip,k,kp)  Bilinear term (b1* x1*x2) coefficient
obj           the loss function
yt(n,j)       y prediction
error(n,j)
c             constant term
;

equations
eq1(n)
*eq60(n),eq61(n)
*eq62(n),eq63(n)
eq2
eq3(n,j)
;

eq1(n)..   sum(j,yt(n,j)) =e= c + sum((i,k),a(i,k)*power(x(n,i),ord(k)))
                                + sum((i,ip,k,kp)$(ord(i)<ord(ip)),b(i,ip,k,kp)*power(x(n,i),ord(k))*power(x(n,ip),ord(kp)));

eq2..      obj =e= sum((n,j),power((yt(n,j)-y(n,j)),2))/3500;

eq3(n,j).. error(n,'j1') =e= yt(n,'j1')-y(n,'j1') ;
*max absolute error

*eq60(n)..      ay =g= y(n,'j1')-yt(n,'j1');
*eq61(n)..      by =g= yt(n,'j1')-y(n,'j1') ;
*eq62(n)..      ay(n)=l=0.05;
*eq63(n)..      by(n)=l=0.05;
*eq6..          obj =e= sum(n,ay(n)+by(n));
*eq6..          obj =e= ay;

model peaks /all/;
solve peaks using nlp minimizing obj;
display obj.l, c.l, a.l, b.l, yt.l, error.l;

*=== Export to Excel using GDX utilities
execute_unload "HDoutput.gdx" a.l, b.l, c.l, yt.l, obj.l, error.l;
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\ProjectIC\peaks\newhdpeaks\Output.xlsx var=a.l rng=a!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\ProjectIC\peaks\newhdpeaks\Output.xlsx var=b.l rng=b!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\ProjectIC\peaks\newhdpeaks\Output.xlsx var=c.l rng=c!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\ProjectIC\peaks\newhdpeaks\Output.xlsx var=yt.l rng=yt!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\ProjectIC\peaks\newhdpeaks\Output.xlsx var=obj.l rng=obj!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\ProjectIC\peaks\newhdpeaks\Output.xlsx var=error.l rng=error!';


*=== Now write to variable levels to Excel file from GDX
*=== Since we do not specify a sheet, data is placed in first sheet
*execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=c.L rng=c!'
*execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=a.L rng=a!'

*=== Write marginals to a different sheet with a specific range
*execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=b.L rng=b!'
*execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=yt.L rng=yt!'

$ontext
*scaling   for all X [1£¬2]

(minx+b)/a=1
(maxx+b)/a=2

a=maxx-minx;
b=maxx-2*minx;

x=(xo+maxx-2*minx)/(maxx-minx);
$offtext
