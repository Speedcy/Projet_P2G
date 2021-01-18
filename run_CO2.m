original_T = readtable('save_results_with_CO2.txt');
original_T.Properties.VariableNames = {'season','alpha','beta','gamma','loss','surplus','power_ptg','loss2','surplus2','power_gaz','Ctot_gaz','stock','CO2_evite'};

T=original_T(original_T.season==1,:);

k=height(T);
while k<=120
    disp(k)
    clearvars -except k
    season=1;
    initialisation_matrix_several
    k=k+1;
end
