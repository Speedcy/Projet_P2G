function [I_nom] = solve_overdim(I,I_nom,I_max)
% L’ajustement de la puissance réactive pour corriger le plan de tension
% peut causer des surdimensionnements de certaines lignes sur le réseau
% (une augmentation de la section d’une ligne peut ne plus être nécessaire
% suite à une injection de puissance réactive). Ce script permet de
% résoudre ces problèmes de surdimensionnement.

for i=1:length(I_nom)
    if I_nom(i)~=I_max(1) % Si la ligne a été modifiée
        if I(i)<I_max(1)
            I_nom(i)=I_max(1);
        else
            vect=false(length(I_max),1);
            vect(end-1)=1;
            while(I_max(vect)>I(i)) % tant que la ligne est surdimensionné
                vect=I_max==I_nom(i);
                vect=vect(2:end);
                vect(length(vect)+1)=0;
                if I_max(vect)>I(i) % la ligne a été surdimensionnée
                    I_nom(i)=I_max(vect);
                end
            end
        end
    end
end
end

