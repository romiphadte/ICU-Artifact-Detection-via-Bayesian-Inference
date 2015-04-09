function x_next= ICP_prob(x_curr,Pa_next,Pvs_next,Pa_curr,Pvs_curr,Ro,kE,G,tau)
particles = size(x_curr,2);
x_next = zeros(7,particles);

Rpv = 1.24;
Rf = 2.38*1e3;
delCa1 = 0.75;
delCa2 = 0.075;
Can = 0.15;
kR = 4.91*1e4;
qn = 12.5;
delT = 1;

I_same_state = 0.999;
I_diff_State = 0.0001;
drain_constant=-0.66;

Pic_curr= x_curr(1,:); 
Pc_curr = x_curr(2,:); 
Ca_curr = x_curr(3,:);
Va_curr = x_curr(4,:); 
q_curr = x_curr(5,:); 
sigma_Gx_curr = x_curr(6,:);
I_curr = x_curr(7,:); 

I_next=(I_curr==(rand(1,particles)<=I_same_state));

Ca_next = Ca_curr + delT/tau.*(-Ca_curr+sigma_Gx_curr) + 1.0*randn(1,particles); % for DBN, there should be some additive noise
Pic_next = delT.*kE.*Pic_curr/(1+Ca_curr.*kE.*Pic_curr).*...
    (   Ca_curr.*(Pa_next-Pa_curr)/delT + ...
    (Ca_next-Ca_curr)/delT.*(Pa_curr-Pic_curr) + ...
    (Pc_curr-Pic_curr)/Rf - ...
    (Pic_curr-Pvs_curr)/Ro + I_curr.*drain_constant) + Pic_curr + 1.0*randn(1,particles) ; % for DBN, there should be some additive noise

Va_next = Ca_next.*(Pa_next - Pic_next);
Ra = (kR.*Can.^2)./(Va_next.^2);
Pc_next = (Pa_next.*Rpv + Pic_next.*Ra)./(Rpv+Ra);
q_next = (Pa_next-Pc_next)./Ra;
x = (q_next - qn)./qn;
delCa = (x<=0)*delCa1 + (x>0)*delCa2;
k_sigma = delCa/4;
sigma_Gx_next = ( (Can+delCa/2)+(Can-delCa/2).*exp(G*x/k_sigma) )./(1+exp(G*x/k_sigma));  

x_next(1,:)=Pic_next;
x_next(2,:)=Pc_next;
x_next(3,:)=Ca_next;
x_next(4,:)=Va_next;
x_next(5,:)=q_next;
x_next(6,:)=sigma_Gx_next;
x_next(7,:)=I_next;