clear all
close all

margin=0.03

marge=["1%" "5%" "10%"];
limit_elec=[0.01 0.05 0.1];
limit_eolien=[0.99 0.95 0.9];

if margin==0.01
    tranche=1;
elseif margin==0.05
    tranche=2;
elseif margin==0.1
    tranche=3;
else
    tranche=4;
    marge(tranche)=strcat(num2str(margin*100),"%");
    limit_elec(tranche)=margin;
    limit_eolien(tranche)=1-margin;
end

disp(strcat("Marge choisie : ",marge(tranche)))

% loi de consommation électrique

if season==0% Hiver
    mu=1;
    sigma=0.139;
elseif season==1 % Ete
    mu=1;
    sigma=0.146;
end

figure(1)
x = [0.4:.001:1.599];
y = normpdf(x,mu,sigma);
plot(x,y)
title('Consommation électrique normalisée')
set(gcf,'Color','white')

pd = makedist('Normal','mu',mu,'sigma',sigma);
y = cdf(pd,x);

T=table(x',y','VariableNames',{'x','y'});

i=1;
color_names=[[0.6350, 0.0780, 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]];
for limit=limit_elec
    distrib=T.x(T.y>limit);
    X(i)=distrib(1);
    xline(distrib(1),'--',strcat(num2str(100*limit)," %"),'color',color_names(i,:));
    i=i+1; 
end

disp(strcat('Consommation électrique limite :',num2str(X(tranche))))

% % loi de consommation gazière
% 
% % Hiver
% mu=0;
% sigma=0.251;
% 
% % Ete
% % mu=0;
% % sigma=0.400;
% 
% figure(2)
% x = [0:.001:2.999];
% y = lognpdf(x,mu,sigma);
% plot(x,y)
% title('Consommation gazière normalisée')
% set(gcf,'Color','white')


% facteur de charge

if season==0% Hiver
    alpha=1.584;
    beta=4.010;
elseif season==1 % Ete
    alpha=2.062;
    beta=9.725;
end

figure(3)
x = [0:.001:0.999];
y = betapdf(x,alpha,beta);
plot(x,y)
title('Facteur de charge éolien')
set(gcf,'Color','white')

pd = makedist('Beta','a',alpha,'b',beta);
y = cdf(pd,x);

T=table(x',y','VariableNames',{'x','y'});

i=1;
color_names=[[0.6350, 0.0780, 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]];
for limit=limit_eolien
    distrib=T.x(T.y>limit);
    X(i)=distrib(1);
    xline(distrib(1),'--',strcat(num2str(100*limit)," %"),'color',color_names(i,:));
    i=i+1; 
end

disp(strcat('Facteur de charge éolien limite : ',num2str(X(tranche))))
