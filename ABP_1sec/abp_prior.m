function x_prior = abp_prior()

x_prior=zeros(13,1);

prevState = 0;
truePulseBP = 50 + 10*randn();
trueMeanBP = 95 + 15*randn();    % eq 2
bagPressure = 230 + 40*randn(); 
zeroPressure = 0;    % eq 6
trueSystolicFraction =  0.33 + 0.04*randn();     % eq 3
trueDiaBP =  trueMeanBP - truePulseBP*trueSystolicFraction;     % eq 4
trueSysBP =  trueMeanBP + truePulseBP*(1-trueSystolicFraction); % eq 5

randState = 1000*rand();

if (randState < 6)
    s = 1;
    apparentMeanBP = bagPressure;
    apparentSysBP = bagPressure;
    apparentDiaBP = bagPressure;
elseif (randState == 6)
    s =-1;
    apparentMeanBP =zeroPressure;
    apparentSysBP = zeroPressure;
    apparentDiaBP = zeroPressure;

else
    s = 0; 
    apparentMeanBP= trueMeanBP;
    apparentSysBP = trueSysBP;
    apparentDiaBP = trueDiaBP;

end
    
timeInState = 0;

 x_prior(1)=truePulseBP; 
 x_prior(2)=trueMeanBP; 
 x_prior(3)=trueSystolicFraction;
 x_prior(4)=trueDiaBP; 
 x_prior(5)=trueSysBP; 
 x_prior(6)=zeroPressure;  
 x_prior(7)=bagPressure; 
 x_prior(8)=apparentDiaBP; 
 x_prior(9)=apparentMeanBP;
 x_prior(10)=apparentSysBP;
 x_prior(11)=prevState;
 x_prior(12)=timeInState;
 x_prior(13)=s;