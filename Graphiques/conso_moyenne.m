plot_reseau
Z_conso=[11.8 39.5 14.7 7.6 5.3 15.7 8.6 17.3];

% Taille des points à la bonne échelle
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
ylabel(cb,'Puissance moyenne (MW)')

title('Consommation Moyenne de la zone en Hiver (MWh/h)')
text(2-1.5,0, strcat([num2str(round(C_conso(7),1)),' MW']),'Color','blue')
text(5-1.5,0+0.5, strcat([num2str(round(C_conso(6),1)),' MW']),'Color','blue')
text(0+0.5,4-0.4, strcat([num2str(round(C_conso(8),1)),' MW']),'Color','blue')
text(4+0.5,5-0.5, strcat([num2str(round(C_conso(5),1)),' MW']),'Color','blue')
text(3-1.5,7, strcat([num2str(round(C_conso(4),1)),' MW']),'Color','blue')
text(4-1.7,9, strcat([num2str(round(C_conso(3),1)),' MW']),'Color','blue')
text(2-1.8,11, strcat([num2str(round(C_conso(2),1)),' MW']),'Color','blue')
text(1-1.7,13+0, strcat([num2str(round(C_conso(1),1)),' MW']),'Color','blue')

plot_reseau
Z_conso=[8.5 28.5 10.6 5.5 3.8 11.3 6.2 12.5];

% Taille des points à la bonne échelle
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
ylabel(cb,'Puissance moyenne (MW)')

title('Consommation Moyenne de la zone en Ete (MWh/h)')
text(2-1.5,0, strcat([num2str(round(C_conso(7),1)),' MW']),'Color','blue')
text(5-1.5,0+0.5, strcat([num2str(round(C_conso(6),1)),' MW']),'Color','blue')
text(0+0.5,4-0.4, strcat([num2str(round(C_conso(8),1)),' MW']),'Color','blue')
text(4+0.5,5-0.5, strcat([num2str(round(C_conso(5),1)),' MW']),'Color','blue')
text(3-1.5,7, strcat([num2str(round(C_conso(4),1)),' MW']),'Color','blue')
text(4-1.7,9, strcat([num2str(round(C_conso(3),1)),' MW']),'Color','blue')
text(2-1.8,11, strcat([num2str(round(C_conso(2),1)),' MW']),'Color','blue')
text(1-1.7,13+0, strcat([num2str(round(C_conso(1),1)),' MW']),'Color','blue')