function signals = ursino_simulator_hf(mode,autoreg,elasticity)
% Yusuf Bugra Erol
% mode = {normal, hypotension, hyperventilation}
% autoreg: determines the strength of autoregulation, range:[0,1]
% elasticity: kE parameter of Ursino, normal value 0.458

% It takes ~30 sec on my 2GHz Intel i7, 4GB RAM laptop.
% to run:
% arguments :
%   1st argument: pathophysiological state : {normal, hypotension, hyperventilation, jugular compression, drainage} 
%   2nd argument: state of autoregulation, 1 for intact and 0 for no autoregulation, can be any value in the range of 0 to 1 (i.e. the strength of autoregulation) 
%   3rd argument: elasticity parameter (kE), (original value: 0.458) , compliance is 1/(kE*ICP) can take values in the range of 0.1-0.5 maybe up to 0.6
% 1) normal run
%   signals = ursino_simulator_hf('normal',1,0.458)
% 2) hypotension simulation
%   signals = ursino_simulator_hf('hypotension',1,0.458)
% to see the effect of intactness of autoregulation on cerebral blood flow during hypotension compare against signals = ursino_simulator_hf('hypotension',0,0.458)
% 3) hyperventilation simulation
%   signals = ursino_simulator_hf('hyperventilation',1,0.458)
% 4) jugular compression simulation
%   signals = ursino_simulator_hf('jugularcompression',1,0.458)
% to see the effect of elasticity during jugular compression test compare against signals = ursino_simulator_hf('jugularcompression',1,0.3)
% 5) drainage simulation
%   ursino_simulator_hf('drainage',1,0.458)
%% settings
fs = 125; % sampling rate (Hz)
delT = 1/fs; % Sampling Period (sec)
T=200000; % Corresponds to T*delT seconds worth simulation
timescale = (1:T)*delT; % in seconds

if( strcmp(mode,'normal') )
    ABP=100+20*sin(2*pi*(1:T)/125); % Constant ABP
    CO2=40*ones(1,T); % Constant Co2
    CVP=5.5+2.5*sin(2*pi*(1:T)/125)+0.1*sin(2*pi*0.2*(1:T)/125); % one sine oscillating with cardiac rate, one oscillating with respiratory rate
    jglr=ones(1,T);
    injection=zeros(1,T);
elseif( strcmp(mode,'hypotension') )
    ABP=[100+20*sin(2*pi*(1:100000)/125) 60+40*exp(-0.05*(0:29999)/125)+20*sin(2*pi*(1:30000)/125) 100-40*exp(-0.05*(0:19999)/125)+20*sin(2*pi*(1:20000)/125) 100+20*sin(2*pi*(1:50000)/125)];
    CO2=40*ones(1,T); % Constant Co2
    CVP=5.5+2.5*sin(2*pi*(1:T)/125)+0.1*sin(2*pi*0.2*(1:T)/125);
    jglr=ones(1,T);
    injection=zeros(1,T);
elseif( strcmp(mode,'hyperventilation') )
    ABP=100+20*sin(2*pi*(1:T)/125); % Constant ABP
    CO2=[40*ones(1,80000) 30+10*exp(-0.5*(1:20000)/125) 40-10*exp(-0.5*(1:20001)/125) 40*ones(1,80000)]; %decrease Co2
    CVP=5.5+2.5*sin(2*pi*(1:T)/125)+0.1*sin(2*pi*0.2*(1:T)/125);
    jglr=ones(1,T);
    injection=zeros(1,T);
elseif( strcmp(mode,'jugularcompression') )
    ABP=100+20*sin(2*pi*(1:T)/125); % Constant ABP
    CO2=40*ones(1,T); % Constant Co2
    CVP=5.5+2.5*sin(2*pi*(1:T)/125)+0.1*sin(2*pi*0.2*(1:T)/125);
    jglr=[ones(1,50000) 0.5*ones(1,50000) ones(1,100000)]; % compress, i.e. reduce conductance
    injection=zeros(1,T);
elseif( strcmp(mode,'drainage') )
    ABP=100+20*sin(2*pi*(1:T)/125); % Constant ABP
    CO2=40*ones(1,T); % Constant Co2
    CVP=5.5+2.5*sin(2*pi*(1:T)/125)+0.1*sin(2*pi*0.2*(1:T)/125); % one sine oscillating with cardiac rate, one oscillating with respiratory rate
    jglr=ones(1,T);
    RoI=0.006; injection=[zeros(1,50000) -RoI*ones(1,30000) zeros(1,120000)];
else
    error(strcat('a simulation named:',mode,' is not available'))
end

%% Memory Allocation
Pa=zeros(1,T); Pic=zeros(1,T); P1=zeros(1,T); P2=zeros(1,T); Pc=zeros(1,T);
Pv=zeros(1,T); Pvs=zeros(1,T); r=zeros(1,T); g1=zeros(1,T);
cic=zeros(1,T); q=zeros(1,T); mu=zeros(1,T); muf=zeros(1,T); mu0=zeros(1,T);
CSF_rate=zeros(1,T); CSF=zeros(1,T);
%% Constant Variables
gamma=2/126; gamma1=2/10000;
Ca=2.34/2; Cve=2.34; Ga=15; Gve_baseline=6.25; Gpv=1.136;
Gvsp=2.77; kE=elasticity; kV=0.31; Pv1=-2.5; G0=0.0019; Gf=0.42e-3;
Tau1=10; Tau2=9; Ka1=3.68; Ka2=3.68; Kr1=0.00707;
rmax= 1.85*0.15; rmin= 0.075; CO2norm=40; alpha=1385;lambda=0.013;l02=0.9;
Reivich_n=(85.55+904400*exp(-5.251*log10(CO2norm)))/(113.8+221300*exp(-5.251*log10(CO2norm)));
%% Dynamics
%Initial Conditions:
Pa(1)=100;Pic(1)=11;P1(1)=85;P2(1)=47.5;Pc(1)=25;Pv(1)=14;Pvs(1)=6.5;r(1)=0.21;mu(1)=0;muf(1)=0.004/Gf;mu0(1)=0.004/G0;CSF(1)=125;
reverseStr = []; fprintf('simulation progress: ');
for i=1:T-1;
    reverseStr = displayprogress(i/T*100, reverseStr);
    G1=(r(i))^4/Kr1; g1(i)=G1; G2=G1/2; G3=G1*G2/(G1+G2);
    Laplace=1.9/(2*pi)*alpha*lambda*l02/(1/(2*pi)*(Pa(i)-(P1(i)+P2(i))/2)+alpha*lambda);
    
    Cic=1/(kE*Pic(i)); cic(i)=Cic;
    C1=1/(Ka1*(P1(i)-Pic(i)));
    C2=1/(Ka2*(P2(i)-Pic(i)));
    
    Cvi=1/(kV*(Pv(i)-Pic(i)-Pv1));
    Gvs=Gvsp*(Pv(i)-Pic(i))/(Pv(i)-Pvs(i));
    Gve=Gve_baseline*jglr(i);
    
    if( P2(i)*2*G2/(2*G2+Gpv) + Pv(i)*Gpv/(2*G2+Gpv) < Pic(i) )
        Pc(i)= P2(i)*2*G2/(2*G2+Gpv) + Pv(i)*Gpv/(2*G2+Gpv);
    elseif (P2(i)*2*G2/(2*G2+Gpv+Gf) + Pv(i)*Gpv/(2*G2+Gpv+Gf)+ Pic(i)*Gf/(2*G2+Gpv+Gf)>Pic(i))
        Pc(i)= P2(i)*2*G2/(2*G2+Gpv+Gf) + Pv(i)*Gpv/(2*G2+Gpv+Gf)+ Pic(i)*Gf/(2*G2+Gpv+Gf);
    end
    
    Pa(i+1)=delT*((Ga/Ca)*ABP(i) + ((-Ga-2*G1)/Ca+1/delT)*Pa(i) + ((2*G1)/Ca)*P1(i));
    Pic(i+1)=delT*(injection(i)/Cic + Pa(i)*(2*G1)/Cic + P1(i)*(-2*G1)/Cic + P2(i)*(-2*G2)/Cic + Pc(i)*(2*G2+Gpv)/Cic + 1/delT*Pic(i) + Pv(i)*(-Gpv-Gvs)/Cic + Pvs(i)*(Gvs/Cic) + ret_pos(muf(i))*(Gf/Cic) + ret_pos(mu0(i))*(-G0)/Cic);
    P1(i+1)=delT*(Pa(i)*(2*G1/C1+2*G1/Cic) + P1(i)*((-2*G3-2*G1)/C1-2*G1/Cic+1/delT) + P2(i)*(-2*G2/Cic+2*G3/C1) + Pc(i)*(2*G2+Gpv)/Cic + Pv(i)*(-Gpv-Gvs)/Cic + Pvs(i)*(Gvs/Cic) + ret_pos(muf(i))*(Gf/Cic) + ret_pos(mu0(i))*(-G0)/Cic);
    P2(i+1)=delT*(Pa(i)*2*G1/Cic + P1(i)*(2*G3/C2-2*G1/Cic) + P2(i)*((-2*G3-2*G2)/C2-2*G2/Cic+1/delT) + Pc(i)*(2*G2/C2+(2*G2+Gpv)/Cic) + Pv(i)*(-Gpv-Gvs)/Cic + Pvs(i)*(Gvs/Cic) + ret_pos(muf(i))*(Gf/Cic) + ret_pos(mu0(i))*(-G0)/Cic);
    Pv(i+1)=delT*(Pa(i)*(2*G1)/Cic + P1(i)*(-2*G1)/Cic + P2(i)*(-2*G2)/Cic + Pc(i)*(Gpv/Cvi+(2*G2+Gpv)/Cic) + Pv(i)*((-Gpv-Gvs)/Cvi+(-Gpv-Gvs)/Cic+1/delT) + Pvs(i)*(Gvs/Cvi+Gvs/Cic) + ret_pos(muf(i))*(Gf/Cic) + ret_pos(mu0(i))*(-G0)/Cic);
    Pvs(i+1)=delT*(Pv(i)*Gvs/Cve + Pvs(i)*((-Gvs-Gve)/Cve+1/delT) + CVP(i)*(Gve/Cve) + ret_pos(Pic(i)-Pvs(i))*G0/Cve);
    
    CSF_rate(i)=ret_pos(muf(i))*Gf-ret_pos(mu0(i))*G0+injection(i);
    Reivich=(85.55+904400*exp(-5.251*log10(CO2(i))))/(113.8+221300*exp(-5.251*log10(CO2(i))));
    q(i)=2*G1*(Pa(i)-P1(i));
    
    mu(i+1)=(1-gamma)*mu(i)+gamma*(ABP(i)-Pic(i)); % smooth CPP
    muf(i+1)=(1-gamma1)*muf(i)+gamma1*ret_pos(Pc(i)-Pic(i));
    mu0(i+1)=(1-gamma1)*mu0(i)+gamma1*ret_pos(Pic(i)-Pvs(i));
    
    if(mu(i+1)<40) % Autoregulation wrt smooth CPP instead of oscillating CPP
        r(i+1)=1/Tau1*(delT*(rmax-r(i))+Tau1*r(i));
    elseif(mu(i+1)>140)
        r(i+1)=1/Tau1*(delT*(rmin-r(i))+Tau1*r(i));
    else
        r(i+1)=1/Tau1*(delT*autoreg*(Laplace-r(i))+Tau1*r(i))+1/Tau2*(delT*((Kr1/Reivich)^0.25-(Kr1/Reivich_n)^0.25));
        if(r(i+1)>rmax)
            r(i+1)=rmax;
        elseif(r(i+1)<rmin)
            r(i+1)=rmin;
        end
    end
    CSF(i+1)=delT*(CSF_rate(i))+CSF(i);
end
fprintf('\n');
signals.abp = ABP; signals.cvp = CVP; signals.co2 = CO2; signals.Pa = Pa;
signals.Pic = Pic; signals.P1 = P1; signals.P2 = P2; signals.Pv = Pv; signals.Pvs = Pvs;
signals.q = q; signals.r = r; signals.muf = muf; signals.mu0 = mu0;
%% related figures
h=figure; h_zoom = zoom(h);
set(h_zoom,'Motion','horizontal','Enable','on');
set(h,'Position',[100 100 1600 1600]);

if( strcmp(mode,'normal') )
    h1=subplot(2,2,1); plot(timescale, Pic); title('ICP'); xlabel('time (sec)'); ylabel('Pressure (mmHg)');
    h2=subplot(2,2,2); plot(timescale, r); title('Proximal Arterial Radius'); xlabel('time (sec)'); ylabel('Radius (cm)');
    h3=subplot(2,2,3); plot(timescale, q); title('Volumetric Blood Flow'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    h4=subplot(2,2,4); plot(timescale, CSF);  title('CSF Volume'); xlabel('time (sec)'); ylabel('Volume (cm^3)');
    linkaxes([h1,h2,h3,h4],'x'); suplabel(strcat(mode,'-simulation') ,'t');
    
elseif( strcmp(mode,'hypotension') )
    % ICP Plot
    h1=subplot(2,2,1); plot(timescale,Pic); title('ICP'); xlabel('time (sec)'); ylabel('Pressure (mmHg)');
    % Cerebral Blood Flow Plot
    h2=subplot(2,2,2); plot(timescale,q); title('Volumetric Blood Flow'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    % CSF Formation/Absorption Plot
    h3=subplot(2,2,3); plot(timescale,muf*Gf,'r'); hold on; plot(timescale,mu0*G0,'b'); legend('Formation','Absorption','Location','SouthWest'); hold off;
    title('CSF Formation and Absorption'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    % Radius Plot
    h4=subplot(2,2,4); plot(timescale,r); title('Proximal Arterial Radius'); xlabel('time (sec)'); ylabel('Radius (cm)');
    % Link the subplots, add the supertitle
    linkaxes([h1,h2,h3,h4],'x'); suplabel(strcat(mode,'-simulation') ,'t');
    
elseif( strcmp(mode,'hyperventilation') )
    % ICP Plot
    h1=subplot(2,2,1); plot(timescale,Pic); title('ICP'); xlabel('time (sec)'); ylabel('Pressure (mmHg)');
    % Cerebral Blood Flow Plot
    h2=subplot(2,2,2); plot(timescale,q); title('Volumetric Blood Flow'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    % CSF Formation/Absorption Plot
    h3=subplot(2,2,3); plot(timescale,muf*Gf,'r'); hold on; plot(timescale,mu0*G0,'b'); legend('Formation','Absorption','Location','SouthWest'); hold off;
    title('CSF Formation and Absorption'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    % Radius Plot
    h4=subplot(2,2,4); plot(timescale,r); title('Proximal Arterial Radius'); xlabel('time (sec)'); ylabel('Radius (cm)');
    % Link the subplots, add the supertitle
    linkaxes([h1,h2,h3,h4],'x'); suplabel(strcat(mode,'-simulation') ,'t');
    
elseif( strcmp(mode,'jugularcompression') )
    % ICP Plot
    h1=subplot(2,2,1); plot(timescale,Pvs); title('Ven.Sinus Pressure'); xlabel('time (sec)'); ylabel('mmHg');
    % Cerebral Blood Flow Plot
    h2=subplot(2,2,2); plot(timescale,Pic); title('ICP'); xlabel('time (sec)'); ylabel('Pressure (mmHg)');
    % CSF Formation/Absorption Plot
    h3=subplot(2,2,3); plot(timescale,muf*Gf,'r'); hold on; plot(timescale,mu0*G0,'b'); legend('Formation','Absorption','Location','SouthWest'); hold off;
    title('CSF Formation and Absorption'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    % Radius Plot
    h4=subplot(2,2,4); plot(timescale,CSF); title('CSF Volume'); xlabel('time (sec)'); ylabel('Volume (cm^3)');
    % Link the subplots, add the supertitle
    linkaxes([h1,h2,h3,h4],'x'); suplabel(strcat(mode,'-simulation') ,'t');
elseif( strcmp(mode,'drainage') )
    % ICP Plot
    h1=subplot(2,2,1); plot(timescale,r); title('Proximal Arterial Radius'); xlabel('time (sec)'); ylabel('Radius (cm)');
    % Cerebral Blood Flow Plot
    h2=subplot(2,2,2); plot(timescale,Pic); title('ICP'); xlabel('time (sec)'); ylabel('Pressure (mmHg)');
    % CSF Formation/Absorption Plot
    h3=subplot(2,2,3); plot(timescale,muf*Gf,'r'); hold on; plot(timescale,mu0*G0,'b'); legend('Formation','Absorption','Location','SouthWest'); hold off;
    title('CSF Formation and Absorption'); xlabel('time (sec)'); ylabel('Flow (cm^3 / sec)');
    % Radius Plot
    h4=subplot(2,2,4); plot(timescale,CSF); title('CSF Volume'); xlabel('time (sec)'); ylabel('Volume (cm^3)');
    % Link the subplots, add the supertitle
    linkaxes([h1,h2,h3,h4],'x'); suplabel(strcat(mode,'-simulation') ,'t');
else
    error(strcat('a simulation named:',mode,' is not available'))
end

