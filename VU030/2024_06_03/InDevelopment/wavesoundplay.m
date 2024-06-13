function wavesoundlay(filename,duration)
[wavedata,freq]=audioread(filename);
wavedata=repmat(wavedata,5,1);
wavedata=wavedata(1:round(freq*duration),:);
sound(wavedata,freq);
end