function mpc = etudeaffinepq
%Modélisation du réseau électrique dans la région de Troyes (Sézanne, Mery
%sur-Seine, Arcis-sur-Aube, Fère-champenoise). 


%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;




%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0	0	0	0	1	1	0	225	1	1.1	0.9;
	2	1	20	9.6	0	0	1	1	0	90	1	1.1	0.9;
	3	1	2.3	1.1	0	0	1	1	0	90	1	1.1	0.9;
	4   1	6.6	3.19	0	0	1	1	0	90	1	1.1	0.9;
    5	1	4.4	2.112	0	0	1	1	0	90	1	1.1	0.9;
	6	1	13.2+40	6.336	0	0	1	1	0	90	1	1.1	0.9;
	7	1	7.2	3.456	0	0	1	1	0	90	1	1.1	0.9;
	8   1	14.4	6.9	0	0	1	1	0	90	1	1.1	0.9;
];


%Le noeud bilan est le bus 1 (transformateur 225/90 kv)

%On considère ensuite des noeuds PQ

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0	0	0	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
	2	0.5	0	0.37	-0.37	1	0.5	1	0.5	0	0	0	0	0	0	0	0	0	0	0	0;
	3	10	0	66	-66	1	97	1	87	0	0	0	0	0	0	0	0	0	0	0	0;
	4	12	0	18.75	-18.75	1	28	1	25	0	0	0	0	0	0	0	0	0	0	0	0;
    5	20	0	83	-83	1	80	1	109	0	0	0	0	0	0	0	0	0	0	0	0;
	6	15 0	75	-75	1	122	1	100	0	0	0	0	0	0	0	0	0	0	0	0;
	7	12	0	80	-80	1	118	1	106	0	0	0	0	0	0	0	0	0	0	0	0;
	8	5  0	54	-54	1	80	1	72	0	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.0018*9.5	0.0048*9.5	0.000290*9.5	78	78	78	0	0	1	-360	360;
	2	3	0.0018*15.5	0.0048*15.5	0.000290*15.5	78	78	78	0	0	1	-360	360;
	3	4	0.0018*7	0.0048*7	0.000290*7	78	78	78	0	0	1	-360	360;
	4	5	0.0018*7.4	0.0048*7.4	0.000290*7.4	78	78	78	0	0	1	-360	360;
    5	6	0.0018*28.2	0.0048*28.2	0.000290*28.2	78	78	78	0	0	1	-360	360;
	6	7	0.0018*13.8	0.0048*13.8	0.000290*13.8	78	78	78	0	0	1	-360	360;
	7	8	0.0018*28.6	0.0048*28.6	0.000290*28.6	78	78	78	0	0	1	-360	360;
	8	5	0.0018*19.8	0.0048*19.8	0.000290*19.8	78	78	78	0	0	1	-360	360;]