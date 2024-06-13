function generate_gabor_geometry
temp_vec=repmat([1:16],1,20); %11 condition repeat 5 times
stim_seq=temp_vec(randperm(length(temp_vec)));
load('RSVP_classes_gabor_geometry.mat');
seq_count=0;
    for i=1:64
        for j=1:5
            seq_count=seq_count+1;
            GeneralVars.ClassStructure(i).frame(j).stim.feature=stim_seq(seq_count);
            GeneralVars.ClassStructure(i).frame(j).stim.end=[0,0];
        end
    end
save RSVP_classes_gabor_geometry.mat GeneralVars    
end