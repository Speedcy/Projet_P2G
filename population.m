plot_reseau
Z_conso=[15068 39082 21557 7487 6218 11827 10200 21870];
% Taille des points à la bonne échelle
a_conso=(200-40)/(40000-5000);
b_conso=40-5000*a_conso;
C_conso=Z_conso/1000;
P_conso=Z_conso*a_conso+b_conso;
for z=1:8
    scatter(X(z),Y(z),P_conso(z),C_conso(z),'filled')
end
blueMap = [linspace(200, 25, 256)', linspace(200, 25, 256)', ones(256, 1)*255]/256;
colormap(blueMap);
cb=colorbar;
ylabel(cb,'Nombre d''habitants (en milliers)')

title('Population dans la zone')
% text(2-1.6,0, num2str(C_conso(7)),'Color','blue')
% text(5-1.5,0+0.5, num2str(C_conso(6)),'Color','blue')
% text(0+0.5,4-0.4, num2str(C_conso(8)),'Color','blue')
% text(4+0.5,5-0.5, num2str(C_conso(5)),'Color','blue')
% text(3-1.5,7, num2str(C_conso(4)),'Color','blue')
% text(4-1.7,9, num2str(C_conso(3)),'Color','blue')
% text(2-1.5,11, num2str(C_conso(2)),'Color','blue')
% text(1-1.3,13+0, num2str(C_conso(1)),'Color','blue')