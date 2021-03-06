function Parse_Load_Buffers(parseon)
global SYSPARAMS StimParams OrigFrame;
if exist('handles','var') == 0;
    handles = guihandles;
else
    %donothing
end

if parseon == 1 
    dirname = StimParams.stimpath;
    d=dir(dirname);
    imfnamesbmp={};
    imfnamesbuf={};
    mapfname={};
    indexbmp = 1;
    indexbuf = 1;
    seqfname = [];
    fext = [];
    for j = 1:size(d,1)
        fname = d(j).name;
        if size(fname,2) > 5
            fext = fname(size(fname,2)-2:end);
            if (strcmp(fext,'bmp') || strcmp(fext,'BMP'))
                imfnamesbmp(indexbmp) = cellstr(fname); %#ok<AGROW>
                indexbmp = indexbmp+1;
            elseif (strcmp(fext,'buf') || strcmp(fext,'BUF'))
                imfnamesbuf(indexbuf) = cellstr(fname); %#ok<AGROW>
                indexbuf = indexbuf+1;
            elseif (strcmp(fext,'map') || strcmp(fext,'MAP'))
                mapfname = fname;
            elseif (strcmp(fext,'seq') || strcmp(fext,'SEQ'))
                seqfname = fname;
            elseif (strcmp(fext,'loc') || strcmp(fext,'LOC'))
                locfname = fname;
            else
            end
        end
    end

    if (indexbmp == 1 && indexbuf == 1)
        set(handles.aom1_state, 'String','Error loading image sequence: You must select a folder that contains at least one bitmap file. Please try again.');
        return
    end

    fprefixes = {};
    findices = [];
    h = waitbar(0,'Parsing stimuli...');
    if indexbuf > 1
        numfiles = size(imfnamesbuf,2);
        fext = 'buf';
    else
        numfiles = size(imfnamesbmp,2);
        fext = 'bmp';
    end
    for k = 1:numfiles;
        fprefix = [];
        findex = [];
        if indexbuf > 1
            fname = char(imfnamesbuf{k});
        else
            fname = char(imfnamesbmp{k});
        end
        fnamesize = size(fname,2);
        for i = 1:fnamesize
            if isempty(str2num(fname(i))) == 1 || fname(i) == 'j' || fname(i) == 'i'
                fprefix = [fprefix,fname(i)]; %#ok<AGROW>
            elseif isempty(str2num(fname(i))) == 0;
                findex = [findex, fname(i)]; %#ok<AGROW>
            end
        end
        fpresize = size(fprefix,2);
        fprefix = fprefix(1:fpresize-4);
        fprefixes(k) = {fprefix}; %#ok<AGROW>
        findices(k) = str2num(findex); %#ok<AGROW>
        waitbar(k/numfiles);
    end
    close(h);

    if iscell(seqfname) == 0
    else
        StimParams.seqfname = char(seqfname);
    end
    fprefix = char(fprefixes(1));
    aomindex = 1+size(findices,2);
    if SYSPARAMS.realsystem == 1
        if aomindex>1
            command = ['Load#1#' dirname '#' fprefix '#' num2str(min(findices)) '#' num2str(max(findices)) '#' fext '#']; %#ok<NASGU>
            if SYSPARAMS.board == 'm'
                MATLABAomControl32(command);
            else
                netcomm('write',SYSPARAMS.netcommobj,int8(command));
            end
        end
    end
    set(handles.aom1_state, 'String','Done Loading AOM Buffers');
    StimParams.fprefix = fprefix;
    StimParams.fprefixes = fprefixes;
    StimParams.stimpath = dirname;
    StimParams.findices = findices;
    StimParams.fext = fext;
    StimParams.mapfname = mapfname;    
else
    if SYSPARAMS.realsystem == 1
        command = ['Load#1#' StimParams.stimpath '#' StimParams.fprefix '#' num2str(StimParams.sframe) '#' num2str(StimParams.eframe) '#' StimParams.fext '#']; %#ok<NASGU>
        if SYSPARAMS.board == 'm'
            MATLABAomControl32(command);
        else
            netcomm('write',SYSPARAMS.netcommobj,int8(command));
        end
        pause((StimParams.eframe - StimParams.sframe)*0.005);
    end
    OrigFrame = zeros(SYSPARAMS.rasterH, SYSPARAMS.rasterV,4);
    OrigFrame(:,:,1) = 50;    
end