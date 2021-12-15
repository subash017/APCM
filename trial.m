clc
clear all
close all;

% part 1
fname = 'Audio_LDC93S1.wav';
[x,Fs] = audioread(fname); % Read TIMIT data file into a vector x
plot(x);
title('x');
figure;

%part 2
a = uencode(x,16);
b = udecode(a,16);
plot(b);
title('udecode16');
figure;
t=1:46797;
compressed = compand(b,255,max(b),'mu/compressor'); 
plot(compressed);
title('compressed');
figure;
y=udecode(uencode(compressed,8),8);
plot(t,y);
title('y');
figure;
filename = '8bits.wav';
audiowrite(filename,y,Fs);

%the code of part 3 is in adpcm_decoder and adpcm_encoder
%part 4
z = adpcm_encoder_ori(y);
plot(z);
title('adpcm encoder ori');
figure
%part 5
y1= adpcm_decoder_ori(z);
plot(y1);
title('y1');
figure
%part 6 7
x1 = compand(y1,255,max(y1),'mu/expander');
plot(x1);
title('x1');
figure
% player = audioplayer(x1, Fs);
% play(player);
filename = 'reconstructive.wav';
audiowrite(filename,y,Fs);
function adpcm_y = adpcm_encoder_ori(raw_y)

% This m-file is based on the app note: AN643, Adaptive differential pulse
% code modulation using PICmicro microcontrollers, Microchip Technology
% Inc. The app note is avaialbe from www.microchip.com
% Example:  Y = wavread('test.wav');
%           y = adpcm_encoder(Y);
%           YY = adpcm_decode(y);

IndexTable = [-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8];
         
StepSizeTable = [7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767];

prevsample = 0;
previndex = 1;

Ns = length(raw_y);
n = 1;

raw_y = 32767 * raw_y;          % 16-bit operation

while (n <= Ns)
    predsample = prevsample;
    index = previndex;
    step = StepSizeTable(index);

    diff = raw_y(n) - predsample;
    if (diff >= 0)
        code = 0;
    else
        code = 8;
        diff = -diff;
    end

    tempstep = step;
    if (diff >= tempstep)
        code = bitor(code, 4);
        diff = diff - tempstep;
    end
    tempstep = bitshift(tempstep, -1);
    if (diff >= tempstep)
        code = bitor(code, 2);
        diff = diff - tempstep;
    end
    tempstep = bitshift(tempstep, -1);
    if (diff >= tempstep)
        code = bitor(code, 1);
    end

    diffq = bitshift(step, -3);
    if (bitand(code, 4))
        diffq = diffq + step;
    end
    if (bitand(code, 2))
        diffq = diffq + bitshift(step, -1);
    end
    if (bitand(code, 1))
        diffq = diffq + bitshift(step, -2);
    end

    if (bitand(code, 8))
        predsample = predsample - diffq;
    else
        predsample = predsample + diffq;
    end

    if (predsample > 32767)
        predsample = 32767;
    elseif (predsample < -32768)
        predsample = -32768;
    end

    index = index + IndexTable(code+1);
    if (index < 1)
        index = 1;
    end
    if (index > 89)
        index = 89;
    end

    prevsample = predsample;
    previndex = index;

    adpcm_y(n) = bitand(code, 15);
    %adpcm_y(n) = code;
    n = n + 1;
end
end
function raw_y = adpcm_decoder_ori(adpcm_y)

% This m-file is based on the app note: AN643, Adaptive differential pulse
% code modulation using PICmicro microcontrollers, Microchip Technology
% Inc. The app note is avaialbe from www.microchip.com
% Example:  Y = wavread('test.wav');
%           y = adpcm_encoder(Y);
%           YY = adpcm_decode(y);
IndexTable = [-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8];
         
StepSizeTable = [7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767];

prevsample = 0;
previndex = 1;

Ns = length(adpcm_y);
n = 1;

while (n <= Ns)
    predsample = prevsample;
    index = previndex;
    step = StepSizeTable(index);
    code = adpcm_y(n);

    diffq = bitshift(step, -3);
    if (bitand(code, 4))
        diffq = diffq + step;
    end
    if (bitand(code, 2))
        diffq = diffq + bitshift(step, -1);
    end
    if (bitand(code, 1))
        diffq = diffq + bitshift(step, -2);
    end

    if (bitand(code, 8))
        predsample = predsample - diffq;
    else
        predsample = predsample + diffq;
    end

    if (predsample > 32767)
        predsample = 32767;
    elseif (predsample < -32768)
        predsample = -32768;
    end

    index = index + IndexTable(code+1);

    if (index < 1)
        index = 1;
    end
    if (index > 89)
        index = 89;
    end

    prevsample = predsample;
    previndex = index;

    raw_y(n) = predsample / 32767;
    n = n + 1;
end
end