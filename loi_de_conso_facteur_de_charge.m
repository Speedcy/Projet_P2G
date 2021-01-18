clear all
close all

tranche=2; % 1: 1% 2: 5% 3: 10%
marge=["1%" "5%" "10%"];
disp(strcat("Marge choisie : ",marge(tranche)))

% loi de consommation �lectrique

% Hiver
mu=1;
sigma=0.139;

% Ete
% mu=1;
% sigma=0.146;

figure(1)
x = [0.4:.001:1.599];
y = normpdf(x,mu,sigma);
plot(x,y)
title('Consommation �lectrique normalis�e')
set(gcf,'Color','white')

pd = makedist('Normal','mu',mu,'sigma',sigma);
y = cdf(pd,x);

T=table(x',y','VariableNames',{'x','y'});

i=1;
color_names=[[0.6350, 0.0780, 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]];
for limit=[0.01 0.05 0.1]
    distrib=T.x(T.y>limit);
    X(i)=distrib(1);
    xline(distrib(1),'--',strcat(num2str(100*limit)," %"),'color',color_names(i,:));
    i=i+1; 
end

disp(strcat('Consommation �lectrique limite :',num2str(X(tranche))))

% loi de consommation gazi�re

% Hiver
mu=0;
sigma=0.251;

% Ete
% mu=0;
% sigma=0.400;

figure(2)
x = [0:.001:2.999];
y = lognpdf(x,mu,sigma);
plot(x,y)
title('Consommation gazi�re normalis�e')
set(gcf,'Color','white')


% facteur de charge

% Hiver
alpha=1.584;
beta=4.010;

% Ete
% alpha=2.062;
% beta=9.725;

figure(3)
x = [0:.001:0.999];
y = betapdf(x,alpha,beta);
plot(x,y)
title('Facteur de charge �olien')
set(gcf,'Color','white')

pd = makedist('Beta','a',alpha,'b',beta);
y = cdf(pd,x);

T=table(x',y','VariableNames',{'x','y'});

i=1;
color_names=[[0.6350, 0.0780, 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]];
for limit=[0.99 0.95 0.9]
    distrib=T.x(T.y>limit);
    X(i)=distrib(1);
    xline(distrib(1),'--',strcat(num2str(100*limit)," %"),'color',color_names(i,:));
    i=i+1; 
end

disp(strcat('Facteur de charge �olien limite : ',num2str(X(tranche))))
