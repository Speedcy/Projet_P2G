% Détermine les valeurs des paramètres d’entrées d’une simulation que sont :
% -	Le facteur de charge éolien déterminé à partir de la marge
% -	La consommation électrique normalisée déterminé à partir de la marge
% -	La consommation gazière normalisée déterminée à partir d’un tirage aléatoire

marge=["1%" "5%" "10%"];
limit_elec=[0.01 0.05 0.1];
limit_eolien=[0.99 0.95 0.9];
color_names=[[0.6350, 0.0780, 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.25, 0.25, 0.25]];

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
for limit=limit_elec
    distrib=T.x(T.y>limit);
    X(i)=distrib(1);
    xline(distrib(1),'--',strcat(num2str(100*limit)," %"),'color',color_names(i,:));
    i=i+1; 
end

disp(strcat("Consommation électrique limite : ",num2str(X(tranche))))

conso_elec_normalised=X(tranche);

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
for limit=limit_eolien
    distrib=T.x(T.y>limit);
    X(i)=distrib(1);
    xline(distrib(1),'--',strcat(num2str(100*limit)," %"),'color',color_names(i,:));
    i=i+1; 
end

disp(strcat("Facteur de charge éolien limite : ",num2str(X(tranche))))

load_factor=X(tranche);

if season==0%Winter case
    %generate power consumption random data in winter
    mu_conso_elec = 1;
    sigma_conso_elec = 0.139;
    %load power consumption fixed data in winter (MW)
    C_damery = 11.8;
    C_cubry = 39.5;
    C_vertus = 14.7;
    C_aulnay = 7.6;
    C_fere = 5.3;
    C_arcis = 15.7;
    C_mery = 8.6;
    C_sezanne = 17.3;
    
    %generate load factor in winter
    alpha_load_factor = 1.584;
    beta_load_factor = 4.010;
    
    %generate gas consumption random data in winter
    mu_conso_gaz = 0;
    sigma_conso_gaz = 0.251;
    %load gas consumption fixed data in winter (MW)
    C_pont_gaz = 2.38;
    C_romilly_gaz = 22.3;
    C_maiziere_gaz = 1.18;
    C_chatres_gaz = 1.29;
    C_mery_gaz = 1.80;
    
elseif season==1%Summer case   
    %generate power consumption random data in summer
    mu_conso_elec = 1;
    sigma_conso_elec = 0.146;
    %load power consumption fixed data in summer (MW)
    C_damery = 8.5;
    C_cubry = 28.5;
    C_vertus = 10.6;
    C_aulnay = 5.5;
    C_fere = 3.8;
    C_arcis = 11.3;
    C_mery = 6.2;
    C_sezanne = 12.5;
    
    %generate load factor in summer
    alpha_load_factor = 2.062;
    beta_load_factor = 9.725;
    
    %generate gas consumption random data in summer
    mu_conso_gaz = 0;
    sigma_conso_gaz = 0.400;
    %load gas consumption fixed data in summer (MW)
    C_pont_gaz = 0.96;
    C_romilly_gaz = 9.06;
    C_maiziere_gaz = 0.48;
    C_chatres_gaz = 0.52;
    C_mery_gaz = 0.73;
    
end

%generate random figures
cons_gaz_normalised = lognrnd(mu_conso_gaz, sigma_conso_gaz);

