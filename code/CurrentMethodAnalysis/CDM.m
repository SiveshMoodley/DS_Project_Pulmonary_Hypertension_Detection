clear
clc

%% Importing Data
% Import Pulmonary Artery to Aorta Ratio (PA:A) data
fileID = fopen('PAA__Data.txt','r');
formatspec = '%f';
PAA = fscanf(fileID,formatspec);

% Import mPAP data for PA:A
fileID2 = fopen('PAAmPAP__Data.txt','r');
formatspec2 = '%f';
PAAmPAP = fscanf(fileID2,formatspec2); % numerical vector of mPaP data

% Import Pulmonary Hypertension classification for PA:A
fileID3 = fopen('PAAph__Data.txt','r');
formatspec3 = '%f';
PAAph = fscanf(fileID3,formatspec3); % numerical vector of mPaP data

% Import Wood Resisitance PVR data
fileID4 = fopen('PVR__Data.txt','r');
formatspec4 = '%f';
PVR = fscanf(fileID4,formatspec4);

% Import mPAP data for PVR
fileID5 = fopen('PVRmPAP__Data.txt','r');
formatspec5 = '%f';
PVRmPAP = fscanf(fileID5,formatspec5); % numerical vector of mPaP data

% Import Pulmonary Hypertension classification for PVR
fileID6 = fopen('PVRph__Data.txt','r');
formatspec6 = '%f';
PVRph = fscanf(fileID6,formatspec6); % numerical vector of mPaP data

%% Indexing Data
% Create tables of the data
PAAt = table(PAA,PAAmPAP,PAAph);
PAAt.Properties.VariableNames = ["PA:A","mPAP","PH Index"];

PVRt = table(PVR,PVRmPAP,PVRph);
PVRt.Properties.VariableNames = ["PVR","mPAP","PH Index"];

% Indexing for Postive PH
idx = PAAt.("PH Index") == 1;
posPAA = table2array(PAAt(idx,:));

idx = PVRt.("PH Index") == 1;
posPVR = table2array(PVRt(idx,:));

% Indexing for actual correctley classified patients
idx = PAAt.("PH Index") == 1 & PAAt.("PA:A") >= 1 & PAAt.("mPAP") >= 25;
PAsucPPAt25 = PAAt(idx,:);

idx = PAAt.("PH Index") == 0 & PAAt.("PA:A") < 1 & PAAt.("mPAP") < 25;
NAsucPPAt25 = PAAt(idx,:);

idx = PAAt.("PH Index") == 1 & PAAt.("PA:A") >= 1 & PAAt.("mPAP") >= 20;
PAsucPPAt20 = PAAt(idx,:);

idx = PAAt.("PH Index") == 0 & PAAt.("PA:A") < 1 & PAAt.("mPAP") < 20;
NAsucPPAt20 = PAAt(idx,:);

idx = PVRt.("PH Index") == 1 & PVRt.("PVR") >= 3 & PVRt.("mPAP") >= 20;
PAsucPVRt = PVRt(idx,:);

idx = PVRt.("PH Index") == 0 & PVRt.("PVR") < 3 & PVRt.("mPAP") < 20;
NAsucPVRt = PVRt(idx,:);

% Indexing for theoretically correctly classified patients
idx = PAAt.("PA:A") >= 1 & PAAt.("mPAP") >= 25;
PTsucPPAt25 = PAAt(idx,:);

idx = PAAt.("PA:A") < 1 & PAAt.("mPAP") < 25;
NTsucPPAt25 = PAAt(idx,:);

idx = PAAt.("PA:A") >= 1 & PAAt.("mPAP") >= 20;
PTsucPPAt20 = PAAt(idx,:);

idx = PAAt.("PA:A") < 1 & PAAt.("mPAP") < 20;
NTsucPPAt20 = PAAt(idx,:);

idx = PVRt.("PVR") >= 3 & PVRt.("mPAP") >= 20;
PTsucPVRt = PVRt(idx,:);

idx = PVRt.("PVR") < 3 & PVRt.("mPAP") < 20;
NTsucPVRt = PVRt(idx,:);

%% Calculating actual and theoretical classifying success rates
% Obtain total number of patients
PPAnumPatients = height(PAAt);
PVRnumPatients = height(PVRt);

% Obtain number actual successful classifications
PPAsucA25 = height(PAsucPPAt25) + height(NAsucPPAt25);
PPAsucA20 = height(PAsucPPAt20) + height(NAsucPPAt20);
PVRsucA = height(PAsucPVRt) + height(NAsucPVRt);

% Obtain number of theoretical successful classifications
PPAsucT25 = height(PTsucPPAt25) + height(NTsucPPAt25);
PPAsucT20 = height(PTsucPPAt20) + height(NTsucPPAt20);
PVRsucT = height(PTsucPVRt) + height(NTsucPVRt);

% Calculate actual successful classification percentages
PPApercentA25 = 100 * (PPAsucA25 / PPAnumPatients);
PPApercentA20 = 100 * (PPAsucA20 / PPAnumPatients);
PVRpercentA = 100 * (PVRsucA / PVRnumPatients);

% Calculate theoretical successful classification percentages
PPApercentT25 = 100 * (PPAsucT25 / PPAnumPatients);
PPApercentT20 = 100 * (PPAsucT20 / PPAnumPatients);
PVRpercentT = 100 * (PVRsucT / PVRnumPatients);

% Create table
cPHc = ["PA:A @ mPAP = 25mmHg";"PA:A @ mPAP = 20mmHg";"Pulmonary Vascular Resistance"];
percentagesA = [PPApercentA25;PPApercentA20;PVRpercentA];
percentagesT = [PPApercentT25;PPApercentT20;PVRpercentT];
T = table(cPHc,percentagesA,percentagesT);
T.Properties.VariableNames = ["Current PH Classifying Methods"," Actual Successful Classification Rate (%)"," Theoretical Successful Classification Rate (%)"];

% Bar Chart Calcs
idx = PAAt.("PH Index") == 1 & PAAt.("PA:A") >= 1;
PAA25TP = height(PAAt(idx,:));

idx = PAAt.("PH Index") == 0 & PAAt.("PA:A") < 1;
PAA25TN = height(PAAt(idx,:));

idx = PAAt.("PH Index") == 0 & PAAt.("PA:A") >= 1;
PAA25FP = height(PAAt(idx,:));

idx = PAAt.("PH Index") == 1 & PAAt.("PA:A") < 1;
PAA25FN = height(PAAt(idx,:));

PAA25suc = PAA25TP + PAA25TN;
PAA25unsuc = PAA25FP + PAA25FN;
PAA25sucP = 100 * (PAA25suc/PPAnumPatients);

PAA25sens = PAA25TP / (PAA25TP + PAA25FN);
PAA25spec = PAA25TN / (PAA25TN + PAA25FP);

idx = PVRt.("PH Index") == 1 & PVRt.("PVR") >= 3;
PVR25TP = height(PVRt(idx,:));

idx = PVRt.("PH Index") == 0 & PVRt.("PVR") < 3;
PVR25TN = height(PVRt(idx,:));

idx = PVRt.("PH Index") == 0 & PVRt.("PVR") >= 3;
PVR25FP = height(PVRt(idx,:));

idx = PVRt.("PH Index") == 1 & PVRt.("PVR") < 3;
PVR25FN = height(PVRt(idx,:));

PVR25suc = PVR25TP + PVR25TN;
PVR25unsuc = PVR25FP + PVR25FN;
PVR25sucP = 100 * (PVR25suc/PVRnumPatients);

PVR25sens = PVR25TP / (PVR25TP + PVR25FN);
PVR25spec = PVR25TN / (PVR25TN + PVR25FP);

%% Plot scatter graphs
% Define PH classifiers
mPAPcutoff = [25;20];
PAAcutoff = 1;
PVRcutoff = 3;

% PA:A
% PA:A Ratio @ mPAP = 25mmHg
figure(1)
scatter(PAAmPAP,PAA,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
hold on
box on
grid, grid minor
scatter(posPAA(:,2),posPAA(:,1),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
xline(mPAPcutoff(1),'r-.','LineWidth',1.25)
yline(PAAcutoff,'k--','LineWidth',1.25)
title("Patients Pulmonary Artery : Aorta Diameters Ratio (PA:A) and their Mean Pulmonary Artery Pressure (mPAP)",'interpreter','latex')
subtitle("Pulmonary Hypertension Classification, mPAP = 25mmHg",'interpreter','latex')
xlabel("mPAP (mmHg)",'interpreter','latex')
ylabel("PA:A",'interpreter','latex')
xlim([10 70])
ylim([0.5 1.5])
legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Pulmonary Hypertension PA:A Classification Line",'interpreter','latex','Location','southeast')
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])

% PA:A Ratio @ mPAP = 20mmHg
figure(2)
scatter(PAAmPAP,PAA,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
hold on
box on
grid, grid minor
scatter(posPAA(:,2),posPAA(:,1),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
xline(mPAPcutoff(2),'r-.','LineWidth',1.25)
yline(PAAcutoff,'k--','LineWidth',1.25)
title("Patients Pulmonary Artery : Aorta Diameters Ratio (PA:A) and their Mean Pulmonary Artery Pressure (mPAP)",'interpreter','latex')
subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
xlabel("mPAP (mmHg)",'interpreter','latex')
ylabel("PA:A",'interpreter','latex')
xlim([10 70])
ylim([0.5 1.5])
legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Pulmonary Hypertension PA:A Classification Line",'interpreter','latex','Location','southeast')
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])

% PVR
figure(3)
scatter(PVRmPAP,PVR,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
hold on
box on
grid, grid minor
scatter(posPVR(:,2),posPVR(:,1),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
xline(mPAPcutoff(2),'r-.','LineWidth',1.25)
yline(PVRcutoff,'k--','LineWidth',1.25)
title("Patients Pulmonary Vascular Resistance (PVR) and their Mean Pulmonary Artery Pressure (mPAP)",'interpreter','latex')
subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
xlabel("mPAP (mmHg)",'interpreter','latex')
ylabel("PVR (Wood Units)",'interpreter','latex')
xlim([10 70])
ylim([0 15])
legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Pulmonary Hypertension PVR Classification Line",'interpreter','latex','Location','southeast')
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])

%% Effective AUCROC Values
% Define new tables of the data
paaT = table(PAAmPAP,PAA);
paaT.Properties.VariableNames = ["mPAP","Amount"];

pvrT = table(PVRmPAP,PVR);
pvrT.Properties.VariableNames = ["mPAP","Amount"];

% Find min and max PA:A and PVR values in Data
lPAA = floor(min(PAA));
uPAA = ceil(max(PAA));

lPVR = floor(min(PVR));
uPVR = ceil(max(PVR));

% PA:A
for mPAPc = 20:5:25
        
    % Set inital conditons
    PAAc(1) = lPAA;
    [SpecPAA(1,:),SensPAA(1,:),PrcnPAA(1,:),ReclPAA(1,:)] = ROCcdm(paaT,mPAPc,PAAc(1));

    % Step Variable
    n = 1;
    while PAAc(n) <= uPAA

        % Increment Input
        PAAc(n+1) = PAAc(n) + 0.01;

        % Apply ROC to extract specificity and sensitivity vector
        [SpecPAA(n+1,:),SensPAA(n+1,:),PrcnPAA(n+1,:),ReclPAA(n+1,:)] = ROCcdm(paaT,mPAPc,PAAc(n+1));

        n = n+1;

    end

    PAAspec = SpecPAA(1:n,1);
    PAAsens = SensPAA(1:n,1);
    PAAprcn = PrcnPAA(1:n,1);
    PAArecl = ReclPAA(1:n,1);
    BC = 0.5;

    % Plot graphs
    figure(mPAPc)
    plot(PAAspec,PAAsens,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
    hold on
    plot([0;1],[0;1],'--k','LineWidth',1.25)
    box on
    grid, grid minor
    title("PA:A Effective Receiver Operating Characteristic Curve",'interpreter','latex')
    subtitle(strjoin(["Pulmonary Hypertension Classification, mPAP = ",num2str(mPAPc),"mmHg"]),'interpreter','latex')
    xlabel("1 - Specificity",'interpreter','latex')
    ylabel("Sensitivity",'interpreter','latex')
    legend("","Random Classification Line",'interpreter','latex','Location','southeast')
    xlim([0 1])
    ylim([0 1])
    set(gca,'TickLabelInterpreter','latex')
    set(gcf,'Position',[600 400 800 400])

        figure(mPAPc*10)
        plot(PAArecl,PAAprcn,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
        hold on
        box on
        grid, grid minor
        yline(BC,'--k','LineWidth',1.25)
        title("PA:A Effective Precision Recall Curve",'interpreter','latex')
        subtitle(strjoin(["Pulmonary Hypertension Classification, mPAP = ",num2str(mPAPc),"mmHg"]),'interpreter','latex')
        xlabel("Recall",'interpreter','latex')
        ylabel("Precision",'interpreter','latex')
        xlim([0 1])
        ylim([0 1])
        legend("","Baseline Classifier Line",'interpreter','latex','Location','southeast')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])    

    % Calculate Area Under Curve for ROC curve (AUCROC)
    AUC(mPAPc,1) = abs(trapz(PAAspec,PAAsens));

    % Calculate Area Under Curve for ROC curve (AUCROC)
    PRC(mPAPc,1) = abs(trapz(PAArecl,PAAprcn));

end

% PVR
% Set inital conditons
PVRc(1) = lPVR;
mPAPc = 20;
[SpecPVR(1,:),SensPVR(1,:),PrcnPVR(1,:),ReclPVR(1,:)] = ROCcdm(pvrT,mPAPc,PVRc(1));

% Step Variable
n = 1;
while PVRc(n) <= uPVR

    % Increment Input
    PVRc(n+1) = PVRc(n) + 0.01;

    % Apply ROC to extract specificity and sensitivity vector
    [SpecPVR(n+1,:),SensPVR(n+1,:),PrcnPVR(n+1,:),ReclPVR(n+1,:)] = ROCcdm(pvrT,mPAPc,PVRc(n+1));

    n = n+1;

end

PVRspec = SpecPVR;
PVRsens = SensPVR;
PVRprcn = PrcnPVR;
PVRrecl = ReclPVR;

% Plot graphs
figure(4)
plot(PVRspec,PVRsens,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
hold on
plot([0;1],[0;1],'--k','LineWidth',1.25)
box on
grid, grid minor
title("PVR Effective Receiver Operating Characteristic Curve",'interpreter','latex')
subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
xlabel("1 - Specificity",'interpreter','latex')
ylabel("Sensitivity",'interpreter','latex')
legend("","Random Classification Line",'interpreter','latex','Location','southeast')
xlim([0 1])
ylim([0 1])
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])

        figure(5)
        plot(PVRrecl,PVRprcn,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
        hold on
        box on
        grid, grid minor
        yline(BC,'--k','LineWidth',1.25)
        title("PVR Effective Precision Recall Curve",'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
        xlabel("Recall",'interpreter','latex')
        ylabel("Precision",'interpreter','latex')
        xlim([0 1])
        ylim([0 1])
        legend("","Baseline Classifier Line",'interpreter','latex','Location','southeast')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

% Calculate Area Under Curve for ROC curve (AUCROC)
AUC(3,1) = abs(trapz(PVRspec,PVRsens));

% Calculate Area Under Curve for ROC curve (AUCROC)
PRC(3,1) = abs(trapz(PVRrecl,PVRprcn));

% Add AUC-PRC-AUCROC data to table
AUCROC = [AUC(25,1);AUC(20,1);AUC(3,1)];
T.("AUCROC Value") = AUCROC;

AUCPRC = [PRC(25,1);PRC(20,1);PRC(3,1)];
T.("AUC-PRC Value") = AUCPRC;

% Add Sensitivity and Specificity
[SpecPAAd,SensPAAd,~,~] = ROCcdm(paaT,25,1);
[SpecPVRd,SensPVRd,~,~] = ROCcdm(pvrT,20,3);

Sensitivity = [SensPAAd;0;SensPVRd];
T.("Sensitivity") = Sensitivity;

Specificity = [1-SpecPAAd;0;1-SpecPVRd];
T.("Specificity") = Specificity;

disp(T)


%% Bar Charts
x = {'Patients Successfully Classified' 'Patients Unsuccessfully Classified'};
% PAA mPAP=25
figure(6)
barPAA25 = [PAA25suc PAA25TP PAA25TN; PAA25unsuc PAA25FN PAA25FP];
b1 = bar(barPAA25,'FaceColor','flat');
b1(1).FaceColor = [0.4940 0.1840 0.5560];
b1(2).FaceColor = [0.6350 0.0780 0.1840];
b1(3).FaceColor = [0 0.4470 0.7410];
box on
grid minor
xticklabels(x)
ylabel("No.",'interpreter','latex')
ylim([0 25])
title("Current PH Diagnostic Methods Performance - PAA",'interpreter','latex')
legend("Healthy and Diagnosed Patients","Patients with Pulmonary Hypertension","Healthy Patients",'interpreter','latex')
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])
str = {strjoin(["Successful Classification Rate: ",num2str(PAA25sucP),"\%"])};
annotation('textbox',[0.68 0.65 0.1 0.1],'Interpreter','latex','String',str,'BackgroundColor','w','FitBoxToText','on','HorizontalAlignment','center')

xtips1 = b1(1).XEndPoints;
ytips1 = b1(1).YEndPoints;
labels1 = string(b1(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex')

xtips2 = b1(2).XEndPoints;
ytips2 = b1(2).YEndPoints;
labels2 = string(b1(2).YData);
text(xtips2,ytips2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex')

xtips3 = b1(3).XEndPoints;
ytips3 = b1(3).YEndPoints;
labels3 = string(b1(3).YData);
text(xtips3,ytips3,labels3,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex')

% PVR
figure(7)
barPVR25 = [PVR25suc PVR25TP PVR25TN; PVR25unsuc PVR25FN PVR25FP];
b1 = bar(barPVR25,'FaceColor','flat');
b1(1).FaceColor = [0.4940 0.1840 0.5560];
b1(2).FaceColor = [0.6350 0.0780 0.1840];
b1(3).FaceColor = [0 0.4470 0.7410];
box on
grid minor
xticklabels(x)
ylabel("No.",'interpreter','latex')
ylim([0 85])
title("Current PH Diagnostic Methods Performance - PVR",'interpreter','latex')
legend("Healthy and Diagnosed Patients","Patients with Pulmonary Hypertension","Healthy Patients",'interpreter','latex')
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])
str = {strjoin(["Successful Classification Rate: ",num2str(PVR25sucP),"\%"])};
annotation('textbox',[0.68 0.65 0.1 0.1],'Interpreter','latex','String',str,'BackgroundColor','w','FitBoxToText','on','HorizontalAlignment','center')

xtips1 = b1(1).XEndPoints;
ytips1 = b1(1).YEndPoints;
labels1 = string(b1(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex')

xtips2 = b1(2).XEndPoints;
ytips2 = b1(2).YEndPoints;
labels2 = string(b1(2).YData);
text(xtips2,ytips2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex')

xtips3 = b1(3).XEndPoints;
ytips3 = b1(3).YEndPoints;
labels3 = string(b1(3).YData);
text(xtips3,ytips3,labels3,'HorizontalAlignment','center','VerticalAlignment','bottom','Interpreter','latex')