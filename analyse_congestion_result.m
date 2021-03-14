close all
clear all

duree_vie_P2G=20;

data=readtable('save_results_congestion.txt');

Puissance_P2G=unique(data.puissance_max_ptg);

Cout_moyen_travaux=zeros(length(Puissance_P2G),1);
Cout_max_travaux=zeros(length(Puissance_P2G),1);

for i=1:length(Puissance_P2G)
    puissance=Puissance_P2G(i)
    %cout_max=max(data.cout_total_evite(data.puissance_max_ptg==puissance,:))
    %cout_moyen=mean(data.cout_total_evite(data.puissance_max_ptg==puissance,:))
    Cout_moyen_travaux(i)=mean(data.cout_total_evite(data.puissance_max_ptg==puissance,:))/duree_vie_P2G;
    Cout_max_travaux(i)=max(data.cout_total_evite(data.puissance_max_ptg==puissance,:))/duree_vie_P2G;
end

Results=table(Puissance_P2G,Cout_moyen_travaux, Cout_max_travaux)

x_interp=linspace(0,100,101);
Cout_moyen_interp=interp1(Results.Puissance_P2G,Results.Cout_moyen_travaux,x_interp,'spline');
Cout_max_interp=interp1(Results.Puissance_P2G,Results.Cout_max_travaux,x_interp,'spline');

%Cout_moyen_fit=fit(Results.Puissance_P2G,Results.Cout_moyen_travaux,'poly1');
Cout_moyen_fit=fit(Results.Puissance_P2G,Results.Cout_moyen_travaux,fittype('a*x'),'StartPoint',[0.3]);
Cout_max_fit=fit(Results.Puissance_P2G,Results.Cout_max_travaux,fittype('a*x'),'StartPoint',[0.3]);

figure;
plot(Cout_moyen_fit,Results.Puissance_P2G,Results.Cout_moyen_travaux)
hold on;
s=scatter(Results.Puissance_P2G,Results.Cout_moyen_travaux,'blue');
xlabel('Puissance unité P2G (MW)')
ylabel('Bénéfice (M€)')
title(sprintf("Bénéfice annuel vis à vis du réseau d'une unité P2G \n en fonction de sa puissance"))
set(gcf,'Color','White')
set(gca,'FontSize',12)
set(get(get(s,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
legend('Données Brutes',strcat(sprintf('a*x (a=%.0f %',Cout_moyen_fit.a*1000),' k€/MW)'),'location','north')

figure;
plot(Cout_max_fit,Results.Puissance_P2G,Results.Cout_max_travaux)
hold on;
s=scatter(Results.Puissance_P2G,Results.Cout_max_travaux,'blue');
xlabel('Puissance unité P2G (MW)')
ylabel('Bénéfice (M€)')
title(sprintf("Bénéfice annuel vis à vis du réseau d'une unité P2G \n en fonction de sa puissance"))
set(gcf,'Color','White')
set(gca,'FontSize',12)
set(get(get(s,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
legend('Données Brutes',strcat(sprintf('a*x (a=%.0f % ',Cout_max_fit.a*1000),' k€/MW)'),'location','north')


