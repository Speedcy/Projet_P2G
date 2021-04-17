% Etudier la formation de congestions pour un sc�nario (Saison, Puissance
% PtG, marge) dans le cas avec ou sans PtG et d�terminer les couts des
% travaux n�cessaires � la r�solution des congestions

%% Definition des param�tres initiaux

clear all;
close all;
clc;
warning off;
define_constants;
%Main parameters
mpc = loadcase('etudeaffinepq');%load the case format
cos_phi = 0.9;%cos(phi) of the electrical load of the network

margin=0.05; % Valeur de la marge
ecretement=1; % Production effectivement inject�e sur le r�seau, le reste �tant �cr�t� (1=100%, 0.5=50%...)
cout_ligne_unitaire=0.65; % Cout renforcement ligne pour une section 228mm� (M�/km) 
cout_transfo_unitaire=0.14; % Cout renforcement transfo (M�/MVA)
cout_Q_unitaire=0; % Cout renforcement puissance r�active (M�/MVA) 
puissance_max_ptg=40.0; % Puissance de l'unit� PtG (MW)
modif_ligne=1; % 0: sans modification des param�tres de lignes 1: avec modification
affichage_detail=2; % 0: affichage courant it�ration initiale et finale 
                    % 1: affichage des courants pour toutes les it�rations
                    % 2: affichage des courants et des tensions pour toutes les it�rations

%Generate Monte-Carlo season
season = 0%randi([0 1]);%0-Winter; 1-Summer

%% Cr�ation du r�seau �lectrique 

%Run parameters
reactive=[];
pmax=[];
reactive_frac=[];
volt=[];
tab=[];
elec_surplus=[];

max_I=[648.6 519.5]; % Maximal current in winter and summer
plan_tension_correct=1;

%Installed wind power (MW)
G_damery = 0*ecretement;
G_cubry = 0.5*ecretement;
G_vertus = 87*ecretement;
G_aulnay = 25*ecretement;
G_fere = 110*ecretement;
G_arcis = 100*ecretement;
G_mery = 106*ecretement;
G_sezanne = 72*ecretement;

parameters_determination

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

% Copies du r�seau �lectrique
mpc_original=mpc; 
mpc2=mpc;

%% R�sum� des conditions de simulation

disp('===========================================')
disp('Simulation g�n�r�e')
disp('------------------')
if season==0
    disp('Hiver')
else
    disp('Et�')
end
disp(['Facteur de charge �olien = ', num2str(alpha)])
disp(['Charge �lectrique normalis�e = ', num2str(beta)])
disp(['Charge gaz normalis�e = ', num2str(gamma)])

% Affichage des lieux de consommation

plot_reseau
Z_conso=zeros(1,8);
for z=1:8
    Z_conso(z)=mpc.bus(z,PD);
end
% Taille des points � la bonne �chelle
a_conso=164/40;
b_conso=36;
C_conso=Z_conso;
P_conso=Z_conso*a_conso+b_conso;
for z=1:8
    scatter(X(z),Y(z),P_conso(z),C_conso(z),'filled')
end
blueMap = [linspace(200, 25, 256)', linspace(200, 25, 256)', ones(256, 1)*255]/256;
colormap(blueMap);
cb=colorbar;
ylabel(cb,'Consommation (MW)')

title('Lieux de Consommation')
text(2-1.6,0, strcat([num2str(round(mpc.bus(7,PD),1)),' MW']),'Color','blue')
text(5-1.5,0+0.5, strcat([num2str(round(mpc.bus(6,PD),1)),' MW']),'Color','blue')
text(0+0.5,4-0.4, strcat([num2str(round(mpc.bus(8,PD),1)),' MW']),'Color','blue')
text(4+0.5,5-0.5, strcat([num2str(round(mpc.bus(5,PD),1)),' MW']),'Color','blue')
text(3-1.5,7, strcat([num2str(round(mpc.bus(4,PD),1)),' MW']),'Color','blue')
text(4-1.7,9, strcat([num2str(round(mpc.bus(3,PD),1)),' MW']),'Color','blue')
text(2-1.5,11, strcat([num2str(round(mpc.bus(2,PD),1)),' MW']),'Color','blue')
text(1-1.3,13+0, strcat([num2str(round(mpc.bus(1,PD),1)),' MW']),'Color','blue')

% Affichage des lieux de production

plot_reseau
Z_prod=zeros(1,8);
for z=1:8
    Z_prod(z)=mpc.gen(z,PG);
end
C_prod=Z_prod;
P_prod=Z_prod*164/100+36;
for z=1:8
    scatter(X(z),Y(z),P_prod(z),C_prod(z),'filled')
end
redMap = [ones(256, 1)*255, linspace(200, 25, 256)', linspace(200, 25, 256)']/256;
colormap(redMap);
cb=colorbar;
ylabel(cb,'Production (MW)')

title('Lieux de Production')
text(2-1.6,0, strcat([num2str(round(mpc.gen(7,PG),1)),' MW']),'Color','red')
text(5-1.5,0+0.5, strcat([num2str(round(mpc.gen(6,PG),1)),' MW']),'Color','red')
text(0+0.5,4-0.4, strcat([num2str(round(mpc.gen(8,PG),1)),' MW']),'Color','red')
text(4+0.5,5-0.5, strcat([num2str(round(mpc.gen(5,PG),1)),' MW']),'Color','red')
text(3-1.5,7, strcat([num2str(round(mpc.gen(4,PG),1)),' MW']),'Color','red')
text(4-1.7,9, strcat([num2str(round(mpc.gen(3,PG),1)),' MW']),'Color','red')
text(2-1.5,11, strcat([num2str(round(mpc.gen(2,PG),1)),' MW']),'Color','red')
text(1-1.3,13+0, strcat([num2str(round(mpc.gen(1,PG),1)),' MW']),'Color','red')

%% Simulation initiale (sans PtG)

%Matpower running simulation 

result = runpf(mpc); %Run
 
% R�sum� de la simulation
disp('===========================================')
disp('Simulation optimis�e - No PtG')
disp('------------------')
tot = result.branch(:,PF)+result.branch(:,PT);
loss = sum(tot);
disp(['Perte totale (MW) = ', num2str(loss)])
surplus = -result.gen(1,PG);
disp(['Surplus �lectrique (MW) = ', num2str(surplus)])

%Diagramme d'admissibilit�

ajustement_tension

% figure(1)
% for o=1:length(reactive_frac)         %1000 is the length of x_vector and y_vector
%     plot(reactive_frac(o), volt(o), 'o')
%     hold on
%     fplot('-0.067*x+1.08',[-0.3423 0.45], '-')
%     hold on
%     fplot('-0.067*x+0.92',[-0.471 0.32], '-')
%     hold on
%     fplot('1.15*x+0.53',[0.32 0.4528], '-')
%     hold on
%     fplot('1.16*x+1.50',[-0.472 -0.3423], '-')
%     hold on
%     plot([0 0],[-1 1.15 ], '--')
%     hold on
%     
%     axis([-1 1 0.85 1.15])
%     xlabel('Q/Pmax')
%     ylabel('U/Unom')
% end

%% Etude des congestions (sans PtG)

pertes=result.branch(:,PF)+result.branch(:,PT); % pertes sur les lignes
I=((pertes*10^6)./(mpc.branch(:,BR_R)*81)).^(0.5)/3; % courant de lignes

L_ligne=mpc.branch(:,3)/0.0018; % longueur des lignes
r_ligne=0.0018*ones(length(I),1); % r�sistance de ligne
I_nom=max_I(season+1)*ones(length(I),1); % courant nominal de ligne
lignes_data=readtable('data_lignes.csv'); % donn�es sur les lignes de diam�tre sup�rieur � 228mm
if season==0
    lignes_data.I_max=lignes_data.Intensit_DeCourantAdmissibleHiver_A_;
elseif season==1
    lignes_data.I_max=lignes_data.Intensit_DeCourantAdmissibleEte_A_;
end

% Sch�ma de la situation initiale sans P2G

plot_reseau
title('Sans P2G')
congestion=I>I_nom;
for j=1:length(congestion)
    if congestion(j)==1
        eval(line_plot(j))
        text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I_nom(j))),'color','red')
    else
        text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I_nom(j))))
    end
end

iteration=0;
while sum(I>I_nom)>0 % Si congestion c�d si une des branches a un courant sup�rieur � la valeur du courant nominal
    disp('')
    disp('Congestion sur le reseau')
    if affichage_detail>0
        plot_reseau
        title(strcat("Sans P2G (Iteration ",num2str(iteration),")"))
        congestion=I>I_nom;
        for j=1:length(congestion)
            if congestion(j)==1
                eval(line_plot(j))
                text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I_nom(j))),'color','red')
            else
                text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I_nom(j))))
            end
        end
    end
    [M,i]=max(I-I_nom); % S�lection de la ligne qui a la plus grande congestion (ligne i)
    % S�lection d'une ligne de capacit� sup�rieure et modifcation du
    % vecteur de r�sistance lin�ique
    ligne_sup=[lignes_data.I_max(lignes_data.I_max>I_nom(i)) lignes_data.R_sistanceLin_ique_Ohm_km_(lignes_data.I_max>I_nom(i))/81];
    I_nom(i)=ligne_sup(1,1);
    r_ligne(i)=ligne_sup(1,2);
    
    if modif_ligne==1
        mpc.branch(:,3)=L_ligne.*r_ligne; % modification des r�sistances de ligne
        % modification des r�actances de ligne (non impl�ment�)
        result = runpf(mpc); % simulation avec les nouveaux param�tres de ligne
        if affichage_detail==2
            plot_plan_tension_v2(result,strcat("Sans P2G (Iteration ",num2str(iteration),")"),VM)
        end
        ajustement_tension % ajustement de la puissance r�active pour la nouvelle simulation
        %result = runpf(mpc);
        pertes=result.branch(:,PF)+result.branch(:,PT);
        I=((pertes*10^6)./(mpc.branch(:,BR_R)*81)).^(0.5)/3; % calcul des nouveaux courants de ligne
    end
   
    iteration=iteration+1;
end

I_nom = solve_overdim(I,I_nom,lignes_data.I_max);
    
plot_reseau
title('Schema Final : Sans P2G')
for j=1:length(I)
    text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I_nom(j))))
end

plot_plan_tension_v2(result,'Sans P2G',VM)
if sum(result.bus(:,VM)<0.95)+sum(result.bus(:,VM)>1.07)>0
    plan_tension_correct=0;
end
plot_diagramme_admissibilite

facteur_cout=zeros(length(I),1);
for ligne=1:length(I)
    I_ligne=I_nom(ligne);
    facteur_cout(ligne)=lignes_data.FacteurCout(find(round(lignes_data.I_max)==round(I_ligne)));
end

cout=sum((max_I(season+1)*ones(length(I),1)~=I_nom).*L_ligne.*facteur_cout)*cout_ligne_unitaire;

disp(strcat("Cout des travaux de renforcement de lignes (Sans P2G) : ",num2str(cout)," M�"))

S_damery=(result.branch(1,PF)^2+result.branch(1,QF)^2)^0.5;

I1_nom=I_nom;

%% Ajout de l'unit� PtG

%Optimisation after adding P2G
if surplus <= puissance_max_ptg
    if surplus > 0
        power_ptg = surplus;
    end
    if surplus <= 0
        power_ptg = 0;
    end
end
if surplus > puissance_max_ptg
    power_ptg = puissance_max_ptg;
end

%Add PtG consumption in Fere-C.

% C_P2G=C_fere;
% num_P2G=5;

%Add PtG consumption in Mery

C_P2G=C_mery;
num_P2G=7;

mpc2.bus(num_P2G,PD) = beta*C_P2G+power_ptg;
mpc2.bus(num_P2G,QD) = mpc2.bus(num_P2G,PD)*tan(acos(cos_phi));

%% Simulation initiale (avec PtG)

result2 = runpf(mpc2); %Run

disp('===========================================')
disp('Simulation g�n�r�e')
disp('------------------')
if season==0
    disp('Hiver')
else
    disp('Et�')
end
disp(['Facteur de charge �olien = ', num2str(alpha)])
disp(['Charge �lectrique normalis�e = ', num2str(beta)])
disp(['Charge gaz normalis�e = ', num2str(gamma)])

disp('===========================================')
disp('Simulation optimis�e - No PtG')
disp('------------------')
disp(['Perte totale (MW) = ', num2str(loss)])
disp(['Surplus �lectrique (MW) = ', num2str(surplus)])

disp('===========================================')
disp('Simulation optimis�e - PtG')
disp('------------------')
tot2 = result2.branch(:,PF)+result2.branch(:,PT);
loss2 = sum(tot2);
disp(['Puissance PtG (MW) = ', num2str(power_ptg)])
disp(['Perte totale (MW) = ', num2str(loss2)])
surplus2 = -result2.gen(1,PG);
disp(['Surplus �lectrique (MW) = ', num2str(surplus2)])

ajustement_tension22

%% Etude des congestions (avec PtG)

pertes2=result2.branch(:,PF)+result2.branch(:,PT);
I2=((pertes2*10^6)./(mpc2.branch(:,BR_R)*81)).^(0.5)/3;

L_ligne=mpc2.branch(:,3)/0.0018; % longueur des lignes
r_ligne=0.0018*ones(length(I2),1);
I_nom=max_I(season+1)*ones(length(I2),1); % courant nominal de ligne
%lignes_data=readtable('data_lignes.csv');
%lignes_data.I_max=max_I(season+1)*(1+lignes_data.EvolutionDeIParRapport_Ref228mm_);

% Sch�ma initial avec P2G

plot_reseau
title('Avec P2G')
%scatter(X(num_P2G),Y(num_P2G),'blue','filled')
scatter(X(num_P2G),Y(num_P2G),power_ptg*a_conso+b_conso,'blue','filled')
text(2-2.1,0, strcat(['P2G (',num2str(round(power_ptg,1)),' MW)']),'Color','blue')
congestion=I2>I_nom;
for j=1:length(congestion)
    if congestion(j)==1
        eval(line_plot(j))
        text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))),'color','red')
    else
        text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))))
    end
end

iteration=0;
while sum(I2>I_nom)>0 % Si congestion
    disp('')
    disp('Congestion sur le reseau')
    if affichage_detail>0
        plot_reseau
        title(strcat("Avec P2G (Iteration ",num2str(iteration),")"))
        scatter(X(num_P2G),Y(num_P2G),power_ptg*a_conso+b_conso,'blue','filled')
        text(2-2.1,0, strcat(['P2G (',num2str(round(power_ptg,1)),' MW)']),'Color','blue')
        congestion=I2>I_nom;
        for j=1:length(congestion)
            if congestion(j)==1
                eval(line_plot(j))
                text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))),'color','red')
            else
                text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))))
            end
        end
    end
    %plot_plan_tension
    [M,i]=max(I2-I_nom); % ligne i a la plus grande congestion
    ligne_sup=[lignes_data.I_max(lignes_data.I_max>I_nom(i)) lignes_data.R_sistanceLin_ique_Ohm_km_(lignes_data.I_max>I_nom(i))/81];
    I_nom(i)=ligne_sup(1,1);
    r_ligne(i)=ligne_sup(1,2);
    
    if modif_ligne==1
        mpc2.branch(:,3)=L_ligne.*r_ligne; % modification des r�sistances de ligne
        % modification des r�actances de ligne
        result2 = runpf(mpc2); % simulation avec les nouveaux param�tres de ligne
        if affichage_detail==2
            plot_plan_tension_v2(result2,strcat("Avec P2G (Iteration ",num2str(iteration),")"),VM)
        end
        ajustement_tension22 % ajustement de la puissance r�active pour la nouvelle simulation
        %result2 = runpf(mpc2);
        pertes2=result2.branch(:,PF)+result2.branch(:,PT);
        I2=((pertes2*10^6)./(mpc2.branch(:,BR_R)*81)).^(0.5)/3; % calcul des nouveaux courants de ligne
    end
    iteration=iteration+1;
end

I_nom = solve_overdim(I2,I_nom,lignes_data.I_max);

plot_reseau
title('Schema Final : Avec P2G')
scatter(X(num_P2G),Y(num_P2G),power_ptg*a_conso+b_conso,'blue','filled')
text(2-2.1,0, strcat(['P2G (',num2str(round(power_ptg,1)),' MW)']),'Color','blue')
for j=1:length(I)
    text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))))
end

plot_plan_tension_v2(result2,'Avec P2G',VM)
if sum(result2.bus(:,VM)<0.95)+sum(result2.bus(:,VM)>1.07)>0
    plan_tension_correct=0;
end
plot_diagramme_admissibilite

%cout_P2G=sum((max_I(season+1)*ones(length(I2),1)~=I_nom).*L_ligne)*0.65;

facteur_cout=zeros(length(I2),1);
for ligne=1:length(I2)
    I_ligne=I_nom(ligne);
    facteur_cout(ligne)=lignes_data.FacteurCout(find(round(lignes_data.I_max)==round(I_ligne)));
end

cout_P2G=sum((max_I(season+1)*ones(length(I2),1)~=I_nom).*L_ligne.*facteur_cout)*cout_ligne_unitaire;

%% R�sum� de la simulation 

disp(" ")
disp("<strong>Param�tres de la simulation</strong>")
disp(" ")
if season==0
    disp('Saison : Hiver')
else
    disp('Saison : Et�')
end
disp(strcat("Marge choisie : ",marge(tranche)))
disp(strcat("Facteur de charge �olien : ",num2str(100*alpha)," %"))
disp(strcat("Pourcentage de production �olienne �cr�t�e : ",num2str(100*(1-ecretement))," %"))
disp(strcat("Puissance max P2G : ",num2str(puissance_max_ptg)," MW"))
disp(strcat("Cout renforcement ligne section 228 mm� : ",num2str(cout_ligne_unitaire),"M�/km"))
disp(strcat("Cout renforcement transformateur : ",num2str(cout_transfo_unitaire),"M�/MVA"))

disp(" ")
disp("<strong>Ajustement de puissance r�active</strong>")
disp(" ")
%point
% 1: Damery 2: Cubry 3: Vertus 4: Aulnay 5: F�re 6: Arcis 7: M�ry 8:
% S�zanne
ecart_Q_no_P2G=0;
ecart_Q_P2G=0;
name=["Damery" "Cubry" "Vertus" "Aulnay" "F�re" "Arcis" "M�ry" "S�zanne"];
Q_modif=(mpc.gen(:,3)-mpc_original.gen(:,3));
disp("Simulation sans P2G :")
for i=1:length(Q_modif)
    ecart_Q=Q_modif(i);
    if ecart_Q>0
        disp(strcat("Puissance r�active augment�e de ",num2str(ecart_Q)," MVar � ",name(i)))
    elseif ecart_Q<0
        disp(strcat("Puissance r�active diminu�e de ",num2str(ecart_Q)," MVar � ",name(i)))
    end
    ecart_Q_no_P2G=ecart_Q_no_P2G+abs(ecart_Q);
end

disp("Simulation avec P2G :")
Q_modif=(mpc2.gen(:,3)-mpc_original.gen(:,3));
for i=1:length(Q_modif)
    ecart_Q=Q_modif(i);
    if ecart_Q>0
        disp(strcat("Puissance r�active augment�e de ",num2str(ecart_Q)," MVar � ",name(i)))
    elseif ecart_Q<0
        disp(strcat("Puissance r�active diminu�e de ",num2str(ecart_Q)," MVar � ",name(i)))
    end
    ecart_Q_P2G=ecart_Q_P2G+abs(ecart_Q);
end

cout_Q=(ecart_Q_no_P2G-ecart_Q_P2G)*cout_Q_unitaire;
disp(" ")
disp(strcat("Cout des travaux �vit�s par le P2G (marge ",num2str(100*margin),"%) : ",num2str(round(cout_Q,2))," M�"))

disp(" ")
disp("<strong>Renforcement des lignes du r�seau</strong>")
disp(" ")
disp(strcat("Cout des travaux (Sans P2G) : ",num2str(round(cout,2))," M�"))
disp(strcat("Cout des travaux (Avec P2G) : ",num2str(round(cout_P2G,2))," M�"))

cout_ligne=cout-cout_P2G;

disp(strcat("Cout des travaux �vit�s par le P2G (marge ",num2str(100*margin),"%) : ",num2str(round(cout_ligne,2))," M�"))

S2_damery=(result2.branch(1,PF)^2+result2.branch(1,QF)^2)^0.5;

disp(" ")
disp("<strong>Renforcement du transformateur de Damery (225kV/63kV)</strong>")
disp(" ")
disp(strcat("Puissance apparente au poste de Damery sans P2G : ",num2str(round(S_damery,1))," MVA"))
disp(strcat("Puissance apparente au poste de Damery avec P2G : ",num2str(round(S2_damery,1))," MVA"))

cout_transfo=(S_damery-S2_damery)*cout_transfo_unitaire;

disp(strcat("Cout des travaux �vit�s par le P2G (marge ",num2str(100*margin),"%) : ",num2str(round(cout_transfo,2))," M�"))

disp(" ")

cout_total=cout_ligne+cout_transfo+cout_Q;

disp(strcat("<strong>Cout total des travaux �vit�s par le P2G (marge ",num2str(100*margin),"%) : </strong>",num2str(round(cout_total,1))," M�"))
if plan_tension_correct==0 % Si le plan de tension est incorrect
    disp('Attention : Plan de tension incorrect !')
end

%% Save Results

A = [puissance_max_ptg; margin; season; alpha; beta; gamma; cout; cout_P2G; cout_ligne; cout_transfo; cout_Q; cout_total];
A = A';
file = fopen('save_results_congestion.txt', 'a');
fprintf(file,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n',A);
fclose(file);
