% Permet de lancer la simulation d’un grand nombre de scénario.

nb=1;
for puissance_max_ptg=[125.0,150.5,175.0,200.0,225.0,250.0,300.0,400.0,500.0]%[3.0,7.5,10.0,15.0,20.0,25.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0]
    for margin=[0.01,0.05,0.1,0.2]
        for season = [0,1]
            close all
            clearvars -except nb puissance_max_ptg margin season
            disp(puissance_max_ptg)
            disp(margin)
            disp(season)
            etude_congestion_several
            nb=nb+1;
        end
    end
end