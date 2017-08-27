clear all
%% convert to hdf5 for all 5 views
for i=2
    shape(i)=load(strcat('./FinalShape_view', num2str(i), '.mat'));
    sh=shape(i).Shape;
    N=size(sh,1);
    num = 2*N;
    points = size(sh{1}.landmarks, 2);
    for j=1:N
        %image data for view i
        rgbI=imread(strcat('./data/view', num2str(i), '/', num2str(j,'%05d'), '.jpg'));
        grayI=single(rgb2gray(rgbI))/255;
        data(:,:,1,j)=grayI;
        %data augmentation *3, x flip and gaussian zero-mean noise
        %data(:,:,1,j+N)=fliplr(grayI);
        data(:,:,1,j+N)=imnoise(grayI,'gaussian');
        %label for view i
        %all images is 356*356*3
        tmp=[sh{j}.landmarks/356;sh{j}.occlusion]';
        label(:,j)=tmp(:);
        tmpp=tmp;
        tmpp(1:points)=356-tmp(1:points);
        %label(:,j+N)=tmpp(:);
        label(:,j+N)=tmp(:);
    end
    
   %% writing to hdf5 , train:test=3:1
    train_file = strcat('train', num2str(i), '.h5');
    test_file = strcat('test', num2str(i), '.h5');
    
    %num = 3*N;
    train_num = ceil(num / 4 * 3);
    
    %label=label';
    train_label=label(:,1:train_num);
    h5create(train_file, '/label',size(train_label),'Datatype','single');
    h5write(train_file, '/label', single(train_label));
    
    test_label=label(:,train_num+1:num);
    h5create(test_file, '/label',size(test_label),'Datatype','single');
    h5write(test_file, '/label', single(test_label));

    %data = data';
    train_data=data(:,:,1,1:train_num);
    train_data  = reshape(train_data,[356 356 1 train_num]);
    h5create(train_file,'/data',[356 356 1 train_num],'Datatype','single');
    h5write(train_file,'/data', single(train_data));
    
    test_data=data(:,:,1,train_num+1:num);
    test_data  = reshape(test_data,[356 356 1 num-train_num]);
    h5create(test_file,'/data',[356 356 1 num-train_num],'Datatype','single');
    h5write(test_file,'/data', single(test_data));

    clear data;
    clear label;
end


% %% WRITING TO HDF5 with chunks
% filename           =   'train.h5';
% num_total_samples  =   size(data,1);            %��ȡ��������
% data_disk          =   data';
% label_disk         =   label';
% chunksz            =   100;                        %���ݿ��С
% created_flag       =   false;
% totalct            =   0;
% for batchno=1:num_total_samples/chunksz
%    fprintf('batch no. %d\n', batchno);
%    last_read       =   (batchno-1)*chunksz;
%    % ��dump��hdf5�ļ�֮ǰģ���ڴ��з��õ����������
%    batchdata       =   data_disk(:,last_read+1:last_read+chunksz);
%    batchlabs       =   label_disk(:,last_read+1:last_read+chunksz);
%    % ����hdf5
%    startloc        =   struct('dat',[1,totalct+1], 'lab',[1,totalct+1]);
%    curr_dat_sz     =   store2hdf5(filename, batchdata,batchlabs, ~created_flag, startloc, chunksz);
%    created_flag    =   true;                       %����flagΪ��ֻ����һ���ļ�
%    totalct         =   curr_dat_sz(end);           %�������ݼ���С (������������)
% end
% %��ʾ���洢HDF5�ļ��Ľṹ��
% h5disp(filename);
% %����HDF5_DATA_LAYER��ʹ�õ�list�ļ�
% FILE               =   fopen('train.txt', 'w');
% fprintf(FILE, '%s', filename);
% fclose(FILE);
% fprintf('HDF5 filename listed in %s \n','train.txt');

