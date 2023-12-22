*For HDMR testing
OPTION optcr=1e-4;
OPTION optca=1e-4;
OPTION ITERLIM = 1e8;
OPTION ResLim = 1e8;
OPTION threads=8;
*OPTION NLP = Baron;
OPTION NLP = Antigone;
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
i inputs                    /i1*i3/
k adjust parameter - orders /k1*k13/
n data set       /n1*n3500/
j output         /j1/;

alias (i,ip);
alias (k,kp);

Parameter xo(n,i) original x value in the nth test;
$call GDXXRW.exe G:\project\project5000.xlsx trace=3 par=xo rng=xo!A1:D3501 rdim=1 cdim=1
$GDXIN project5000.gdx
$LOAD xo
$GDXIN

Parameter y(n,j) y value in the nth test;
$call GDXXRW.exe G:\project\project5000.xlsx trace=3 par=y rng=y!A1:B3501 rdim=1 cdim=1
$GDXIN project5000.gdx
$LOAD y
$GDXIN
display  xo, y;

parameters maxx(i)
/i1 300, i2 80, i3 354/;
parameters minx(i)
/i1 5, i2 5, i3 6/;

parameters  x(n,i) xo after scaling to [0 1];
x(n,i)=(xo(n,i)-minx(i))/(maxx(i)-minx(i));
display x;
*positive variables
*ay(n)
*by(n);

variables
a(i,k)        Exponential (a1 * x1**3) coefficient
b(i,ip,k,kp)  Bilinear term (b1* x1*x2) coefficient
c             constant term
obj           the loss function
yt(n,j)       y prediction
error(n,j)    to find out the max absolute error
;

equations
eq1(n)
eq2
eq3(n,j)
;

eq1(n)..   yt(n,'j1') =e= c + sum((i,k),a(i,k)*power(x(n,i),ord(k)))
                            + sum((i,ip,k,kp)$(ord(i)<ord(ip)),  b(i,ip,k,kp)*power(x(n,i),ord(k))*power(x(n,ip),ord(kp)));
*                            + sum(k,d(k)*power(x(n,'i1'),ord(k))*power(x(n,'i2'),ord(k))*power(x(n,'i3'),ord(k))) ;

eq2..           obj =e= sum((n,j),power((yt(n,'j1')-y(n,'j1')),2))/3500 ;
eq3(n,j)..      error(n,'j1') =e= yt(n,'j1')-y(n,'j1') ;

*max absolute error
*eq60(n)..      ay =g= y(n,'j1')-yt(n,'j1');
*eq61(n)..      by =g= yt(n,'j1')-y(n,'j1') ;
*eq62(n)..      ay(n)=l=0.05;
*eq63(n)..      by(n)=l=0.05;
*eq6..          obj =e= sum(n,ay(n)+by(n));
*eq6..          obj =e= ay;

model BioReactor /all/;
solve BioReactor using nlp minmizing obj;
display obj.l, c.l, a.l, b.l, yt.l, error.l;

*=== Export to Excel using GDX utilities
execute_unload "HDoutput.gdx" a.l, b.l, c.l, yt.l, obj.l, error.l;
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\resultHD\Output.xlsx var=a.l rng=a!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\resultHD\Output.xlsx var=b.l rng=b!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\resultHD\Output.xlsx var=c.l rng=c!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\resultHD\Output.xlsx var=yt.l rng=yt!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\resultHD\Output.xlsx var=obj.l rng=obj!';
execute 'gdxxrw.exe HDoutput.gdx o=G:\project\resultHD\Output.xlsx var=error.l rng=error!';
