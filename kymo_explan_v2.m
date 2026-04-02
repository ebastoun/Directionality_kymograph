%% Kymograph explanation code
% data: Flow_HM1_2021_12_06_Nuc
% displacement vs radial distance
clc, clear, close all

%% Step 1: Read the file of PIV displacement vectors in cartesian coordinates
fcal = 1.1; % [um/px] calibration factor
PIV_vectors = readmatrix('HM1_f_0036.txt');
mtx_len = length(unique(PIV_vectors(:,1)));
PIV_vectors = reshape(PIV_vectors,[mtx_len,mtx_len,5]);

figure(1)
quiver(PIV_vectors(:,:,1)'*fcal,PIV_vectors(:,:,2)'*fcal,PIV_vectors(:,:,3)'*fcal,PIV_vectors(:,:,4)'*fcal);
axis square
axis off
hold on
max_length = (PIV_vectors(1,1,1) + PIV_vectors(end,1,1)); 
plot([0,max_length*fcal,max_length*fcal,0,0],[0,0,max_length*fcal,max_length*fcal,0],'-k')
hold off
title('Calculated displament vector with PIV in cartesian coordinates','FontSize',16)
set(gca,'YDir','reverse')
set(gcf,"Color",'w')%,'Units','pixels','InnerPosition',[0,0,1000,1000])

%% Step 3: Interpolate vector values to reduce noise
[x_q,y_q] = meshgrid(0:1:max_length);
[x_data,y_data] = meshgrid(PIV_vectors(:,1,1));
u_interp = interp2(x_data,y_data,PIV_vectors(:,:,3),x_q,y_q,'cubic');
v_interp = interp2(x_data,y_data,PIV_vectors(:,:,4),x_q,y_q,'cubic');

%% Step 4: Transform cartesian coordinates to polar coordinates
center_dist = max_length/2; % center of field of view
Polar_radii = sqrt((x_q'-center_dist).^2 + (y_q'-center_dist).^2)*fcal; % radial distance from center in um
Theta_dir = atan2d(y_q-center_dist,x_q-center_dist)*-1; % angle from center in degrees

%% Step 5: Calculate the radial component of PIV displacement vectors for every angle from center
ur  = (u_interp'*fcal.*cos(deg2rad(Theta_dir)) + -v_interp'*fcal.*sin(deg2rad(Theta_dir))); % Radial component of displacement

shade = linspace(0,1,100);
blue_c = [shade',shade',ones(100,1)];
red_c = [ones(100,1),flip(shade'),flip(shade')];
red_c(1,:) = []; % remove repeated white
my_colormap = [blue_c;red_c];

figure(2)
imagesc(ur)
colorbar
colormap(my_colormap)
caxis([-2 2])
axis square
axis off
title('Heatmap of radial component of PIV vector displacements','FontSize',16)
set(gca, 'YDir','reverse')
set(gcf,'Color','w')

%% Step 4: calculate the average of radial component of cell displacements per distance away from the center
radii = unique(Polar_radii);

p_r = reshape(Polar_radii,[],1);
ur_r = reshape(ur,[],1);

radii_ur = [p_r,ur_r];
radii_ur(isnan(radii_ur(:,2)),:) = [];

radii_ur = sortrows(radii_ur,1);

radii_idx = find(diff(floor(radii_ur(:,1)))>0);

avrg_ur(1) = radii_ur(1,1);

for i = 2:length(radii_idx)-1
    avrg_ur(i) = sum(radii_ur(radii_idx(i-1)+1:radii_idx(i+1),2))/(radii_idx(i+1)-radii_idx(i-1)+1);
end

kymolimit = 757; % [px] % Limit for calculated rows
avrg_ur(kymolimit:end) = []; 

%% Plot average radial component of cell displacements for the calculated instance of time
Kymo = importdata("Kymograph.mat");
kymolimit = 757; % [px] % Limit for calculated rows

Kymo = Kymo(1:kymolimit,:);
total_frames = 96; 
% displacement at 6 hours: Kymo in column 36
frame_example = 36;
displ = Kymo(:,frame_example);
Radial_pos = (1:length(Kymo(:,1)))*fcal;

figure(3)
patch([displ' nan]',[Radial_pos nan]',[displ' nan]','edgecolor', 'interp', 'LineWidth', 3); 
colormap(my_colormap)
clim([-0.4 0.4])
%colorbar
xlim([-0.6 0.2])
ylim([0 Radial_pos(end)])
ylabel('\textsf{Radial position ($\mu$m)}','Interpreter','latex','FontSize',16)
xlabel('\textsf{Average displacement} $\bar{u}_{r}$ $(\mu\textsf{m})$','Interpreter','latex','FontSize',16)
set(gca,'FontSize',16,'XAxisLocation','top','YDir','reverse')
set(gcf,'Color','w')
print(gcf,'Colored_line','-dtiff','-r300')
print(gcf,'Colored_line','-depsc')

%% Example of partial kymograph with calculated radial component averages for several time steps
figure(4)
%PKymo = kymograph;
PKymo = Kymo;
PKymo = PKymo(1:kymolimit,1:total_frames) ;
imagesc([1:length(PKymo(1,:))]*10/60,Radial_pos,PKymo);
clim([-1 1])
colormap(my_colormap)
hold on
plot([35.5 35.5 36.5 36.5 35.5]*10/60,[Radial_pos(end) Radial_pos(1) Radial_pos(1) Radial_pos(end) Radial_pos(end)], ...
     'LineWidth',2,'Color','g')
colorbar
xlabel('Time (h)','FontSize',16);
ylabel('Radial distance from center (\mum)','FontSize',16);
hCB=colorbar;
set(get(hCB,'Title'),'String','$\bar{u}_{r}$\, \textsf{away center} $(\mu\textsf{m})$','Interpreter','latex','FontSize',12)
set(hCB.XLabel,{'String','Rotation','Position','Interpreter','FontSize'},{'$\bar{u}_{r}$ \textsf{towards center} $(\mu\textsf{m})$',0,[0.3 -0.71],'latex',12})
hCB.Position = [0.89,0.07,0.02,0.88];
caxis([-0.4 0.4])
set(gca,'FontSize',13,'DefaultAxesFontName', 'Arial');
% run first get(gca,'Position') and modify below
set(gca,'Position',[0.08 0.11 0.775 0.815]) % reduce empty space to the left of the kymograph
set(gcf,'Color','w')
print(gcf,'kymograph','-dtiff','-r300')
print(gcf,'kymograph','-depsc')
