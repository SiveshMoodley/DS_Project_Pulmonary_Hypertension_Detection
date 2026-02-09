clear
clc

%% Importing Data
% Read momenta vectors from text file
fileID = fopen('DeterministicAtlas__EstimatedParameters__Momenta.txt','r');
formatspec = '%f';
A = fscanf(fileID,formatspec);

subjects = A(1); % Number of subject shapes used in deformetrica model
controlPoints = A(2); % Number of control points used in deformetrica model
dimensions = A(3); % Shape dimension (i.e. 2D or 3D)

% Initialise and populate a 2D momenta vector
momenta2D = zeros(controlPoints*dimensions,subjects);

for i = 1:subjects
    offset = (i-1)*controlPoints*3;
    momenta2D(1:controlPoints*3,i) = A(4+offset:3+controlPoints*3+offset);
end

% Import Pressure Data
fileID2 = fopen('AOmPAP__Data.txt','r');
formatspec2 = '%f';
B = fscanf(fileID2,formatspec2); % numerical vector of mPaP data
mPAP = B;

% Import Pulmonary Hypertension Classification Data
fileID3 = fopen('AOph__Data.txt','r');
formatspec3 = '%f';
C = fscanf(fileID3,formatspec3); % numerical vector of mPaP data
phClass = C;

% Remove template from mPAP and PH data
% Create user input for defining template data ID
prompt = {'Define Template ID:'};
dlgtitle = 'UI';
fieldsize = [1 30];
definput = {'40'};
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
templateID = str2double(answer);

H = height(mPAP); % Define number of data points
h = height(phClass); % Define no. of data points

% Remove template from dataset
mPAPdata = zeros(H-1,1);
mPAPdata(1:templateID-1,:) = mPAP(1:templateID-1,:);
mPAPdata(templateID,:) = mPAP(templateID+1,:);
mPAPdata(templateID+1:H-1,:) = mPAP(templateID+2:H,:);
mPAP = mPAPdata; % Set new data

phData = zeros(h-1,1);
phData(1:templateID-1,:) = phClass(1:templateID-1,:);
phData(templateID,:) = phClass(templateID+1,:);
phData(templateID+1:H-1,:) = phClass(templateID+2:H,:);
PHclass = phData; % Set new data

% Removed samples S43, S34, and S22, prior to deformetrica, because they have no mPAP value

% Define number of modes
numModes = subjects-1;

%% Statistical Analysis
% Prep data for PLS
X = transpose(momenta2D);
Y = mPAP;

% Carry out PLS regression
[XL,YL,XS,YS,BETA,PCTVAR,MSE,stats] = plsregress(X,Y,numModes);

%% Calculate shape mode percentage of variation and accumulated variation
% Obtain vector of percentages in descending order
smPCTVAR = 100 * PCTVAR(2,:)';
SMpctvar = sort(smPCTVAR,'descend');

% Obtain Cumulative Percentage Vector
SMcumPercent = cumsum(SMpctvar);
SMs = (1:1:numModes)';

SMsP(2:numModes+1,1) = SMs;
SMsP(1,1) = 0;
SMcumPercentP(2:numModes+1,1) = SMcumPercent;
SMcumPercentP(1,1) = 0;

% Interpolate for 90% Variance
[~,SM90s]= min(abs(SMcumPercent - 90));
SM90 = max(SM90s);
if SMcumPercent(SM90) < 90
    SM90 = SM90 + 1;
end

P90 = spline(SMcumPercentP(1:30,:),SMsP(1:30,:),90);
PVD90x = [0;P90];
PVD90y = [90;90];
PVDx = [P90;P90];
PVDy = [0;90];

% Plot cumulative shape mode percentage
figure(1)
plot(SMsP,SMcumPercentP,'MarkerFaceColor',[0 0.4470 0.7410],'LineWidth',1.25)
hold on
plot(PVD90x,PVD90y,'k--',PVDx,PVDy,'k--','LineWidth',1.25)
scatter(P90,90,'k','filled','LineWidth',1.25)
box on
grid, grid minor
title("Cumulative Amount of Dataset Shape Variance Captured by PLS Shape Modes",'interpreter','latex')
xlabel("No. of PLS Shape Modes",'interpreter','latex')
ylabel("Dataset Shape Variance Captured (\%)",'interpreter','latex')
xlim([0 75])
ylim([0 100])
set(gca,'TickLabelInterpreter','latex')
set(gcf,'Position',[600 400 800 400])
str = {"90\% of the Dataset Shape Variance is Captured",strjoin(["by the first ",num2str(SM90)," PLS Shape Modes."])};
annotation('textbox',[0.65 0.19 0.1 0.1],'Interpreter','latex','String',str,'BackgroundColor','w','FitBoxToText','on','HorizontalAlignment','center')

% Create tables of each individual shape mode variance of the dataset
SMpercentT = table(SMs,smPCTVAR);
SMpercentT.Properties.VariableNames = ["Shape Mode No.","Percentage Variance of the Dataset (%)"];

SMpls_Imbio47 = XL;
writematrix(SMpls_Imbio47)

% Set t for number of standard deviations and m for which shape mode
for m = 1:numModes
    for t = -2:4:2
        output = t*XL(:,m);

        % Save the output to a .txt file
        % Create the file name
        name1 = strcat('PLS__Momenta__mode__',num2str(m));
        name2 = strcat('__nSD__',num2str(t));
        name = strcat(name1,name2);

        filename = strcat(name,'.txt');

        % The first three lines are 1 A(2) and A(3)
        header1 = '1'; % number of subjects per file
        header2 = num2str(A(2)); % number of control points
        header3 = num2str(A(3)); % number of dimensions

        % Create a file ID
        fid = fopen(filename,'w');

        % Put the header info into the text file
        fprintf(fid, [ header1 ' ']);
        fprintf(fid, [ header2 ' ']);
        fprintf(fid, [ header3 '\n']);

        % Print the data to a text file
        reshapeOutput = ones(controlPoints,dimensions);
        
        for i = 1:controlPoints
            
            a = num2str(output((i-1)*3+1));
            b = num2str(output((i-1)*3+2));
            c = num2str(output((i-1)*3+3));
     
            fprintf(fid, ['\n' a ' ' b ' ' c ]);
        end
    end
end

% Calculate how much of each shape mode is present in each patient
% Save the output to a .txt file
% Create the file name
filename = 'PLS_AmountOfEachMode.txt';

% Create a file ID
fid = fopen(filename,'w');

scores = zeros(subjects,numModes);

for subject = 1:subjects
    for mode = 1:numModes
        
        subject_n = momenta2D(:,subject);
        mode_m = XL(:,mode);
        score = dot(subject_n,mode_m);

        % Create an array where each row represents all the scores for one subject from mode 1 to 69
        scores(subject,mode) = score;

        % Print the data to a text file
        a = num2str(score);

        text1 = strcat('Subject: ',num2str(subject));
        text2 = strcat('; Mode: ',num2str(mode));
        text = strcat(text1, text2);

        fprintf(fid, ['\n' text ]);
        fprintf(fid, ['\n' a ]);
    end
end

%% Widely Accepted pulmonary hypertension (PH) classification
% Define mPAP PH classification
PHmPAP = 25; % mmHg

% Obtain graphical results and display AUCROC table
[AUC25,YI25,R25,PVD25,SRCC25] = ScatPlotsPLS(numModes,mPAP,scores,PHmPAP,smPCTVAR,PHclass);
disp(PVD25)
disp(SRCC25)
disp(AUC25)
disp(YI25)
disp(R25)

%% New pulmonary hypertension (PH) classification
% Define new mPAP PH classification
newPHmPAP = 20; % mmHg

% Obtain graphical results and display AUCROC table
[AUC20,YI20,R20,PVD20,SRCC20] = ScatPlotsPLS(numModes,mPAP,scores,newPHmPAP,smPCTVAR,PHclass);
disp(PVD20)
disp(SRCC20)
disp(AUC20)
disp(YI20)
disp(R20)
