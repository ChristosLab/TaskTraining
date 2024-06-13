function generate_new_rsvp2
temp_vec=repmat([23:33],1,10); %each condition repeat 5 times
stim_seq=temp_vec(randperm(length(temp_vec)));
load('RSVP2_classes.mat');
seq_count=0;
    for i=1:55
        for j=1:2
            seq_count=seq_count+1;
            GeneralVars.ClassStructure(i).frame(j).stim.feature=stim_seq(seq_count);
            GeneralVars.ClassStructure(i).frame(j).stim.end=[0,0];
        end
    end
save RSVP2_classes.mat GeneralVars    
end