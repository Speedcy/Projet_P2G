
% Si la puissance r�active a �t� ajust�e afin d'obtenir un plan de tension
% valide, il est possible que des lignes ait �t� surdimensionn�
% Ce script permet de r�soudre ces probl�mes de surdimensionnement

for i=1:length(I_nom)
    if I_nom(i)~=lignes_data.I_max(1) % Si la ligne a �t� modifi�e
        if I(i)<lignes_data.I_max(1)
            I_nom(i)=lignes_data.I_max(1);
        else
            vect=false(height(lignes_data),1);
            vect(end-1)=1;
            while(lignes_data.I_max(vect)>I(i)) % tant que la ligne est surdimensionn�
                vect=lignes_data.I_max==I_nom(i);
                vect=vect(2:end);
                vect(length(vect)+1)=0;
                if lignes_data.I_max(vect)>I(i) % la ligne a �t� surdimensionn�e
                    I_nom(i)=lignes_data.I_max(vect);
                end
            end
        end
    end
end
            