
%
% The demo has not been well organized. 
% Please contact me if you meet any problems.
% 
% Email: gaofeng@ouc.edu.cn
% 
%

clear;
clc;
close all;

addpath('./Utils');

% PatSize ����Ϊ����
PatSize = 5;
k_n = 3;

fprintf(' ... ... read image file ... ... ... ....\n');
im1   = imread('./pic/ice_part2_1.bmp');
im2    =imread('./pic/ice_part2_2.bmp');
im_lab = imread('./pic/ice_part2_gt.bmp');
fprintf(' ... ... read image file finished !!! !!!\n\n');

im1 = double(im1(:,:,1));
im2 = double(im2(:,:,1));
im_gt = double(im_lab(:,:,1));

[ylen, xlen] = size(im1);

% �� neighborhood-based ratio image
fprintf(' ... .. compute the neighborhood ratio ..\n');
nrmap = nr(im1, im2, k_n);
nrmap = max(nrmap(:))-nrmap;
nrmap = nr_enhance( nrmap );
feat_vec = reshape(nrmap, ylen*xlen, 1); %����������
fprintf(' ... .. compute finished !!! !!! !!! !!!!\n\n');

fprintf(' ... .. clustering for sample selection begin ... ....\n');
im_lab = gao_clustering(feat_vec, ylen, xlen);
fprintf(' ... .. clustering for sample selection finished !!!!!\n\n');

fprintf(' ... ... ... samples initializaton begin ... ... .....\n');
fprintf(' ... ... ... Patch Size : %d pixels ... ....\n', PatSize);

% ��ȡ lab ��Ϣ

pos_lab = find(im_lab == 1);
neg_lab = find(im_lab == 0);
tst_lab = find(im_lab == 0.5);

% ��������������˳��
pos_lab = pos_lab(randperm(numel(pos_lab)));
neg_lab = neg_lab(randperm(numel(neg_lab)));
[ylen, xlen] = size(im1);

% ͼ����Χ���㣬Ȼ��ÿ��������ΧȡPatch������
mag = (PatSize-1)/2;
imTmp = zeros(ylen+PatSize-1, xlen+PatSize-1);
imTmp((mag+1):end-mag,(mag+1):end-mag) = im1; 
im1 = im2col_general(imTmp, [PatSize, PatSize]);
imTmp((mag+1):end-mag,(mag+1):end-mag) = im2; 
im2 = im2col_general(imTmp, [PatSize, PatSize]);
clear imTmp mag;

% �ϲ������� im
im1 = mat2imgcell(im1, PatSize, PatSize, 'gray'); 
im2 = mat2imgcell(im2, PatSize, PatSize, 'gray');
parfor idx = 1 : numel(im1)  
    im_tmp = [im1{idx}; im2{idx}];
    im(idx, :) = im_tmp(:);
end
clear im1 im2 idx;

fprintf(' ... ... ... randomly generation samples ... ... .....\n');
PosNum = round(numel(pos_lab)*0.007);
NegNum = round(numel(neg_lab)*0.05);



% ȡ����������ͼ���
pos_data = im(pos_lab(1:PosNum), :);
neg_data = im(neg_lab(1:NegNum), :);
trn_data = [pos_data; neg_data];
trn_lab  = [PosNum, NegNum];

clear PosPat NegPat TraPat TrnLab; 
%clear PosNum NegNum;
clear pos_lab neg_lab;


% ʵ�ʲ����з�������㷨�Ƚ��������ԣ�ֻ�ܰѴַ������б�ǩΪ0.5������ȡ����
% ��������Ч�ʻ��Щ
tst_data = im(tst_lab, :);

lambda = [0.4];

class = NRS_Classification(trn_data, trn_lab, tst_data, lambda);

idx = find(im_lab == 0.5);
for i = 1:numel(class)
    if class(i) == 1;
        im_lab(idx(i)) = 1;
    else
        im_lab(idx(i)) = 0;
    end
end



 [im_lab,num] = bwlabel(~im_lab);
%  for i = 1:num
%      idx = find(im_lab==i);
%      if numel(idx) <= 10
%          im_lab(idx)=0;
%      end
%  end
 im_lab = im_lab>0;

[FA,MA,OE,CA] = DAcom(im_gt, im_lab);
% ������
fid = fopen('rec.txt', 'a');
fprintf(fid, 'PatSize = %d\n', PatSize);
fprintf(fid, '�龯����: %d \n', FA);
fprintf(fid, '©������: %d \n', MA);
fprintf(fid, '�������: %d \n', OE);
fprintf(fid, '׼ȷ��:   %f \n\n\n', CA);
fclose(fid);

fprintf(' ===== Written change detection results to Res.txt ====\n\n');









