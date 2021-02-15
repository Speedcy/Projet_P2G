figure()
title('Diagramme Admissibilité RTE')
set(gcf,'Color','white')
nom=["Damery" "Cubry" "Vertus" "Aulnay" "Fère" "Arcis" "Méry" "Sézanne"];
for o=1:length(reactive_frac)         %1000 is the length of x_vector and y_vector
    if reactive_frac(o)~=Inf && reactive_frac(o)~=0
        text(reactive_frac(o)+0.05, volt(o)+0.005, nom(o))
    end
    plot(reactive_frac(o), volt(o), 'o')
    hold on
    fplot('-0.067*x+1.08',[-0.3423 0.45], '-')
    hold on
    fplot('-0.067*x+0.92',[-0.471 0.32], '-')
    hold on
    fplot('1.15*x+0.53',[0.32 0.4528], '-')
    hold on
    fplot('1.16*x+1.50',[-0.472 -0.3423], '-')
    hold on
    plot([0 0],[-1 1.15 ], '--')
    hold on
    
    axis([-1 1 0.85 1.15])
    xlabel('Q/Pmax')
    ylabel('U/Unom')
end