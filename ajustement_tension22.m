for z = 0:1:7
    pmax(z+1)=mpc2.gen(z+1,PMAX);
end
 
for l = 0:7
    res1 = result2.bus(l+1,VM);
    volt(l+1)=res1;
    for p = 1:length(volt) %Réglage de la puissance réactive pour diminiuer ou augmenter la tension
        if volt(p)<0.95
            mpc2.gen(p,QG)= (tan(acos(cos_phi))-0.15)*mpc2.gen(p,PMAX);
            disp('===========================================')
            disp('Réglage de la tension')
            disp('------------------')
            disp(['Tension trop basse au noeud ', num2str(p),' avec une tension de ', num2str(result2.bus(p,VM))]);          
            result2 = runpf(mpc2);
            res1 = result2.bus(l+1,VM);
            volt(l+1)=res1;
        end
        if volt(p)>1.07
            mpc2.gen(p,QG)= -(tan(acos(cos_phi))-0.15)*mpc2.gen(p,PMAX);
            disp('===========================================')
            disp('Réglage de la tension')
            disp('------------------')
            disp(['Tension trop haute au noeud ', num2str(p),' avec une tension de ', num2str(result2.bus(p,VM))]);          
            result2 = runpf(mpc2);
            res1 = result2.bus(l+1,VM);
            volt(l+1)=res1;
        end
    end
    res2 = result2.gen(l+1,QG);
    reactive(l+1)=res2;
end
        
for m = 1:length(reactive)
    reactive_frac(m) = reactive(m)/pmax(m);
end