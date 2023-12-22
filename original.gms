option optcr = 0.001;
option optca = 0.001;
OPTION ResLim = 1000000;

VARIABLE
x1,x2,obj;
x1.lo = -3; x1.up = 3;
x2.lo = -3; x2.up = 3;
EQUATIONS
eq1;
*eq1.. obj =e= (3*(1-x1)**2)*exp(-x1*x1-(x2+1)**2)
*            -  10*(x1/5-x1**3-x2**5)*exp(-x1**2-x2**2)
*            - exp(-(x1+1)**2-x2**2)/3 ;
eq1.. obj =e= (3*(1-x1)**2)*exp(-x1*x1-(x2+1)*(x2+1))
            -  10*(x1/5-x1**3-x2*x2*x2*x2*x2)*exp(-x1**2-x2*x2)
            - exp(-(x1+1)**2-x2*x2)/3 ;
*k=4
*x1.fx = 0.118; x2.fx = -0.646;
*k=9
*x1.fx = 0.264; x2.fx = -1.699;
*k=7
*x1.fx = 0.305; x2.fx = -1.854;
*k=11
*x1.fx = 0.235; x2.fx = -1.677;
*k=13
*x1.fx = 0.222; x2.fx = -1.666;
*k=15
*x1.fx = 0.227; x2.fx = -1.633;
*k=17
x1.fx = 0.23; x2.fx = -1.622;

MODEL optimization for /all/;
*OPTION NLP = BARON;
SOLVE optimization using NLP minimizing obj ;
DISPLAY x1.l, x2.l, obj.l
*execute_unload 'coursework.gdx', i, z, x;
