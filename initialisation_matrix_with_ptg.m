% function initialisation_matrix
clear all;
close all;
clc;
warning off;
define_constants;
%Main parameters
mpc = loadcase('etudeaffinepq');%load the case format
cos_phi = 0.9;%cos(phi) of the electrical load of the network

%Run parameters
reactive=[];
pmax=[];
reactive_frac=[];
volt=[];
tab=[];
elec_surplus=[];

%Installed wind power (MW)
% G_damery = 0;
% G_cubry = 0.5;
% G_vertus = 87;
% G_aulnay = 25;
% G_fere = 110;
% G_arcis = 100;
% G_mery = 106;
% G_sezanne = 72;
G_damery = 0;
G_cubry = 0.5;
G_vertus = 87;
G_aulnay = 25;
G_fere = 110;
G_arcis = 100;
G_mery = 106;
G_sezanne = 72;

%Generate Monte-Carlo season
season = 0%randi([0 1]);%0-Winter; 1-Summer

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
%conso_elec_normalised = normrnd(mu_conso_elec, sigma_conso_elec);
%cons_gaz_normalised = lognrnd(mu_conso_gaz, sigma_conso_gaz);
%load_factor = betarnd(alpha_load_factor, beta_load_factor)+0.02;

conso_elec_normalised=1.0785;
cons_gaz_normalised=2.0825;
load_factor=0.8;

%simplify naming for readability
alpha = load_factor;
beta = conso_elec_normalised;
gamma = cons_gaz_normalised;

%generate consumption matrix
%active power
mpc.bus(1,PD) = beta*C_damery;
mpc.bus(2,PD) = beta*C_cubry;
mpc.bus(3,PD) = beta*C_vertus;
mpc.bus(4,PD) = beta*C_aulnay;
mpc.bus(5,PD) = beta*C_fere;
mpc.bus(6,PD) = beta*C_arcis;
mpc.bus(7,PD) = beta*C_mery;
mpc.bus(8,PD) = beta*C_sezanne;
%reactive power
mpc.bus(1,QD) = mpc.bus(1,PD)*tan(acos(cos_phi));
mpc.bus(2,QD) = mpc.bus(2,PD)*tan(acos(cos_phi));
mpc.bus(3,QD) = mpc.bus(3,PD)*tan(acos(cos_phi));
mpc.bus(4,QD) = mpc.bus(4,PD)*tan(acos(cos_phi));
mpc.bus(5,QD) = mpc.bus(5,PD)*tan(acos(cos_phi));
mpc.bus(6,QD) = mpc.bus(6,PD)*tan(acos(cos_phi));
mpc.bus(7,QD) = mpc.bus(7,PD)*tan(acos(cos_phi));
mpc.bus(8,QD) = mpc.bus(8,PD)*tan(acos(cos_phi));

%generate production matrix
%installed capacity
mpc.gen(1,PMAX) = G_damery;
mpc.gen(2,PMAX) = G_cubry;
mpc.gen(3,PMAX) = G_vertus;
mpc.gen(4,PMAX) = G_aulnay;
mpc.gen(5,PMAX) = G_fere;
mpc.gen(6,PMAX) = G_arcis;
mpc.gen(7,PMAX) = G_mery;
mpc.gen(8,PMAX) = G_sezanne;
%produced capacity
mpc.gen(1,PG) = alpha*mpc.gen(1,PMAX);
mpc.gen(2,PG) = alpha*mpc.gen(2,PMAX);
mpc.gen(3,PG) = alpha*mpc.gen(3,PMAX);
mpc.gen(4,PG) = alpha*mpc.gen(4,PMAX);
mpc.gen(5,PG) = alpha*mpc.gen(5,PMAX);
mpc.gen(6,PG) = alpha*mpc.gen(6,PMAX);
mpc.gen(7,PG) = alpha*mpc.gen(7,PMAX);
mpc.gen(8,PG) = alpha*mpc.gen(8,PMAX);

disp('===========================================')
disp('Simulation générée')
disp('------------------')
if season==0
    disp('Hiver')
else
    disp('Eté')
end
disp(['Facteur de charge éolien = ', num2str(alpha)])
disp(['Charge électrique normalisée = ', num2str(beta)])
disp(['Charge gaz normalisée = ', num2str(gamma)])

% Situation avec forte production éolienne = max de ptg
power_ptg = 40.0;

%Add PtG consumption in Mery


mpc.bus(7,PD) = beta*C_mery+power_ptg;
mpc.bus(7,QD) = mpc.bus(7,PD)*tan(acos(cos_phi));

result2 = runpf(mpc); %Run

disp('===========================================')
disp('Simulation générée')
disp('------------------')
if season==0
    disp('Hiver')
else
    disp('Eté')
end
disp(['Facteur de charge éolien = ', num2str(alpha)])
disp(['Charge électrique normalisée = ', num2str(beta)])
disp(['Charge gaz normalisée = ', num2str(gamma)])

disp('===========================================')
disp('Simulation optimisée - PtG')
disp('------------------')
tot2 = result2.branch(:,PF)+result2.branch(:,PT);
loss2 = sum(tot2);
disp(['Puissance PtG (MW) = ', num2str(power_ptg)])
disp(['Perte totale (MW) = ', num2str(loss2)])
surplus2 = -result2.gen(1,PG);
disp(['Surplus électrique (MW) = ', num2str(surplus2)])

