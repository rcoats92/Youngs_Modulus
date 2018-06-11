clear
%%%%%%%%%%%%%%%%%%%%%%
%% Young's Modulus script, Coats (2018)
%This is a script to find the Young's Modulus of a cylindrical sample from
%stress-strain mechanical data in a UCS test. See Coats et al.,(2018)for a 
%detailed description and example results.

%Coats, R., Kendrick, J.E., Wallace, P.A., Miwa, T., Hornby, A.J., 
%Ashworth, J.D., Matsushima, T. and Lavallée, Y. (2018).
%Failure criteria for porous dome rocks and lavas: a study of Mt. Unzen, Japan. 
%Solid Earth Discuss, https://doi.org/10.5194/se-2018-19.
%% Loading in your data
%The mechanical data should be in an excel spread sheet in .xls format. 
%For multiple samples, put each sample in a new sheet and label the sheet with the sample
%name. Name the .xls file 'mechanical data'. Make sure the data are
%corrected for machine compliance and make the corrected strains (e.g. mm/mm) appear in
%the 6th column and the stresses (in MPa) appear in the 7th column
[status,sheets] = xlsfinfo('mechanical data');
sheet_names = sheets;
 for i = 1:length(sheet_names);
        data_sheet{i} = xlsread('mechanical data',i);
 end

%% setting up our vectors
%This is where we set up our vectors, if you wish to move the column of
%your stress and/or strain you can change the 6 and 7 here to whichever column you desire 
for j = 1:length(sheet_names);
     % This is where we find the differential of our stress and strain values (search diff in the help for more info) 
     strains{j} = diff(data_sheet{j}(:,6));
     stresses{j} = diff(data_sheet{j}(:,7));

     %This is where we define our value of porosity of the sample, this is
     %only needed if you want to enable the plot at the bottom of the
     %script, here we put our porosity in the 2nd row, 3rd column of the
     %.xls sheet (uncomment by removing the '%' to use it) 
%      porosity(j) = data_sheet{j}(2,3);

     %Here the differential of the stress and strain data are smoothed to get rid of extreme positives and negatives, 
     %achieving an average change in each value.
     %This value of smooting depends on your sampling rate, e.g. a
     %smoothing of 51 was used for a sampling rate of 1 point per ms. 
     smoothed_stresses{j} = smooth(stresses{j},51);
     smoothed_strains{j} = smooth(strains{j},51);
     %This finds the maximum of the difference, this is the value where the slope in
     %stress-strain is at its maximum. 
     X(j) = max(smoothed_stresses{j}); 
     %Finding which points are within a percentage of this maximum value. This is
     %where you will define your linear portion of the curve. This may take
     %some trial and error with your data as to the amount of smoothing you
     %pick and what percentage you define (see below). The trick is to start with more
     %smoothing and a high percentage within maximum then lower it as much
     %as possible. The percentage you choose depends on how linear your
     %slope is, i.e. how much of an elastic portion of the curve you
     %have.
     f = @iswithin;
     %change this value to change the percent within maximum (1.01 = 1%, 1.1 = 10%,
     %1.2 = 20% etc..)
     percent = 1.01;
     %finding the data within the percent
     GG{j}=f(smoothed_stresses{j},X(j)/percent,X(j)*percent);
     %indexing to find values
     GGG{j} = GG{j}.*smoothed_stresses{j};
     %Indexing to find cosiding strains
     strainsGGG{j} = GG{j}.*smoothed_strains{j};
     slope{j} = GGG{j}./strainsGGG{j};
     %value of Young's Modulus from slope, you can find this vector in your
     %worksapce if you want to save/copy it. Units are GPa.
     average_youngs(j) = nanmean(slope{j})/1000;
     
end

%% plot of differential stress
%This plots the differential of the stress, the smoothed differential of 
%the stress, and then the selected values of stress that are within the 
%defined percentage of the maximum. This is a useful visualisation tool that
%helps you pick your value of smoothing and percentage of max based on your
%data
 
for j = 1:length(sheet_names);

    figure
    P1{j} = plot((stresses{j}));hold on
    P2{j} = plot((smoothed_stresses{j}),'r');hold on
    P3{j} = plot((GGG{j}),'k');hold off
    xlabel('Index');
    ylabel('Differential of stress (MPa)');
    legend([P1{j} P2{j} P3{j}], {'differential stress', 'smoothed differential stress', 'data within % of max'}, 'Location', 'SouthWest');
    print(char(sheet_names{j}),'-dpng','-r300');
    
end


%% plotting Young's Modulus with porosity (optional)
% The following can be uncommented along with the above porosity variable to plot the
% Young's Modulus with porosity for all samples. Porosity is interchangeable
% with any variable e.g. temperature or heating rate

% f1 = figure
% p1 = plot(porosity, average_youngs, 'O','MarkerFaceColor',[1,0,0],'MarkerEdgeColor',[0,0,0], 'MarkerSize',5); hold on
% 
% %This is the axis max and mins, change to fit your data
% xmax = 0.35; xmin = 0;
% ymax = 15; ymin = 0;
% axis([xmin,xmax,ymin,ymax]); xtickformat('%.2f');
% xlabel('Porosity'); 
% ylabel('Youngs Modulus (GPa)'); set(gca, 'fontname', 'timesnewroman', 'FontSize', 10);
% fig_format = 4/3; %aspect ratio
%  height = 7; %of fig
%  width = fig_format*height;
%  set(f1, 'Paperunits', 'centimeters' ,'PaperPosition', [1 1 width height]);
% print('Youngs Modulus','-dpng','-r300');
    

 %% Function to find which data are within a defined range
 function [ flg ] = iswithin(x,lo,hi)

flg= (x>=lo) & (x<=hi);

 end