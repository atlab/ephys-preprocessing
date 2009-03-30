function db = submitJobs(db,rec,behIds,tetrodes,varargin)
% AE 2009-03-27

args.tstart = 1;
args.tend = [];
args.samplingRate = 32000;
args.priority = 0;
args = parseVarArgs(args,varargin{:});

% retrieve session data from db
if isnumeric(rec)
    rec = getRecById(db,rec);
elseif ischar(rec)
    % TODO
end
% acq = getAcqById(db,rec.acqId);

% Determine recording end if not defined
if isempty(args.tend)
    args.tend = rec.nSamples / args.samplingRate * 1000;
end    

% % lfp extraction
% jdb = jobDB();
% recFolder = [acq.folder '/' rec.folder];
% lfpPath = [acq.processedFolder '/' rec.folder '_lfp'];
% params = {recFolder,lfpPath};
% jobId = insert(jdb,'extract_lfp_path','extract_lfp',params,[],5);
% addLfpJob(db,rec.id,jobId);

% create a new clustering set
clus = newClusSet(db,rec.id,behIds,[args.tstart; args.tend]);

% build clustering job struct
outPath = clus.folder;
backupPath = strrep(outPath,'/processed/','/clustered/');
timeFrames = [args.tstart; args.tend];
timeFrames = mat2cell(timeFrames,ones(1,2),ones(1,size(timeFrames,2)));
jobs = clus_enqueue_jobs([],outPath,tetrodes,outPath,backupPath,timeFrames{:});

% create jobs to run
for i = 1:length(tetrodes)

    % spike detection
    params = {recFolder,tetrodes(i),outPath,'tstart',args.tstart(1),'tend',args.tend(end)};
    detectId = insert(jdb,'detect_ae_path','detectSpikes',params,[],15+args.priority);
    addJobToClusSet(db,clus.id,detectId,tetrodes(i));

    % run clustering
    params = {jobs(i)};
    runClusId = insert(jdb,'clus_path','clus_run_job',params,detectId,15+args.priority);
    addJobToClusSet(db,clus.id,runClusId,tetrodes(i));

    % user interaction
    userId = insert(jdb,'','USER_INTERACTION',{},runClusId);
    addJobToClusSet(db,clus.id,userId,tetrodes(i));

    % post processing
    params = {setfield(jobs(i),'status',2)}; %#ok<SFLD>
    postId = insert(jdb,'clus_path','clus_runPostProcessing',params,userId,16+args.priority);
    addJobToClusSet(db,clus.id,postId,tetrodes(i));
end
