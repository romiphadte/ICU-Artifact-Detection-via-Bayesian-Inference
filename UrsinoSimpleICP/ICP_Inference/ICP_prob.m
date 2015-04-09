function x_next = ICP_prob(x_curr)
particles = size(x_curr,2);
x_next = zeros(7,particles);

Pic= x_curr(1,:); 
Pc = x_curr(2,:); 
Ca = x_curr(3,:);
Va = x_curr(4,:); 
q = x_curr(5,:); 
sigma_Gx = x_curr(6,:);
I = x_curr(7,:); 

    Ca(t) = Ca(t-1) + delT/tau*(-Ca(t-1)+sigma_Gx(t-1)); % for DBN, there should be some additive noise
    Pic(t) = delT*kE*Pic(t-1)/(1+Ca(t-1)*kE*Pic(t-1))*...
        (   Ca(t-1)*(Pa(t)-Pa(t-1))/delT + ...
        (Ca(t)-Ca(t-1))/delT*(Pa(t-1)-Pic(t-1)) + ...
        (Pc(t-1)-Pic(t-1))/Rf - ...
        (Pic(t-1)-Pvs(t-1))/Ro + I(t-1) ) + Pic(t-1); % for DBN, there should be some additive noise
    
    Va(t) = Ca(t)*(Pa(t) - Pic(t));
    Ra = (kR*Can^2)/(Va(t)^2);
    Pc(t) = (Pa(t)*Rpv + Pic(t)*Ra)/(Rpv+Ra);
    q(t) = (Pa(t)-Pc(t))/Ra;
    x = (q(t) - qn)/qn;
    delCa = (x<=0)*delCa1 + (x>0)*delCa2;
    k_sigma = delCa/4;
    sigma_Gx(t) = ( (Can+delCa/2)+(Can-delCa/2)*exp(G*x/k_sigma) )/(1+exp(G*x/k_sigma));  

x_next(1,:)=Pic;
x_next(2,:)=Pc;
x_next(3,:)=Ca;
x_next(4,:)=Va;
x_next(5,:)=q;
x_next(6,:)=sigma_Gx;
x_next(7,:)=I;