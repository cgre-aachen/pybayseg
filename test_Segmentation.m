%% define source data

clc;clear;close all;
addpath('./Functions');

EMI_FileList = {'./F01_ME_H118_1m.csv'};
loc_fileName = './F01_ME_H118_loc.csv';

load NDVI.mat NDVI x y;
figure;
imagesc(x,y,NDVI);
colormap viridis;
title('NDVI image of the entire region');
xlabel('UTM-E [m]');
ylabel('UTM-N [m]');

%% preprocess
F = PreProcess(EMI_FileList,loc_fileName);

figure;
imagescwithnan(F.ux,F.uy,F.EMI_image,mycmap,[1 1 1]);
title('EMI image');
xlabel('UTM-E [m]');
ylabel('UTM-N [m]');
axis equal;

figure;
imagescwithnan(F.ux,F.uy,F.NDVI_image,viridis,[1 1 1]);
title('NDVI image');
xlabel('UTM-E [m]');
ylabel('UTM-N [m]');
axis equal;
%%
order = 1;
F.Element = constructElements(F.ux,F.uy,0,order);
F.field_value = cat(2,retrieve(F.Element,F.NDVI_image),retrieve(F.Element,F.EMI_image));
F.field_value(isnan(sum(F.field_value,2)),:) = NaN;

%% segmentation
dimension = 2;
beta_initial = []; % do not specify initial value (i.e. randomly generate intial value)
num_of_clusters = 2;
Chain_length = 50;
% =============================
seg = segmentation(F.Element,dimension,beta_initial,F.field_value,num_of_clusters,Chain_length);
% =============================
%% extend the Markov Chain
Ext_Chain_length = 100;
seg = ExtendChain_para(seg,Ext_Chain_length);
% =============================
%% postprocess
figure;
plotField(F.Element,seg.latent_field_est);
title('segmentation result');

figure;
plotField(F.Element,seg.InfEntropy);
title('Information Entropy');

figure;
labels = {'NDVI','EC_a'};
mixturePlot(seg.MU_hat,seg.COV_hat,seg.field_value,seg.latent_field_est,labels);

figure;
imagescwithnan(F.ux,F.uy,F.NDVI_image,viridis,[1 1 1]);
title('NDVI image');
xlabel('UTM-E [m]');
ylabel('UTM-N [m]');
axis equal;

figure;
imagescwithnan(F.ux,F.uy,F.EMI_image,mycmap,[1 1 1]);
title('EMI image');
xlabel('UTM-E [m]');
ylabel('UTM-N [m]');
axis equal;