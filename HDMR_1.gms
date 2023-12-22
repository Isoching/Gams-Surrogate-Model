*For HDMR testing
option optcr=1e-4;
option optca=1e-4;
OPTION ITERLIM = 1000000000;
OPTION ResLim = 2000000000;
option threads=8;
$ontext
constraints£ºInput X£¬Output trying to find f(X)=Y, minimize the cost(loss) function
   e.g: x1,x2,x3,x4,x5  y      using HDMR
   f(x)=c+a(1,1)x1+a(2,1)x2+a(3,1)x3+...+a(1,2)x1^2+...+b(1,1,2,1)x1*x2 +..     x1*x2*x3    x1*x2  x1*x3  x2*x3

high dimensional modeling repesentation
   f(x)=c+sum((i,k),a(i,k)*power(x(i),k))+sum((i,ip,k,kp),b(i,ip,k,kp)*power(x(i),k)*power(x(ip),kp))

to get£ºc,a(i,k) and  b(i,ip,k,kp)

objective£º min (f(X)-Y)^2
            min|f(x)-Y|

x^2    a(1,2)=1, others a and b =0
$offtext

set
i 2 input     /i1*i2/
k adjust parameter /k1*k12/
n 500 data set    /n1*n2500/
j 1 output/j1/
;

alias (i,ip);
alias (k,kp);
parameters
xo(n,i)
y(n,j)
;

Parameter xo(n,i) original x value in the nth test;
$call GDXXRW.exe C:\Users\curry\Desktop\peak.xlsx trace=3 par=xo rng=xo!a1 rdim=1 cdim=1
$GDXIN peak.gdx
$LOAD xo
$GDXIN
display  xo;

Parameter y(n,j) y value in the nth test;
$call GDXXRW.exe C:\Users\curry\Desktop\peak.xlsx trace=3 par=y rng=y!a1 rdim=1 cdim=1
$GDXIN peak.gdx
$LOAD y
$GDXIN
display  y;

$ontext
*scaling   for all X [1£¬2]

(minx+b)/a=1
(maxx+b)/a=2

a=maxx-minx;
b=maxx-2*minx;

x=(xo+maxx-2*minx)/(maxx-minx);
$offtext


parameters minx(i)
/i1 -3, i2  -3/;
parameters maxx(i)
/i1 3, i2 3/;

parameters  x(n,i) xo after scaling to [-1 1];
*x(n,i)=(xo(n,i)+maxx(i)-2*minx(i))/(maxx(i)-minx(i));
x(n,i) = ((xo(n,i)-minx(i))*2 / (maxx(i)-minx(i))) - 1 ;
display x;

*positive variables
*ay(n)
*by(n);

variables
a(i,k)
b(i,ip,k,kp)
obj        the loss function
yt(n,j)    y prediction
c          constant term  ;

equations
eq1(n)
*eq2,eq3(n),eq4(n),eq5(n)
eq6
;

eq1(n).. yt(n,'j1')=e=c+sum((i,k),a(i,k)*power(x(n,i),ord(k)))
                       +sum((i,ip,k,kp)$(ord(i)<ord(ip)),b(i,ip,k,kp)*power(x(n,i),ord(k))*power(x(n,ip),ord(kp)));

eq6..      obj =e= sum(n,power((yt(n,'j1')-y(n,'j1')),2))/2500;
*eq2(n)..      ay(n)=g= (y(n,'j1')-yt(n,'j1'))/y(n,'j1') ;
*eq3(n)..      by(n)=g= (yt(n,'j1')-y(n,'j1'))/y(n,'j1') ;
*eq4(n)$(ord(n)<2501)..      ay(n)=l=0.05;
*eq5(n)$(ord(n)<2501)..      by(n)=l=0.05;
*eq6..        obj=e=sum(n$(ord(n)<2501),ay(n)+by(n));

OPTION NLP = BARON;
OPTION LP = BARON;
model case1 /all/;
solve case1 using nlp min obj;
display c.l, a.l, b.l, obj.l, yt.l;

*=== Export to Excel using GDX utilities

*=== First unload to GDX file (occurs during execution phase)
execute_unload "case1y.gdx" a.l, b.l, c.l,  yt.l


*=== Now write to variable levels to Excel file from GDX
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=c.L rng=c!'
execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=a.L rng=a!'


*=== Write marginals to a different sheet with a specific range
execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=b.L rng=b!'
execute 'gdxxrw.exe case1y.gdx o=case1y.xlsx var=yt.L rng=yt!'

