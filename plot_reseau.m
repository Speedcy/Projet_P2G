figure()
set(gcf,'Color','white')
% reseau
plot([2 0],[0 4],'color','black')
hold on;
plot([2 5],[0 0],'color','black')
plot([5 4],[0 5],'color','black')
plot([0 4],[4 5],'color','black')
plot([3 4],[7 5],'color','black')
plot([3 4],[7 9],'color','black')
plot([4 2],[9 11],'color','black')
plot([1 2],[13 11],'color','black')
%point
% 1: Damery 2: Cubry 3: Vertus 4: Aulnay 5: Fère 6: Arcis 7: Méry 8:
% Sézanne
X=[1 2 4 3 4 5 2 0];    
Y=[13 11 9 7 5 0 0 4];
scatter(X,Y,[],'black','filled')
%nom
text(2+0.2,0+0.5, 'Mery')
text(5+0.2,0+0.5, 'Arcis-sur-Aube')
text(0,4+1, 'Sézanne')
text(4+0.2,5+0.5, 'Fère-Champenoise')
text(3+0.4,7, 'Aulnay')
text(4+0.2,9+0.5, 'Vertus')
text(2+0.2,11+0.5, 'Cubry')
text(1+0.2,13+0.5, 'Damery')
xlim([-1 8])
ylim([-1 15])

line_plot=["plot([1 2],[13 11],'color','red','linewidth',2)" 
    "plot([4 2],[9 11],'color','red','linewidth',2)" 
    "plot([3 4],[7 9],'color','red','linewidth',2)" 
    "plot([3 4],[7 5],'color','red','linewidth',2)" 
    "plot([5 4],[0 5],'color','red','linewidth',2)"
    "plot([2 5],[0 0],'color','red','linewidth',2)"
    "plot([2 0],[0 4],'color','red','linewidth',2)"
    "plot([0 4],[4 5],'color','red','linewidth',2)"];

value_plot_x=[0.25 1.8 4 2 4.75 3 1.3 2];
value_plot_y=[11.5 9.5 8 6 2.5 0.8 2 4];