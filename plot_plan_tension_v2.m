function [] = plot_plan_tension(res,name,VM)
plot_reseau
title(strcat(name,' : Plan de tension'))
Z=zeros(1,8);
for z=1:8
    Z(z)=res.bus(z,VM);
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
end

