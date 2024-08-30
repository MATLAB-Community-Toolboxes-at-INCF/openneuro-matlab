function b = addParticipantWiseDataStore(b, datastoreType, folder)


% find patterns in open neuro and make very specific data types 
%create a data store from data store
% add root directory overview as property
b = addRootDir(b);

% query BIDS folder structure dictinary
dic = bidsDictionary(datastoreType, folder);

subjects = dic("subjects");
folders = dic("folders");
sessions = dic("sessions");

dir(b.encoding.dir + "/" + subjects{1} + "/" + sessions{1} + "/" +folders{1} + "/*" );


end
