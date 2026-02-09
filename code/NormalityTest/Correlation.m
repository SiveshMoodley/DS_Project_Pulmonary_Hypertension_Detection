
% Import Pressure Data
fileID2 = fopen('mPAP__Data.txt','r');
formatspec2 = '%f';
B = fscanf(fileID2,formatspec2); % numerical vector of mPaP data
data = B;

% Anderson-Darling Test for normality
h1 = adtest(data);

% Lilliefors Test for normality
h2 = lillietest(data);

% Shapiro-Wilk Test for normality
h3 = swtest(data);

% Kolmogorov-Smirnov Test for normality
M = mean(data);
S = std(data);
KSmPAP = (data-M)/S;
h4 = kstest(data);

% Create a table of all normality test results
NormalityTest = ["Anderson-Darling Test";"Lilliefors Test";"Shapiro-Wilk Test";"Kolmogorov-Smirnov Test"];
NormalityTestResults = [h1;h2;h3;h4];
NormalityTestTable = table(NormalityTest,NormalityTestResults)