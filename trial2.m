close all
clear
clc
t=1:1:40;
%data=exp(0.5*t);
filename = 'Audio_LDC93S1.wav';

[input_sig,  orgnal_sampl_freq]=audioread(num2str(filename));
plot(input_sig)
% xlim([0 70])
title('Input Signal')
figure;
[a,~]=size(input_sig);
time=(a/orgnal_sampl_freq);
fs=round(time);
fs=40
samples=round(linspace(1,a,fs));                                               %To get n samples we divide data by n-1 so to get n points(samples)    %Input signal divided into samples with each sample separated by sample_size
sampled_signal=zeros(1,fs);       
index=1;
for i=samples
        
    sampled_signal(index)=input_sig(i);
	index=index+1;
    
end
plot(t,sampled_signal,'LineWidth',1.5);
title('y(n)');
xlabel('n');
figure;
data = sampled_signal
y = compand(data,80,max(data),'mu/compressor');
n=1;m=2;
o=1;
while ( m< length(t))
    
    D=(y(m)+y(n))/2;
    k=round((m+n)/2);
    N=y(k);
    f=N/D;
    if f >1
    nn=m;
    mn=m+round(2*(m-n));
    elseif f==1
        nn=m;
        mn=m+m-n
    elseif f<1
        nn=m;
        mn=m+round(0.5*(m-n));
    end
    n=nn;
    m=mn;
    ind(o)=n;
    o=o+1;
end
plot(t,y,'LineWidth',1.5)
title('compresser(y(n))');
xlabel('n');
figure;
O=zeros(size(y));
for i=1:length(ind)-1
O(ind(i):ind(i+1))=y(ind(i+1));    
end

plot(t,O,'LineWidth',1.5);
title('Quantizes output');
xlabel('n');
figure;
ny= compand(O,80,max(O),'mu/expander');
plot(t,ny,'LineWidth',1.5)
hold on
plot(t,data,'LineWidth',1.5);
title('Expander output and y(n)');
xlabel('n');
legend('Expander','y(n)');
compression_ratio =y/sampled_signal
compression_ratio =y/data
compression_error =data-y
average_compression_error = mean(compression_error)

