function [Pic,Pc,Ca,Va,q] = ICPsimulator(delT,Pa,Pvs,I,Ro,kE,G,tau)
T = length(Pa);
% Allocation
Pic = zeros(1,T);       % Intracranial Pressure
Pc  = zeros(1,T);       % Capillary Pressure
Ca  = zeros(1,T);       % Arterial Compliance
Va  = zeros(1,T);       % Arteriolar Blood Volume
q   = zeros(1,T);       % Cerebral Blood Flow

% Parameters that won't be learned
Rpv = 1.24;
Rf = 2.38*1e3;
delCa1 = 0.75;
delCa2 = 0.075;
Can = 0.15;
kR = 4.91*1e4;
qn = 12.5;

% initialization
t = 1;
Ca(t) = Can;
Pic(t) = 9.5;
Va(t) = Ca(t)*(Pa(t) - Pic(t));
Ra = kR*Can^2/Va(t)^2;
Pc(t) = (Pa(t)*Rpv + Pic(t)*Ra)/(Rpv+Ra);
q(t) = (Pa(t)-Pc(t))/Ra;
x = (q(t) - qn)/qn;
delCa = (x<=0)*delCa1 + (x>0)*delCa2;
k_sigma = delCa/4;
sigma_Gx = ( (Can+delCa/2)+(Can-delCa/2)*exp(G*x/k_sigma) )/(1+exp(G*x/k_sigma));

% Dynamics
for t=2:T;
    Ca(t) = delT/tau*(Ca(t-1)*(tau/delT-1)+sigma_Gx);
    Pic(t) = delT*kE*Pic(t-1)/(1+Ca(t-1)*kE*Pic(t-1))*...
        (   Ca(t-1)*(Pa(t)-Pa(t-1))/delT + ...
        (Ca(t)-Ca(t-1))/delT*(Pa(t-1)-Pic(t-1)) + ...
        (Pc(t-1)-Pic(t-1))/Rf - ...
        (Pic(t-1)-Pvs(t-1))/Ro + I(t-1) ) + Pic(t-1);
    
    Va(t) = Ca(t)*(Pa(t) - Pic(t));
    Ra = (kR*Can^2)/(Va(t)^2);
    Pc(t) = (Pa(t)*Rpv + Pic(t)*Ra)/(Rpv+Ra);
    q(t) = (Pa(t)-Pc(t))/Ra;
    x = (q(t) - qn)/qn;
    delCa = (x<=0)*delCa1 + (x>0)*delCa2;
    k_sigma = delCa/4;
    sigma_Gx = ( (Can+delCa/2)+(Can-delCa/2)*exp(G*x/k_sigma) )/(1+exp(G*x/k_sigma));  
end