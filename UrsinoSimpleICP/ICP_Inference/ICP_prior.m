function x_prior = ICP_prior(Pa,G)
%function [Pic,Pc,Ca,Va,q] = ICPsimulator(delT,Pa,Pvs,I,Ro,kE,G,tau)
x_prior=zeros(8,1);
% Allocation
Pic = 0;       % Intracranial Pressure
Pc = 0;       % Capillary Pressure
Ca = 0;       % Arterial Compliance
Va  = 0;       % Arteriolar Blood Volume
q   = 0;       % Cerebral Blood Flow
sigma_Gx = 0;  % Autoregulation Equilibrium Compliance

% Parameters that won't be learned
Rpv = 1.24;
Rf = 2.38*1e3;
delCa1 = 0.75;
delCa2 = 0.075;
Can = 0.15;
kR = 4.91*1e4;
qn = 12.5;

% initialization
Ca = Can + .1* randn();    % for DBN, should be initialized according to a prior
Pic = 10 + 3*randn();   % for DBN, should be initialized according to a prior
Va = Ca*(Pa - Pic);
Ra = kR*Can^2/Va^2;
Pc = (Pa*Rpv + Pic*Ra)/(Rpv+Ra);
q = (Pa-Pc)/Ra;
x = (q - qn)/qn;
delCa = (x<=0)*delCa1 + (x>0)*delCa2;
k_sigma = delCa/4;
sigma_Gx = ( (Can+delCa/2)+(Can-delCa/2)*exp(G*x/k_sigma) )/(1+exp(G*x/k_sigma));
I = 0;
app_ICP=Pic;
x_prior(1)=Pic; 
x_prior(2)=Pc; 
x_prior(3)=Ca;
x_prior(4)=Va; 
x_prior(5)=q; 
x_prior(6)=sigma_Gx;
x_prior(7)=I;
x_prior(8)=app_ICP;
