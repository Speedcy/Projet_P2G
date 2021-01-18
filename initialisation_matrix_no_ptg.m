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

conso_elec_normalised=1.0785;
cons_gaz_normalised=2.0825;
load_factor=0.5;


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


%---------------------------------------------------------------------

%Matpower running simulation 

result = runpf(mpc); %Run
 
disp('===========================================')
disp('Simulation optimisée - No PtG')
disp('------------------')
tot = result.branch(:,PF)+result.branch(:,PT);
loss = sum(tot);
disp(['Perte totale (MW) = ', num2str(loss)])
surplus = -result.gen(1,PG);
disp(['Surplus électrique (MW) = ', num2str(surplus)])


%Diagramme d'admissibilité

n_noeud=1;
list_noeud=zeros(1,1);
list_tension=zeros(1,1);
list_tension_basse=zeros(1,1);
list_tension_haute=zeros(1,1);

for z = 0:1:7
    pmax(z+1)=mpc.gen(z+1,PMAX);
end
 
for l = 0:7
    res1 = result.bus(l+1,VM);
    volt(l+1)=res1;
    for p = 1:length(volt) %Réglage de la puissance réactive pour diminiuer ou augmenter la tension
        if volt(p)<0.95
            mpc.gen(p,QG)= (tan(acos(cos_phi))-0.15)*mpc.gen(p,PMAX);
            disp('===========================================')
            disp('Réglage de la tension')
            disp('------------------')
            disp(['Tension trop basse au noeud ', num2str(p),' avec une tension de ', num2str(result.bus(p,VM))]);    
            list_noeud(n_noeud)=p;
            list_tension(n_noeud)=result.bus(p,VM);
            list_tension_basse(n_noeud)=1;
            list_tension_haute(n_noeud)=0;
            n_noeud=n_noeud+1;
            result = runpf(mpc);
            res1 = result.bus(l+1,VM);
            volt(l+1)=res1;
        end
        if volt(p)>1.07
            mpc.gen(p,QG)= -(tan(acos(cos_phi))-0.15)*mpc.gen(p,PMAX);
            disp('===========================================')
            disp('Réglage de la tension')
            disp('------------------')
            disp(['Tension trop haute au noeud ', num2str(p),' avec une tension de ', num2str(result.bus(p,VM))]); 
            list_noeud(n_noeud)=p;
            list_tension(n_noeud)=result.bus(p,VM);
            list_tension_basse(n_noeud)=0;
            list_tension_haute(n_noeud)=1;
            n_noeud=n_noeud+1;
            result = runpf(mpc);
            res1 = result.bus(l+1,VM);
            volt(l+1)=res1;
        end
    end
    res2 = result.gen(l+1,QG);
    reactive(l+1)=res2;
end
        
for m = 1:length(reactive)
    reactive_frac(m) = reactive(m)/pmax(m);
end

text_list=["Damery","Cubry","Vertus","Aulnay","Fere","Arcis","Mery","Sezanne"];

figure(1)
for o=1:length(reactive_frac)         %1000 is the length of x_vector and y_vector
    plot(reactive_frac(o), volt(o), 'o')
    text(reactive_frac(o), volt(o),text_list(o))
    hold on
    fplot('-0.067*x+1.08',[-0.3423 0.45], '-')
    hold on
    fplot('-0.067*x+0.92',[-0.471 0.32], '-')
    hold on
    fplot('1.15*x+0.53',[0.32 0.4528], '-')
    hold on
    fplot('1.16*x+1.50',[-0.472 -0.3423], '-')
    hold on
    plot([0 0],[-1 1.15 ], '--')
    hold on
    
    axis([-1 1 0.85 1.15])
    xlabel('Q/Pmax')
    ylabel('U/Unom')
end