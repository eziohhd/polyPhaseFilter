%%参量
%1.选择滤波器2.bit数3.滤波器赋值4.save

%% 信号产生
clc;clear all;close all;
%fs=384000
%subbw=750
%bw=300000
%fsym=375
%load('pp_coef.mat') %原型滤波器
load('coef4096.mat')
% load('coef2048.mat')
% load('coef512.mat')
%load('Coef_Prototype_pr_m16_M512.mat');
%p_coef=pp_coef;
p_coef=Num1;%4096
%     p_coef=Num2;%2048
%     p_coef=coef512;
data_m=1024;%bit数
N=1024;%bit数
M=512;%信道数
SNR=1:1:20;%信噪比变化
snr=10.^(SNR/10);
data=randi([0 1],1,data_m);
qpsk_std=[1+1j -1+1j  1-1j -1-1j];
map_std = [0 0; 0 1; 1 0 ; 1 1 ];
data_tmp=reshape(data,2,data_m/2);
for j=1:length(SNR)
    N0=1/2/snr(j);%计算噪声功率(1/2是因为能量没有归一化）
    N0_dB=10*log10(N0);%将噪声功率转换为dBW
    ni=wgn(1,N,N0_dB);%产生高斯噪声
    data_q=qpsk_std(bi2de((data_tmp).')+1);
    data_up=zeros(1,2*length(data_q));
    data_up(1:2:end)=data_q(1:end);
    psf = rcosine(1,2,'fir/sqrt',0.35, 16/2/2);
    data_r_1=filter(psf,1,data_up);
    data_r=data_r_1+ni;%添加噪声
    %data_r=data_r_1;
    %data_r=awgn(data_r_1,SNR(j), 'measured');
    delay=floor((length(psf))/2);
    data_r(:,1:delay)=[];
    data_len=length(data_r);
%     figure(1);
%     pwelch(data_r,[],[],[],'centered');
%      saveas(1,'基带频谱.jpg');
%% added by Haidi, data, coefficient quantized and written to txt
s=1;
wl=12;
fl=8;
% data 
data_r_q = fi(data_r,s,wl,fl);
data_r_q_real = real(data_r_q);
data_r_q_imag = imag(data_r_q);
data_r_q_real_bin = data_r_q_real.bin;
data_r_q_imag_bin = data_r_q_imag.bin;
FID1 = fopen('data_q_binary.txt','w+');
fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
for i = 1:length(data_r_q_real)
    if(i<length(data_r_q_real))
        fprintf(FID1,'%s',data_r_q_real_bin(1+15*(i-1):1+15*(i-1)+11)); %15 = wl+3, 11 = wl-1
        fprintf(FID1,'%s,\n',data_r_q_imag_bin(1+15*(i-1):1+15*(i-1)+11));
    else
        fprintf(FID1,'%s',data_r_q_real_bin(1+15*(i-1):1+15*(i-1)+11));
        fprintf(FID1,'%s;\n',data_r_q_imag_bin(1+15*(i-1):1+15*(i-1)+11));
    end
end

% coef
s=1;
wl=16;
fl=14;
p_coef_q = fi(p_coef,s,wl,fl);
p_coef_q_bin = p_coef_q.bin;
FID1 = fopen('coe_q_binary.txt','w+');
fprintf(FID1,'MEMORY_INITIALIZATION_RADIX=2;\n');
fprintf(FID1,'MEMORY_INITIALIZATION_VECTOR=\n');
for i = 1:length(p_coef_q)
    if(i<length(p_coef_q))
        fprintf(FID1,'%s,\n',p_coef_q_bin(1+19*(i-1):1+19*(i-1)+15)); %19 = wl+3, 15 = wl-1
    else
        fprintf(FID1,'%s;\n',p_coef_q_bin(1+19*(i-1):1+19*(i-1)+15));
    end
end


    %% 信道分配
    channel=zeros(M,data_len);
    for i=1:200
        channel(i,:)=data_r(1,:);
    end
    for i=313:512
        channel(i,:)=data_r(1,:);
    end
%     test=filter(p_coef,1,data_r);
%     figure;
%     pwelch(test,[],[],[],'centered');
    %% 多相合路
    ifftOut = zeros(M,data_len);
    for idx = 1:data_len
        tmp = channel(1:M, idx);
        ifftOut(1:M,idx) = M*ifft(tmp,M);%最后修改
    end
    polyphsOut = zeros(1,M*data_len);
    Zp = zeros(M,length(p_coef)/M-1);
    for subBandIdx = 1:M
        tmp = ifftOut(subBandIdx, :);
        [tmpfilt Zp(subBandIdx,:)] = filter(p_coef(subBandIdx:M:end), 1, tmp, Zp(subBandIdx,:));
        polyphsOut(subBandIdx:M:end) = M*tmpfilt;%上采样操作
    end    
%       figure(2);
%       pwelch(polyphsOut,[],[],[],'centered');
%       saveas(2,'合路图512.jpg');
    %% 多相分路
    sublen=length(polyphsOut)/M;
    polyFiltOut=zeros(M,sublen);  
    for i=1:M
        tmp=polyphsOut(M-i+1:M:end);
        tmpfilt=filter(p_coef(i:M:end),1,tmp,Zp(i,:));
        polyFiltOut(i,1:sublen)=M*tmpfilt;% why*M
    end
    polyfftout=zeros(M,sublen);
    for i=1:sublen
        polyfftout(1:M,i)=fft(polyFiltOut(:,i),M);
    end
%     figure;
%     pwelch(polyfftout(1,:),[],[],[],'centered');
    polyfftout(1,:)=polyfftout(1,:)/sqrt(var(polyfftout(1,:)));%归一化
%      figure(3);
%      pwelch(polyfftout(1,:),[],[],[],'centered');
%      saveas(3,'信道1输出.jpg');
%     test_coef=p_coef.*exp(1j*2*pi*75000/384000*(1:length(p_coef)));
%     test=filter(test_coef,1,polyphsOut);
%     pwelch(test,[],[],[],'centered');
    %% 误码率计算
    test_1=polyfftout(1,:);
    psf = rcosine(1,2,'fir/sqrt',0.35, 16/2/2);
    rx_test_tmp=filter(psf,1,test_1);
    rx_test_tmp(:,1:delay)=[];%delay=floor((length(psf))/2);
    rx_test(1,:)=rx_test_tmp(2:2:end);%/512
    for i=1:length(rx_test)
        dis=abs(qpsk_std-rx_test(1,i)).^2;
        [m,n]=min(dis);
        data_rx(1,i)=qpsk_std(n);
    end
    %sym_b=length(find(data_rx(8:end)~=data_q(1:length(data_rx)-7)));%8196
    %sym_b=length(find(data_rx(2:end)~=data_q(1:length(data_rx)-1)));%2048
    sym_b=length(find(data_rx(4:end)~=data_q(1:length(data_rx)-3)));%4096
    %sym_b=length(find(data_rx(1:end)~=data_q(1:length(data_rx))));%512
    sym_ber(j)=sym_b/length(data_q);%j
 end
%sym_ber_8191=sym_ber;
%sym_ber_4096=sym_ber;
%sym_ber_2048=sym_ber;
%sym_ber_512=sym_ber;
%save('.\data8191.mat','sym_ber8191');
%save('.\data4096.mat','sym_ber4096');
%save('.\data2048.mat','sym_ber2048');
%save('.\data512.mat','sym_ber');
qpsk_awgn=1/2*erfc(sqrt(snr));%AWGN信道下QPSK理论误码率
    figure(1);
    pwelch(data_r,[],[],[],'centered');
    figure(2);
    pwelch(polyphsOut,[],[],[],'centered');
    figure(3);
    pwelch(polyfftout(1,:),[],[],[],'centered'); %polyfftout
figure(1);
semilogy(SNR,sym_ber,'-r*');hold on;
semilogy(SNR,qpsk_awgn,'-go');hold on;
axis([-1,6,10^-4,1]);
title('QPSK误码性能分析');
xlabel('信噪比（dB）');ylabel('BER');
%saveas(1,'ber8191曲线.jpg');
%saveas(1,'ber4096曲线.jpg');
%saveas(1,'ber2048曲线.jpg');
% saveas(1,'ber512曲线.jpg');




    


    



