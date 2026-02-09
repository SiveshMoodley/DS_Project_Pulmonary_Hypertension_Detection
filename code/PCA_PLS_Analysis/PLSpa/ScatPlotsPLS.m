function [AUCROCPRC,YIcsr,Rcsr,PVDt,newSRCC,csr] = ScatPlotsPLS(numModes,mPAP,scores,mPAPcutoff,PercentVar,PHclass)

% Calculate Spearman's Rank Correlation Coefficient for all modes
for i = 1:numModes

    SRCC(i,1) = i;
    [rho,pval] = corr(mPAP,scores(:,i),'Type','Spearman');
    SRCC(i,2) = rho;
    SRCC(i,3) = pval;

end

% Convert Arrays to a Table
SRCC = array2table(SRCC, 'VariableNames', ["PLS Shape Mode No.","Spearman's Rank Correlation Coefficient","Spearman's P-Value"]);

%% Indexing for meeting correlation requirements
% Index SRCC table for SRCC >= 0.3 & SRCC <= -0.3
idx = SRCC.("Spearman's Rank Correlation Coefficient") >= 0.3 | SRCC.("Spearman's Rank Correlation Coefficient") <= -0.3;
newSRCC = SRCC(idx,:);

% Index new SRCC table for P-Value <=0.05
idx = newSRCC.("Spearman's P-Value") <= 0.05;
newSRCC = newSRCC(idx,:);

% Define number of shape modes which have met the conditions
H = height(newSRCC);

% Error message if no modes are found
if H ==0
    msg = "No significant PLS shape modes were found to correlate to Pulmonary Hypertension.";
    error(msg)
end

%% Receiver Operating Characteristic mPAP classification = 25mmHg
% Receiver Operating Characteristic
for i = 1:H

    % Index for Shape Mode Number
    SM = table2array(newSRCC(i,1));
    SMn(i,1) = SM;

    L = floor(min(scores(:,SM))); % Finds least Shape Mode Amount
    U = ceil(max(scores(:,SM))); % Finds most Shape Mode Amount
    d = log10((U - L)); % Find the power of 10 magnitude of the difference between the values

    % Defining increment amount based of shape mode magnitudes
    if d >= 2
        e = 1;
    else 
        e = 0.01;
    end

    smA = scores(:,SM); % Define shape mode amount vector
    T = table(mPAP,smA,PHclass); % Create table of mPAP and SM amount

    % Define Correlation as Positive (1) or Negative (0)
    PN = table2array(newSRCC(i,2));
    if PN >= 0
        C = 1;
    else
        C = 0;
    end

    %% ROC step function (Vary Shape Mode Classifying Amount)
    % Set inital conditions
    SMAc(1) = L;
    MpapC = mPAPcutoff;
    [Spec(1,:),Sens(1,:),J(1,:),SRa(1,:),SRt(1,:),Prcn(1,:),Recl(1,:),Fb(1,:)] = ROC(T,MpapC,SMAc(1),C);

    % Step Variable
    n = 1;
    while SMAc(n) <= U

        % Increment Input
        SMAc(n+1) = SMAc(n) + e;
        
        % Apply ROC to extract specificity and sensitivity vector
        [Spec(n+1,:),Sens(n+1,:),J(n+1,:),SRa(n+1,:),SRt(n+1,:),Prcn(n+1,:),Recl(n+1,:),Fb(n+1,:)] = ROC(T,MpapC,SMAc(n+1),C);

        n = n+1;

    end

    %% Youden's Index Calculations
    % Find Youden's Index
    j = J(1:n,1);
    spec = Spec(1:n,1);
    sens = Sens(1:n,1);
    prcn = Prcn(1:n,1);
    recl = Recl(1:n,1);
    fb = Fb(1:n,1);

    cutO = max(fb);
    cutI = find(fb==cutO);

    YI = max(j);
    YIi = find(j==YI);   
  
    if C == 1
        SMAcutoff = min(SMAc(YIi)); % Finds the YI shape mode amount cutoff
    else
        SMAcutoff = max(SMAc(YIi)); % Finds the YI shape mode amount cutoff
    end

    smaCut = median(SMAc(cutI));

    ROCx = [0;1];
    ROCy = [0;1];

    % Random Classifier Line
    p = polyfit(ROCx,ROCy,1);
    RCLx = linspace(0,1,n)';    
    RCLy = polyval(p,RCLx);
    BC = 0.5;

    % Data points for vertical line
    vl = polyval(p,spec);
    YIx = [spec(YIi);spec(YIi)];
    YIy = [vl(YIi);sens(YIi)];
    
    % Data points for F1 score
    fbx = recl(max(cutI));
    fby = prcn(max(cutI));

    % PRC vertical line
    if C == 1
        recl(2:n+1,:) = recl;
        recl(1,:) = 1;
        prcn(2:n+1,:) = prcn;
        prcn(1,:) = 0.5;
    else
        recl(n+1,:) = 1;
        prcn(n+1,:) = 0.5;
    end
    
    %% Determine Actual and Theoretical Success Rates
    % Actual Success Rate
    srA = SRa(1:n,1);
    SucRateA(i,1) = 100 * max(srA(YIi));

    % Theoretical Success Rate
    srT = SRt(1:n,1);
    SucRateT(i,1) = 100 * max(srT(YIi));

    %% Indexing for Pulmonary Hypertension Diagnosed Patients
    % Indexing for positive PH
    idx = T.PHclass == 1;
    PosPs = table2array(T(idx,:));

    %% Plotting Graphs
    if mPAPcutoff == 25
        % Plot Receiver Operating Characterisitc curve graph
        figure(i*25)
        plot(spec,sens,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
        hold on
        box on
        grid, grid minor
        plot(RCLx,RCLy,'k--','LineWidth',1.25)
        plot(YIx,YIy,'r-.','LineWidth',1.25)
        title(strjoin(["PLS Shape Mode ",num2str(SM)," Receiver Operating Characteristic Curve"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 25mmHg",'interpreter','latex')
        xlabel("1 - Specificity",'interpreter','latex')
        ylabel("Sensitivity",'interpreter','latex')
        xlim([0 1])
        ylim([0 1])
        legend("","Random Classifier Line","Youden's Index (J Statistic)",'interpreter','latex','Location','southeast')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

        % Calculate Area Under Curve for ROC curve (AUCROC)
        AUC(i,1) = abs(trapz(spec,sens));

        % Plot Scatter Graphs
        figure(i*250)
        scatter(mPAP,scores(:,SM),'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        hold on
        box on
        grid, grid minor
        scatter(PosPs(:,1),PosPs(:,2),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
        xline(mPAPcutoff,'--r','LineWidth',1.25)
        yline(SMAcutoff,'--k','LineWidth',1.25)
        title(strjoin(["Quantity of PLS Shape Mode ",num2str(SM)," in each Patient and their associated Mean Pulmonary Artery Pressure"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 25mmHg",'interpreter','latex')
        xlabel("mPAP (mmHg)",'interpreter','latex')
        ylabel("PLS Shape Mode Quantity",'interpreter','latex')
        xlim([10 70])
        legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Youden's Index Shape Mode Classification Line",'interpreter','latex')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

    else
        % Plot Receiver Operating Characterisitc curve graph
        figure(i*20)
        plot(spec,sens,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
        hold on
        box on
        grid, grid minor
        plot(RCLx,RCLy,'k--','LineWidth',1.25)
        plot(YIx,YIy,'r-.','LineWidth',1.25)
        title(strjoin(["PLS Shape Mode ",num2str(SM)," Receiver Operating Characteristic Curve"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
        xlabel("1 - Specificity",'interpreter','latex')
        ylabel("Sensitivity",'interpreter','latex')
        xlim([0 1])
        ylim([0 1])
        legend("","Random Classifier Line","Youden's Index (J Statistic)",'interpreter','latex','Location','southeast')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

        % Calculate Area Under Curve for ROC curve (AUCROC)
        AUC(i,1) = abs(trapz(spec,sens));
        
        % Plot Scatter Graphs
        figure(i*200)
        scatter(mPAP,smA,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        hold on
        box on
        grid, grid minor
        scatter(PosPs(:,1),PosPs(:,2),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
        xline(mPAPcutoff,'--r','LineWidth',1.25)
        yline(SMAcutoff,'--k','LineWidth',1.25)
        title(strjoin(["Quantity of PLS Shape Mode ",num2str(SM)," in each Patient and their associated Mean Pulmonary Artery Pressure"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
        xlabel("mPAP (mmHg)",'interpreter','latex')
        ylabel("PLS Shape Mode Quantity",'interpreter','latex')
        xlim([10 70])
        legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Youden's Index Shape Mode Classification Line",'interpreter','latex')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

    end

    %% Move Shape Mode Amount Cutoff and find new Actual and Successfull Classification Rates
    % Run ROC function to get successful classification rates
    [~,~,~,SCRa,SCRt,~,~,~] = ROC(T,MpapC,smaCut,C);
    scrA(i,1) = SCRa;
    scrT(i,1) = SCRt;

    % Plot PRC graphs
    if mPAPcutoff == 25
        % Plot Receiver Operating Characterisitc curve graph
        figure(i*25000)
        plot(recl,prcn,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
        hold on
        box on
        grid, grid minor
        yline(BC,'--k','LineWidth',1.25)
        scatter(fbx,fby,'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840],'LineWidth',1.25)
        title(strjoin(["PLS Shape Mode ",num2str(SM)," Precision Recall Curve"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 25mmHg",'interpreter','latex')
        xlabel("Recall",'interpreter','latex')
        ylabel("Precision",'interpreter','latex')
        xlim([0 1])
        ylim([0 1])
        legend("","Baseline Classifier Line","Maximum F$B$ Score",'interpreter','latex','Location','southeast')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

        % Calculate Area Under Curve for ROC curve (AUCROC)
        PRC(i,1) = abs(trapz(recl,prcn));
        
        % Plot Scatter Graphs
        figure(i*2500)
        scatter(mPAP,scores(:,SM),'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        hold on
        box on
        grid, grid minor
        scatter(PosPs(:,1),PosPs(:,2),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
        xline(mPAPcutoff,'--r','LineWidth',1.25)
        yline(smaCut,'--k','LineWidth',1.25)
        xlim([10 70])
        title(strjoin(["Quantity of PLS Shape Mode ",num2str(SM)," in each Patient and their associated Mean Pulmonary Artery Pressure"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 25mmHg",'interpreter','latex')
        xlabel("mPAP (mmHg)",'interpreter','latex')
        ylabel("PLS Shape Mode Quantity",'interpreter','latex')
        legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","F$B$ Shape Mode Classification Line",'interpreter','latex')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

    else
        % Plot Receiver Operating Characterisitc curve graph
        figure(i*20000)
        plot(recl,prcn,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
        hold on
        box on
        grid, grid minor
        yline(BC,'--k','LineWidth',1.25)
        scatter(fbx,fby,'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840],'LineWidth',1.25)
        title(strjoin(["PLS Shape Mode ",num2str(SM)," Precision Recall Curve"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
        xlabel("Recall",'interpreter','latex')
        ylabel("Precision",'interpreter','latex')
        xlim([0 1])
        ylim([0 1])
        legend("","Baseline Classifier Line","Maximum F$B$ Score",'interpreter','latex','Location','southeast')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

        % Calculate Area Under Curve for PRC curve (PRC-ROC)
        PRC(i,1) = abs(trapz(recl,prcn));

        % Plot Scatter Graphs
        figure(i*2000)
        scatter(mPAP,smA,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        hold on
        box on
        grid, grid minor
        scatter(PosPs(:,1),PosPs(:,2),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
        xline(mPAPcutoff,'--r','LineWidth',1.25)
        yline(smaCut,'--k','LineWidth',1.25)
        xlim([10 70])
        title(strjoin(["Quantity of PLS Shape Mode ",num2str(SM)," in each Patient and their associated Mean Pulmonary Artery Pressure"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
        xlabel("mPAP (mmHg)",'interpreter','latex')
        ylabel("PLS Shape Mode Quantity",'interpreter','latex')
        legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","F$B$ Shape Mode Classification Line",'interpreter','latex')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

    end

    %% Plot defined classification line
    smAcut = -2000;
    % Run ROC function to get successful classification rates
    [specD,sensD,~,SCRa,SCRt,~,~,~] = ROC(T,MpapC,smAcut,C);
    sucRaA(i,1) = SCRa;
    sucRaT(i,1) = SCRt;
    SpecD(i,1) = 1 - specD;
    SensD(i,1) = sensD;

    % Plot PRC graphs
    if mPAPcutoff == 25
        % Plot Scatter Graphs
        figure(i*250000)
        scatter(mPAP,scores(:,SM),'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        hold on
        box on
        grid, grid minor
        scatter(PosPs(:,1),PosPs(:,2),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
        xline(mPAPcutoff,'--r','LineWidth',1.25)
        yline(smAcut,'--k','LineWidth',1.25)
        xlim([10 70])
        title(strjoin(["Quantity of PLS Shape Mode ",num2str(SM)," in each Patient and their associated Mean Pulmonary Artery Pressure"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 25mmHg",'interpreter','latex')
        xlabel("mPAP (mmHg)",'interpreter','latex')
        ylabel("PLS Shape Mode Quantity",'interpreter','latex')
        legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Defined Shape Mode Classification Line",'interpreter','latex')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])

    else
        % Plot Scatter Graphs
        figure(i*200000)
        scatter(mPAP,smA,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor',[0 0.4470 0.7410])
        hold on
        box on
        grid, grid minor
        scatter(PosPs(:,1),PosPs(:,2),'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor',[0.6350 0.0780 0.1840])
        xline(mPAPcutoff,'--r','LineWidth',1.25)
        yline(smAcut,'--k','LineWidth',1.25)
        xlim([10 70])
        title(strjoin(["Quantity of PLS Shape Mode ",num2str(SM)," in each Patient and their associated Mean Pulmonary Artery Pressure"]),'interpreter','latex')
        subtitle("Pulmonary Hypertension Classification, mPAP = 20mmHg",'interpreter','latex')
        xlabel("mPAP (mmHg)",'interpreter','latex')
        ylabel("PLS Shape Mode Quantity",'interpreter','latex')
        legend("","Patients Diagnosed with Pulmonary Hypertension","Pulmonary Hypertension mPAP Classification Line","Defined Shape Mode Classification Line",'interpreter','latex')
        set(gca,'TickLabelInterpreter','latex')
        set(gcf,'Position',[600 400 800 400])
    end
end

% Filter for Shape Modes Percentage Variances of the Dataset
o = height(SMn);
for i = 1:o
    PVD(i,1) = PercentVar(SMn(i));
end

%% Create tables of results
% Create table of PVD and their representative shape mode numbers
PVDt = table(SMn,PVD);
PVDt.Properties.VariableNames = ["PLS Shape Mode No.","Percentage Variance of the Dataset (%)"];

% Create table of AUCROC and AUC-PRC data and their representative shape mode numbers
AUCROCPRC = table(SMn,AUC,PRC);
AUCROCPRC.Properties.VariableNames = ["PLS Shape Mode No.","AUCROC Value","AUC-PRC Value"];

% Create table of Youden Index classification success rates and their representative shape mode numbers
YIcsr = table(SMn,SucRateA,SucRateT);
YIcsr.Properties.VariableNames = ["PLS Shape Mode No."," Actual Successful Classification Rate (%)"," Theoretical Successful Classification Rate (%)"];

% Create table of refined classification success rates and their representative shape mode numbers
Rcsr = table(SMn,scrA,scrT);
Rcsr.Properties.VariableNames = ["PLS Shape Mode No."," Actual Successful Classification Rate (%)"," Theoretical Successful Classification Rate (%)"];

% Create table of refined classification success rates and their representative shape mode numbers
csr = table(SMn,sucRaA,sucRaT,SensD,SpecD);
csr.Properties.VariableNames = ["PLS Shape Mode No."," Actual Successful Classification Rate (%)"," Theoretical Successful Classification Rate (%)","Sensitivity","Specificity"];
