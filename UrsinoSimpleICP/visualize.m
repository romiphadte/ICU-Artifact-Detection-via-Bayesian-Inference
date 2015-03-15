function visualize(delT,Pic,Pc,q,Ca)
T = length(Pic);
figure();
subplot(2,2,1);
plot((1:T)*delT,Pic);
title('ICP')
xlabel('sec'); ylabel('mmHg');
xlim([1 T]*delT); 
subplot(2,2,2);
plot((1:T)*delT,Pc);
title('Capillary Pressure');
xlabel('sec'); ylabel('mmHg');
xlim([1 T]*delT); 
subplot(2,2,3);
plot((1:T)*delT,q);
title('Cerebral Blood Flow');
xlabel('sec'); ylabel('ml/sec');
xlim([1 T]*delT); 
subplot(2,2,4);
plot((1:T)*delT,Ca);
title('Arteriolar Compliance')
xlabel('sec'); ylabel('ml/mmHg');
xlim([1 T]*delT); 
