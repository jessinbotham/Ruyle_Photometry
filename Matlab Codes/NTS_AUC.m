% analyzes AUC of zscore data in 15-s bins for NTS photometry
AUC=[] % generates data table to store each trials AUC vals 
time=-30:0.01:90 %trial time 

% CHANGE TABLE NAME
x=zfent  % x=datatable to be analyzed with each trial in a separate rows. Change "datatable" to desired table for analysis
name="SHEETNAME"%replace sheetname with document name for output

% Time increments for AUC values to be calculated. Should be spaced with
% even increments to avoid errors on final bar plot
AUC(:,1)=trapz(x(:,time(1,:) >-30 & time(1,:) < -15),2);
AUC(:,2)=trapz(x(:,time(1,:) >-15 & time(1,:) < 0),2);
AUC(:,3)=trapz(x(:,time(1,:) >0 & time(1,:) < 15),2);
AUC(:,4)=trapz(x(:,time(1,:) >15 & time(1,:) < 30),2);
AUC(:,5)=trapz(x(:,time(1,:) >30 & time(1,:) < 45),2);
AUC(:,6)=trapz(x(:,time(1,:) >45 & time(1,:) <60),2);
AUC(:,7)=trapz(x(:,time(1,:) >60 & time(1,:) <75),2);
AUC(:,8)=trapz(x(:,time(1,:) >75 & time(1,:) <90),2);
AUC(:,9)=max(x,[],2)

% Find mean and error of all AUC values
AUCmean=mean(AUC);
AUCsem=std(AUC)/sqrt(height(AUC));
% increment spacing for AUC values to add labels on graph 
% i.e. first value of first bin:increment:first value of last bin
% if spacing is not equal - manually generate table of time values
n=[-30:15:90]
writematrix(AUC, name,'FileType','Spreadsheet');
graph=bar(n,AUCmean(:,1:9))
hold on
er=errorbar(n(:,1:9),AUCmean(:,1:9),AUCsem(:,1:9),AUCsem(:,1:9));
er.Color=[0 0 0];
er.LineStyle = 'none';
title('AUC'+name)
xlabel('Seconds')
ylabel('dF/F AUC')
hold off
saveas(graph,name,'png')

CumAUC=cumtrapz(AUC(:,3:9),2);

% CHANGE OUTPUT FILE NAME
name2=[name,"NTS_AUC"];
Cname= join(name2);
writematrix(CumAUC,Cname,'FileType', 'Spreadsheet')
