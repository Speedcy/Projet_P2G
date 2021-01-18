function diag = diagrammepq

clc;
warning off;
define_constants; %Constantes de MatPower

%===========================================

%Tracés des pertes totales, du surplus et du diagramme d'admission
%Sans simulation Monte-Carlo

x=[];
y=[];
reactive=[]; %Tableau contenant les tensions au noeud lors de la simulation
reactive_frac=[]; %Fraction Q/Pmax sur les différentes valeurs de reactive[]
volt=[]; %Tableau contenant les tensions au noeud lors de la simulation
tab=[];
elec_surplus=[];
k= 1;
x2 = 0.35; %coefficient puissance réactive
x3 = 0.2 ; % tan(phi) pour Q=tan(phi)*P
j = 1;


%===========================================


%Simulation sur toute la plage des facteurs de charge
 for i = 0:0.05:1
 
        mpc = loadcase('etudeaffinepq');
        for z = 0:1:7
        y(z+1)=mpc.gen(z+1,PMAX);
        end
        mpc.gen(2,PG)=i*0.5;
        mpc.gen(3,PG)=i*87;
        mpc.gen(4,PG)=i*25;
        mpc.gen(5,PG)=i*110;
        mpc.gen(6,PG)=i*100;
        mpc.gen(7,PG)=i*106;
        mpc.gen(8,PG)=i*72;
        
        
%Puissance réactive maximale 

        mpc.gen(2,QMAX)=x2*mpc.gen(2,PMAX);
        mpc.gen(3,QMAX)=x2*mpc.gen(3,PMAX);
        mpc.gen(4,QMAX)=x2*mpc.gen(4,PMAX);
        mpc.gen(5,QMAX)=x2*mpc.gen(5,PMAX);
        mpc.gen(6,QMAX)=x2*mpc.gen(6,PMAX);
        mpc.gen(7,QMAX)=x2*mpc.gen(7,PMAX);
        mpc.gen(8,QMAX)=x2*mpc.gen(8,PMAX);
        

       
%Puissance réactive minimale 

        mpc.gen(2,QMIN)=-x2*mpc.gen(2,PMAX);
        mpc.gen(3,QMIN)=-x2*mpc.gen(3,PMAX);
        mpc.gen(4,QMIN)=-x2*mpc.gen(4,PMAX);
        mpc.gen(5,QMIN)=-x2*mpc.gen(5,PMAX);
        mpc.gen(6,QMIN)=-x2*mpc.gen(6,PMAX);
        mpc.gen(7,QMIN)=-x2*mpc.gen(7,PMAX);
        mpc.gen(8,QMIN)=-x2*mpc.gen(8,PMAX);
        
    
        result = runpf(mpc);
        tot = result.branch(:,PF)+result.branch(:,PT); 
        s = sum(tot); 
        
        %Extraction du surplus
        surplus = abs(result.gen(1,PG));
    
        x(k)=i; %Tableau contenant les rangs
        tab(k)=s;
        elec_surplus(k)=surplus;
        k=k+1; 
        
        %Réglage de la tension
        for l = 0:7
            res1 = result.bus(l+1,VM);
            volt(l+1)=res1;
            for p = 1:length(volt)
                    if volt(p)<0.95 %Tension trop basse
                        mpc.gen(p,QG)= x3*mpc.gen(p,PMAX); %Fourniture de puissance réactive
                        disp('===========================================')
                        disp('Réglage de la tension')
                        disp('------------------')
                        disp(['Tension trop basse au noeud ', num2str(p),' avec une tension de ', num2str(result.bus(p,VM))]);          
                        result = runpf(mpc);
                        res1 = result.bus(l+1,VM);
                        volt(l+1)=res1;
                    end
                    if volt(p)>1.07 %Tension trop haute
                        mpc.gen(p,QG)= -x3*mpc.gen(p,PMAX); %Absortpion de puissance réactive
                        disp('===========================================')
                        disp('Réglage de la tension')
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
        
        %Calcul de rapport Q/Pmax pour tracer le diagramme d'admission
        
        for m = 1:length(reactive)
            reactive_frac(m) = reactive(m)/y(m);
        end
        

            
        %Tracé des diagrammes d'admission
        
        figure(j)
        for o=1:length(reactive_frac)         
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
            title("Diagramme d'admission RTE")

        end
        
        j=j+1;
        

 end 
    

    

%Diagramme de perte

figure(2)
plot(x,tab)
axis([0 1 0 100]);
title('Pertes en fonction du facteur de charge des éoliennes')
xlabel('Facteur de charge des éoliennes')
ylabel('Puissance active perdue (MW)')

%Diagramme de surplus

figure(3)
plot(x,elec_surplus)
title("Surplus d'électricité en fonction du facteur de charge des éoliennes")
xlabel('Facteur de charge des éoliennes')
ylabel('Valeur absolue de la puissance active de compensation (MW)')
           
        




    
    
end 