clear all
close all

nombre_heures=120;
season_number=1; %0: hiver 1:été
if season_number==0
    season_name='Hiver';
else
    season_name='Ete';
end

original_T = readtable('save_results_1_week.txt');
original_T.Properties.VariableNames = {'season','alpha','beta','gamma','loss','surplus','power_ptg','loss2','surplus2','power_gaz','Ctot_gaz','stock','CO2_evite'};

T=original_T(original_T.season==season_number,:);
T=T(1:nombre_heures,:);

T_hiver=original_T(original_T.season==0,:);
T_hiver=T_hiver(1:nombre_heures,:);

T_ete=original_T(original_T.season==1,:);
T_ete=T_ete(1:nombre_heures,:);

% Figure 20 rapport

Fig1=figure;

edges=[0:2:40];
h1=histogram(T_ete.power_ptg,edges);
List_h1=transpose(h1.Values);
h2=histogram(T_hiver.power_ptg,edges);
List_h2=transpose(h2.Values);

edges_bis=[1:2:39];
b=bar(edges_bis,[List_h1 List_h2],1,'stack');
b(1).FaceColor=[1 0 0];
b(2).FaceColor=[0 0 1];

xlabel("Puissance moyenne d'utilisation sur une heure (MW)",'FontSize',14,'interpreter','none')
%ylabel('émissions de CO2 évitées (kg)','FontSize',14,'interpreter','none')
title(sprintf("Nombre d'occurence de la puissance de fonctionnement \n de l'unité PtG par tranche d'1h \n"),'FontSize',20)
legend('Ete','Hiver') 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])

%Explication de la polarité
Fig2=figure;
size=15;
set(gca,'Color','white')
set(gcf,'Color','white')
x = T_ete.alpha;
y = T_ete.beta;       % create combinations of distances
C = T_ete.surplus; 
hold on
for i=1:length(x)
    if C(i)<=0% how mayn points inside circle
        scatter(x(i),y(i),size,'blue','filled')
    elseif C(i)>40
        scatter(x(i),y(i),size,'red','filled')
    else
        scatter(x(i),y(i),size,[1 0.5 0.5],'filled')
    end
end

x = T_hiver.alpha;
y = T_hiver.beta;       % create combinations of distances
C = T_hiver.surplus; 
for i=1:length(x)
    if C(i)<=0% how mayn points inside circle
        s(1)=scatter(x(i),y(i),size,'blue','filled');
    elseif C(i)>40
        s(3)=scatter(x(i),y(i),size,'red','filled');
    else
        s(2)=scatter(x(i),y(i),size,[1 0.5 0.5],'filled');
    end
end

legend(s,'Déficit','Surplus < 40 MW','Surplus > 40 MW')
xlabel('Facteur de charge éolien')
ylabel('Consomattion électrique normalisée')

% Figure 19 rapport

Fig3=figure;

edges=[-150:10:150];
h1=histogram(T_ete.surplus,edges);
List_h1=transpose(h1.Values);
h2=histogram(T_hiver.surplus,edges);
List_h2=transpose(h2.Values);

edges_bis=[-145:10:145];
b=bar(edges_bis,[List_h1 List_h2],1,'stack');
b(1).FaceColor=[1 0 0];
b(2).FaceColor=[0 0 1];

xlabel("Surplus (MW)",'FontSize',14,'interpreter','none')
%ylabel('émissions de CO2 évitées (kg)','FontSize',14,'interpreter','none')
title(sprintf("Nombre d'occurences du surplus électrique \n de la zone par tranche d'1h \n"),'FontSize',16)
legend('Ete','Hiver') 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])
hold on
X = [0,0] ;
Y = [0,20] ;
x1=plot(X,Y,'--','Color','black','linewidth',2)
x1.Annotation.LegendInformation.IconDisplayStyle = 'off';
X = [40,40] ;
Y = [0,20] ;
x2=plot(X,Y,'--','Color','black','linewidth',2)
x2.Annotation.LegendInformation.IconDisplayStyle = 'off';


pas=sum(T_ete.power_ptg==0)+sum(T_hiver.power_ptg==0)
full=sum(T_ete.power_ptg==40)+sum(T_hiver.power_ptg==40)
inter=240-pas-full