% Ajustement de plan de tension via l�injection de puissance r�active : si
% la tension d�un n�ud du r�seau est en dehors de la plage de variation
% acceptable, la puissance r�active en ce n�ud du r�seau est ajust�e afin
% d�obtenir un plan de tension convenable.
% Pour le r�seau sans PtG

for z = 0:1:7
    pmax(z+1)=mpc.gen(z+1,PMAX);
end
 
for l = 0:7
    res1 = result.bus(l+1,VM);
    volt(l+1)=res1;
    for p = 1:length(volt) %R�glage de la puissance r�active pour diminiuer ou augmenter la tension
        if volt(p)<0.95 % Si la tension est trop basse (inf�rieure � 95% de la tension nominale)
            mpc.gen(p,QG)= (tan(acos(cos_phi))-0.15)*mpc.gen(p,PMAX);
            disp('===========================================')
            disp('R�glage de la tension')
            disp('------------------')
            disp(['Tension trop basse au noeud ', num2str(p),' avec une tension de ', num2str(result.bus(p,VM))]);          
            result = runpf(mpc);
            res1 = result.bus(l+1,VM);
            volt(l+1)=res1;
        end
        if volt(p)>1.07 % Si la tension est trop grande (sup�rieure � 107
        % % de la tension nominale)
            mpc.gen(p,QG)= -(tan(acos(cos_phi))-0.15)*mpc.gen(p,PMAX);
            disp('===========================================')
            disp('R�glage de la tension')
            disp('------------------')
            disp(['Tension trop haute au noeud ', num2str(p),' avec une tension de ', num2str(result.bus(p,VM))]);          
            result = runpf(mpc);
            res1 = result.bus(l+1,VM);
            volt(l+1)=res1;
        end
    end
    res2 = result.gen(l+1,QG);
    reactive(l+1)=res2;
end
        
for m = 1:length(reactive)
    reactive_frac(m) = reactive(m)/pmax(m);
end