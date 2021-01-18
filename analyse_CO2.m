clear all
close all

nombre_heures=120;
season_number=1; %0: hiver 1:�t�
if season_number==0
    season_name='Hiver';
else
    season_name='Ete';
end

original_T = readtable('save_results_with_CO2.txt');
original_T.Properties.VariableNames = {'season','alpha','beta','gamma','loss','surplus','power_ptg','loss2','surplus2','power_gaz','Ctot_gaz','stock','CO2_evite'};

T=original_T(original_T.season==season_number,:);
T=T(1:nombre_heures,:);

CO2_total=sum(T.CO2_evite);
disp(['Simulation ', season_name, ' : ', num2str(CO2_total), ' kg de CO2 absorb�s sur ',num2str(height(T)), ' h'])

Fig1=figure;

scatter(T.alpha*100,T.CO2_evite,'k')

xlabel('Facteur de charge �olien (%)','FontSize',14,'interpreter','none')
ylabel('CO2 absorb� (kg)','FontSize',14,'interpreter','none')
title('CO2 absorb� en fonction du facteur de charge �olien','FontSize',16)
legend(season_name,'Location','southeast') 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])

Fig2=figure;

scatter(T.Ctot_gaz,T.CO2_evite,'k')

xlabel('Consommation totale gazi�re (MWh)','FontSize',14,'interpreter','none')
ylabel('CO2 absorb� (kg)','FontSize',14,'interpreter','none')
title('CO2 absorb� pour diff�rentes consommation gazi�res','FontSize',16)
legend(season_name,'Location','southeast') 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])

Fig3=figure;

edges=[0:200:4400];
histogram(T.CO2_evite,edges)

xlabel('CO2 absorb� (kg)','FontSize',14,'interpreter','none')
%ylabel('�missions de CO2 �vit�es (kg)','FontSize',14,'interpreter','none')
title('Histogramme de r�partition du CO2 absorb� par tranches d une heure (en kg)','FontSize',16)
legend(season_name) 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])

T_hiver=original_T(original_T.season==0,:);
T_hiver=T_hiver(1:nombre_heures,:);

T_ete=original_T(original_T.season==1,:);
T_ete=T_ete(1:nombre_heures,:);

Fig4=figure;

scatter(T_ete.alpha*100,T_ete.CO2_evite,[],'r')
hold on 
scatter(T_hiver.alpha*100,T_hiver.CO2_evite,[],'b','x')

xlabel('Facteur de charge �olien (%)','FontSize',14,'interpreter','none')
ylabel('CO2 absorb� (kg)','FontSize',14,'interpreter','none')
title('CO2 absorb� en fonction du facteur de charge �olien','FontSize',16)
legend('Ete','Hiver','Location','southeast')  
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])

Fig5=figure;

scatter(T_ete.Ctot_gaz,T_ete.CO2_evite,[],'r')
hold on 
scatter(T_hiver.Ctot_gaz,T_hiver.CO2_evite,[],'b','x')

xlabel('Consommation totale gazi�re (MWh)','FontSize',14,'interpreter','none')
ylabel('CO2 absorb� (kg)','FontSize',14,'interpreter','none')
title('CO2 absorb� pour diff�rentes consommation gazi�res','FontSize',16)
legend('Ete','Hiver','Location','southeast') 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])

Fig6=figure;

edges=[0:200:4400];
h1=histogram(T_ete.CO2_evite,edges);
List_h1=transpose(h1.Values);
h2=histogram(T_hiver.CO2_evite,edges);
List_h2=transpose(h2.Values);

edges_bis=[100:200:4300];
b=bar(edges_bis,[List_h1 List_h2],1,'stack');
b(1).FaceColor=[1 0 0];
b(2).FaceColor=[0 0 1];

xlabel('CO2 absorb� (kg)','FontSize',14,'interpreter','none')
%ylabel('�missions de CO2 �vit�es (kg)','FontSize',14,'interpreter','none')
title('Histogramme de r�partition du CO2 absorb� par tranches d une heure (en kg)','FontSize',16)
legend('Ete','Hiver') 
set(gca,'fontsize',10)
set(gcf,'Color',[1,1,1])


