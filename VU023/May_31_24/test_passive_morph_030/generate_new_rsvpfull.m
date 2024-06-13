function generate_new_rsvpfull
temp_vec=repmat([1:44],1,5); %44 condition repeat 5 times
%temp_vec=repmat([23:33],1,20); %11 condition repeat 5 times
stim_seq=temp_vec(randperm(length(temp_vec)));
load('RSVPfull_classes.mat');
seq_count=0;
    for i=1:44
        for j=1:5
            seq_count=seq_count+1;
            GeneralVars.ClassStructure(i).frame(j).stim.feature=stim_seq(seq_count);
            GeneralVars.ClassStructure(i).frame(j).stim.end=[0,0];
        end
    end
save RSVPfull_classes.mat GeneralVars    
end