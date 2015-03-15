clear
close all
clc
%% Reproducing simulation results of Ursino
% in his paper title "A simple mathematical model of the interaction
% between intracranial pressure and cerebral hemodynamics (1997)
% 1-sec model (fs = 1Hz)
delT = 1; % 1-sec sampling period
%% Injection
T = 2000;
% Input Signals
Pa  = 100*ones(1,T);    % Arterial Blood Pressure
Pvs = 6*ones(1,T);      % Constant Central Venous Pressure
I   = zeros(1,T);       % Injection
I(500:507) = 0.66;      % Injecting at a rate of 0.66ml/sec for 8 seconds
% Parameters
Ro = 526.3; kE = 0.11; tau = 20; G = 1.5;
[Pic,Pc,Ca,~,q] = ICPsimulator(delT,Pa,Pvs,I,Ro,kE,G,tau);
visualize(delT,Pic,Pc,q,Ca)

%% Plateau Waves
T = 5000;
% Input Signals
Pa  = 100*ones(1,T);    % Arterial Blood Pressure
Pvs = 6*ones(1,T);      % Constant Central Venous Pressure
I   = zeros(1,T);       % Injection
% Parameters
Ro = 526.3*12; kE = 2.1*0.11; tau = 20; G = 1.5;
[Pic,Pc,Ca,~,q] = ICPsimulator(delT,Pa,Pvs,I,Ro,kE,G,tau);
visualize(delT,Pic,Pc,q,Ca)

%% CBF vs SAP curve
T = 5000;
% Parameters
Ro = 526.3; kE = 0.11; tau = 20; G = 1.5;
ABPs=10:200; L = length(ABPs);
qs = zeros(1,L); Vas = zeros(1,L);
reverseStr = [];
for i=1:L;
    reverseStr = displayprogress(i/L*100,reverseStr);
    ABP = ABPs(i);
    Pa = ABP*ones(1,T);     % Arterial Blood Pressure
    Pvs = 6*ones(1,T);      % Constant Central Venous Pressure
    I   = zeros(1,T);       % Injection
    [Pic,Pc,Ca,Va,q] = ICPsimulator(delT,Pa,Pvs,I,Ro,kE,G,tau);
    qs(i) = q(end);
    Vas(i) = Va(end);
end
h2=figure(11);
set(h2,'Position',[100 100 1000 500]);
subplot(1,2,1);
plot(ABPs,qs)
xlabel('Arterial Blood Pressure (mmHg)')
ylabel('Cerebral Blood Flow (ml/sec)')
subplot(1,2,2);
plot(ABPs,Vas)
xlabel('Arterial Blood Pressure (mmHg)')
ylabel('Arteriolar Blood Volume (ml)')