% function initialisation_matrix
clc;
disp(" ")
disp(nb)
disp(" ")
warning off;
define_constants;
%Main parameters
mpc = loadcase('etudeaffinepq');%load the case format
cos_phi = 0.9;%cos(phi) of the electrical load of the network

%mpc.branch(:,4)=mpc.branch(:,4)*0.0048/0.0082;
r_ligne_init=mpc.branch(:,3);

ecretement=1; % Production effectivement injectée sur le réseau, le reste étant écrété (1=100%, 0.5=50%...)
cout_ligne_unitaire=0.65; % Cout renforcement ligne pour une section 228mm² (M€/km) 
cout_transfo_unitaire=0.14; % Cout renforcement transfo (M€/MVA)
modif_ligne=1; % 0: sans modification des paramètres de lignes 1: avec modification
affichage_detail=0; % 0: affichage itération initiale et finale 1: affichage de toutes les itérations

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


%Diagramme d'admissibilité

ajustement_tension

pertes=result.branch(:,PF)+result.branch(:,PT);
I=((pertes*10^6)./(mpc.branch(:,BR_R)*81)).^(0.5)/3; % courant de lignes

L_ligne=mpc.branch(:,3)/0.0018; % longueur des lignes
r_ligne=0.0018*ones(length(I),1);
I_nom=max_I(season+1)*ones(length(I),1); % courant nominal de ligne
lignes_data=readtable('data_lignes.csv');
lignes_data.I_max=max_I(season+1)*(1+lignes_data.EvolutionDeIParRapport_Ref228mm_);

while sum(I>I_nom)>0 % Si congestion
    disp('')
    disp('Congestion sur le reseau')
    [M,i]=max(I-I_nom); % ligne i a la plus grande congestion
    ligne_sup=[lignes_data.I_max(lignes_data.I_max>I_nom(i)) lignes_data.R_sistanceLin_ique_Ohm_km_(lignes_data.I_max>I_nom(i))/81];
    I_nom(i)=ligne_sup(1,1);
    r_ligne(i)=ligne_sup(1,2);
    
    if modif_ligne==1
        mpc.branch(:,3)=L_ligne.*r_ligne; % modification des résistances de ligne
        % modification des réactances de ligne
        result = runpf(mpc); % simulation avec les nouveaux paramètres de ligne
        ajustement_tension % ajustement de la puissance réactive pour la nouvelle simulation
        pertes=result.branch(:,PF)+result.branch(:,PT);
        I=((pertes*10^6)./(mpc.branch(:,BR_R)*81)).^(0.5)/3; % calcul des nouveaux courants de ligne
    end
end

facteur_cout=zeros(length(I),1);
for ligne=1:length(I)
    I_ligne=I_nom(ligne);
    facteur_cout(ligne)=lignes_data.FacteurCout(find(round(lignes_data.I_max)==round(I_ligne)));
end

cout=sum((max_I(season+1)*ones(length(I),1)~=I_nom).*L_ligne.*facteur_cout)*cout_ligne_unitaire;

disp(strcat("Cout des travaux de renforcement de lignes (Sans P2G) : ",num2str(cout)," M€"))

S_damery=(result.branch(1,PF)^2+result.branch(1,QF)^2)^0.5;

I1_nom=I_nom;

%---------------------------------------------------------------------

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

mpc.bus(num_P2G,PD) = beta*C_P2G+power_ptg;
mpc.bus(num_P2G,QD) = mpc.bus(num_P2G,PD)*tan(acos(cos_phi));

mpc.branch(:,3)=r_ligne_init; % Réinitialisation des résistances de lignes
% Idem réactances

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
I2=((pertes2*10^6)./(mpc.branch(:,BR_R)*81)).^(0.5)/3;

L_ligne=mpc.branch(:,3)/0.0018; % longueur des lignes
r_ligne=0.0018*ones(length(I2),1);
I_nom=max_I(season+1)*ones(length(I2),1); % courant nominal de ligne
lignes_data=readtable('data_lignes.csv');
lignes_data.I_max=max_I(season+1)*(1+lignes_data.EvolutionDeIParRapport_Ref228mm_);

while sum(I2>I_nom)>0 % Si congestion
    disp('')
    disp('Congestion sur le reseau')
    if affichage_detail==1
        plot_reseau
        title('Avec P2G')
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
        mpc.branch(:,3)=L_ligne.*r_ligne; % modification des résistances de ligne
        % modification des réactances de ligne
        result2 = runpf(mpc); % simulation avec les nouveaux paramètres de ligne
        ajustement_tension % ajustement de la puissance réactive pour la nouvelle simulation
        pertes2=result2.branch(:,PF)+result2.branch(:,PT);
        I2=((pertes2*10^6)./(mpc.branch(:,BR_R)*81)).^(0.5)/3; % calcul des nouveaux courants de ligne
    end
end

%cout_P2G=sum((max_I(season+1)*ones(length(I2),1)~=I_nom).*L_ligne)*0.65;

facteur_cout=zeros(length(I2),1);
for ligne=1:length(I2)
    I_ligne=I_nom(ligne);
    facteur_cout(ligne)=lignes_data.FacteurCout(find(round(lignes_data.I_max)==round(I_ligne)));
end

cout_P2G=sum((max_I(season+1)*ones(length(I2),1)~=I_nom).*L_ligne.*facteur_cout)*cout_ligne_unitaire;

% Résumé de la simulation 

disp(" ")
disp("<strong>Paramètres de la simulation</strong>")
disp(" ")
if season==0
    disp('Saison : Hiver')
else
    disp('Saison : Eté')
end
disp(strcat("Marge choisie : ",marge(tranche)))
disp(strcat("Facteur de charge éolien : ",num2str(100*alpha)," %"))
disp(strcat("Pourcentage de production éolienne écrétée : ",num2str(100*(1-ecretement))," %"))
disp(strcat("Puissance max P2G : ",num2str(puissance_max_ptg)," MW"))
disp(strcat("Cout renforcement ligne section 228 mm² : ",num2str(cout_ligne_unitaire),"M€/km"))
disp(strcat("Cout renforcement transformateur : ",num2str(cout_transfo_unitaire),"M€/MVA"))

disp(" ")
disp("<strong>Renforcement des lignes du réseau</strong>")
disp(" ")
disp(strcat("Cout des travaux (Sans P2G) : ",num2str(round(cout,2))," M€"))
disp(strcat("Cout des travaux (Avec P2G) : ",num2str(round(cout_P2G,2))," M€"))

disp(strcat("Cout des travaux évités par le P2G (marge ",num2str(100*margin),"%) : ",num2str(round(cout-cout_P2G,2))," M€"))

S2_damery=(result2.branch(1,PF)^2+result2.branch(1,QF)^2)^0.5;

disp(" ")
disp("<strong>Renforcement du transformateur de Damery (225kV/63kV)</strong>")
disp(" ")
disp(strcat("Puissance apparente au poste de Damery sans P2G : ",num2str(round(S_damery,1))," MVA"))
disp(strcat("Puissance apparente au poste de Damery avec P2G : ",num2str(round(S2_damery,1))," MVA"))

cout_transfo=(S_damery-S2_damery)*cout_transfo_unitaire;

disp(strcat("Cout des travaux évités par le P2G (marge ",num2str(100*margin),"%) : ",num2str(round(cout_transfo,2))," M€"))

disp(" ")

disp(strcat("<strong>Cout total des travaux évités par le P2G (marge ",num2str(100*margin),"%) : </strong>",num2str(round(cout-cout_P2G+cout_transfo,1))," M€"))

% Save Results

A = [puissance_max_ptg; margin; season; alpha; beta; gamma; cout; cout_P2G; cout-cout_P2G; cout_transfo; cout-cout_P2G+cout_transfo];
A = A';
file = fopen('save_results_congestion.txt', 'a');
fprintf(file,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n',A);
fclose(file);

% Final plot

% plot_reseau
% title('Schema Final : Sans P2G')
% for j=1:length(I)
%     text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I(j))),'/',num2str(I1_nom(j))))
% end
% 
% plot_reseau
% title('Schema Final : Avec P2G')
% scatter(X(num_P2G),Y(num_P2G),power_ptg*a_conso+b_conso,'blue','filled')
% text(2-2.1,0, strcat(['P2G (',num2str(round(power_ptg,1)),' MW)']),'Color','blue')
% for j=1:length(I)
%     text(value_plot_x(j),value_plot_y(j),strcat(num2str(round(I2(j))),'/',num2str(I_nom(j))))
% end

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