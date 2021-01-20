% function initialisation_matrix
clear all;
close all;
clc;
warning off;
define_constants;
%Main parameters
mpc = loadcase('etudeaffinepq');%load the case format
cos_phi = 0.9;%cos(phi) of the electrical load of the network

margin=0.05;
ecretement=1.1;
cout_ligne_unitaire=0.65; % Cout renforcement ligne (M€/km)

%Generate Monte-Carlo season
season = 0%randi([0 1]);%0-Winter; 1-Summer

%Run parameters
reactive=[];
pmax=[];
reactive_frac=[];
volt=[];
tab=[];
elec_surplus=[];
max_I=[700 550]; % Maximal current in winter and summer

%Installed wind power (MW)
G_damery = 0*ecretement;
G_cubry = 0.5*ecretement;
G_vertus = 87*ecretement;
G_aulnay = 25*ecretement;
G_fere = 110*ecretement;
G_arcis = 100*ecretement;
G_mery = 106*ecretement;
G_sezanne = 72*ecretement;
% G_damery = 0;
% G_cubry = 0.5;
% G_vertus = 87;
% G_aulnay = 25;
% G_fere = 200;
% G_arcis = 200;
% G_mery = 200;
% G_sezanne = 200;

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

% Affichage du plan de tension

plot_reseau
Z=zeros(1,8);
for z=1:8
    Z(z)=result.bus(z,VM);
end
C=Z*90;
P=Z*200/0.12-1483.3;
for z=1:8
    if 0.95<=Z(z) && Z(z)<=1.07
        scatter(X(z),Y(z),P(z),C(z),'filled')
    end
end
cb=colorbar;
ylabel(cb,'Voltage (kV)')
basse=0;
eleve=0;
for z=1:8
    if Z(z)<0.95
        s1=scatter(X(z),Y(z),P(z));
        s1.LineWidth = 3;
        s1.MarkerEdgeColor = [0.4940 0.1840 0.5560];
        s1.MarkerFaceColor = [1 1 1];
        liste_basse(1)=s1;
        basse=1;
    elseif Z(z)>1.07
        s2=scatter(X(z),Y(z),P(z));
        s2.LineWidth = 3;
        s2.MarkerEdgeColor = [0.8500 0.3250 0.0980];
        s2.MarkerFaceColor = [1 1 1];
        liste_eleve(1)=s2;
        eleve=1;
    end
end
if basse==1 && eleve==1
    legend([s1 s2],{'Tension trop basse','Tension trop élevée'})
elseif basse==1
    legend([s1],{'Tension trop basse'})
elseif eleve==1
    legend([s2],{'Tension trop élevée'})
end


%Diagramme d'admissibilité

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

Z=readtable('z.csv');
pertes=result.branch(:,PF)+result.branch(:,PT);
I=(pertes./Z.Z).^(1/2); % courant de lignes

L_ligne=mpc.branch(:,3)/0.0018; % longueur des lignes
I_nom=max_I(season+1)*ones(length(I),1); % courant nominal de ligne
lignes_data=readtable('data_lignes.csv');
lignes_data.I_max=max_I(season+1)*(1+lignes_data.EvolutionDeIParRapport_Ref228mm_);

while sum(I>I_nom)>0 % Si congestion
    disp('')
    disp('Congestion sur le reseau')  
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
    [M,i]=max(I-I_nom); % ligne i a la plus grande congestion
    ligne_sup=lignes_data.I_max(lignes_data.I_max>I_nom(i));
    I_nom(i)=ligne_sup(1);
    % modifier la résistance et la réactance de la ligne
    % run
end

facteur_cout=zeros(length(I),1);
for ligne=1:length(I)
    I_ligne=I_nom(ligne);
    facteur_cout(ligne)=lignes_data.FacteurCout(find(round(lignes_data.I_max)==round(I_ligne)));
end

cout=sum((max_I(season+1)*ones(length(I),1)~=I_nom).*L_ligne.*facteur_cout)*cout_ligne_unitaire;

disp(strcat("Cout des travaux (Sans P2G) : ",num2str(cout)," M€"))

I1_nom=I_nom;

%---------------------------------------------------------------------

%Optimisation after adding P2G
if surplus <= 40.0
    if surplus > 0
        power_ptg = surplus;
    end
    if surplus <= 0
        power_ptg = 0;
    end
end
if surplus > 40.0
    power_ptg = 40.0;
end

%Add PtG consumption in Fere-C.

% C_P2G=C_fere;
% num_P2G=5;

C_P2G=C_mery;
num_P2G=7;

mpc.bus(num_P2G,PD) = beta*C_P2G+power_ptg;
mpc.bus(num_P2G,QD) = mpc.bus(num_P2G,PD)*tan(acos(cos_phi));

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
disp('Simulation optimisée - No PtG')
disp('------------------')
disp(['Perte totale (MW) = ', num2str(loss)])
disp(['Surplus électrique (MW) = ', num2str(surplus)])

disp('===========================================')
disp('Simulation optimisée - PtG')
disp('------------------')
tot2 = result2.branch(:,PF)+result2.branch(:,PT);
loss2 = sum(tot2);
disp(['Puissance PtG (MW) = ', num2str(power_ptg)])
disp(['Perte totale (MW) = ', num2str(loss2)])
surplus2 = -result2.gen(1,PG);
disp(['Surplus électrique (MW) = ', num2str(surplus2)])

pertes2=result2.branch(:,PF)+result2.branch(:,PT);
I2=(pertes2./Z.Z).^(1/2);

L_ligne=mpc.branch(:,3)/0.0018; % longueur des lignes
I_nom=max_I(season+1)*ones(length(I2),1); % courant nominal de ligne
lignes_data=readtable('data_lignes.csv');
lignes_data.I_max=max_I(season+1)*(1+lignes_data.EvolutionDeIParRapport_Ref228mm_);

while sum(I2>I_nom)>0 % Si congestion
    disp('')
    disp('Congestion sur le reseau')
    plot_reseau
    title('Avec P2G')
    scatter(X(num_P2G),Y(num_P2G),'blue','filled')
    congestion=I2>I_nom;
    for j=1:length(congestion)
        if congestion(j)==1
            eval(line_plot(j))
            text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))),'color','red')
        else
            text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))))
        end
    end
    [M,i]=max(I2-I_nom); % ligne i a la plus grande congestion
    ligne_sup=lignes_data.I_max(lignes_data.I_max>I_nom(i));
    I_nom(i)=ligne_sup(1);
    % modifier la résistance et la réactance de la ligne
    % run
end

%cout_P2G=sum((max_I(season+1)*ones(length(I2),1)~=I_nom).*L_ligne)*0.65;

facteur_cout=zeros(length(I2),1);
for ligne=1:length(I2)
    I_ligne=I_nom(ligne);
    facteur_cout(ligne)=lignes_data.FacteurCout(find(round(lignes_data.I_max)==round(I_ligne)));
end

cout_P2G=sum((max_I(season+1)*ones(length(I2),1)~=I_nom).*L_ligne.*facteur_cout)*cout_ligne_unitaire;

disp(strcat("Cout des travaux (Avec P2G) : ",num2str(cout_P2G)," M€"))

disp(strcat("Cout des travaux évités par le P2G (marge ",num2str(100*margin),"%) : ",num2str(cout-cout_P2G)," M€"))

% Final plot

plot_reseau
title('Schema Final : Sans P2G')
for j=1:length(I)
    text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I1_nom(j))))
end

plot_reseau
title('Schema Final : Avec P2G')
scatter(X(num_P2G),Y(num_P2G),'blue','filled')
for j=1:length(I)
    text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))))
end

% 
% line_plot=["plot([1 2],[13 11],'color','red','linewidth',2)" 
%     "plot([4 2],[9 11],'color','red','linewidth',2)" 
%     "plot([3 4],[7 9],'color','red','linewidth',2)" 
%     "plot([3 4],[7 5],'color','red','linewidth',2)" 
%     "plot([5 4],[0 5],'color','red','linewidth',2)"
%     "plot([2 5],[0 0],'color','red','linewidth',2)"
%     "plot([2 0],[0 4],'color','red','linewidth',2)"
%     "plot([0 4],[4 5],'color','red','linewidth',2)"];
% 
% figure()
% % reseau
% plot([2 0],[0 4],'color','black')
% hold on;
% plot([2 5],[0 0],'color','black')
% plot([5 4],[0 5],'color','black')
% plot([0 4],[4 5],'color','black')
% plot([3 4],[7 5],'color','black')
% plot([3 4],[7 9],'color','black')
% plot([4 2],[9 11],'color','black')
% plot([1 2],[13 11],'color','black')
% %point
% X=[2 5 0 4 3 4 2 1];    
% Y=[0 0 4 5 7 9 11 13];
% scatter(X,Y,[],'black','filled')
% %nom
% text(2+0.2,0+0.5, 'Mery')
% text(5+0.2,0+0.5, 'Arcis-sur-Aube')
% text(0,4+1, 'Sézanne')
% text(4+0.2,5+0.5, 'Fère-Champenoise')
% text(3+0.4,7, 'Aulnay')
% text(4+0.2,9+0.5, 'Vertus')
% text(2+0.2,11+0.5, 'Cubry')
% text(1+0.2,13+0.5, 'Damery')
% xlim([-1 8])
% ylim([-1 15])