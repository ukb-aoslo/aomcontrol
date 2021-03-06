function psyfname = set_VideoParams_PsyfileName()
global SYSPARAMS VideoParams;  %#ok<NUSED>

%set video folder
time = fix(clock);
VideoParams.videofolder = [VideoParams.rootfolder VideoParams.vidprefix '\' num2str(time(2)) '_' num2str(time(3)) '_' num2str(time(1)) '_' num2str(time(4)) '_' num2str(time(5)) '\'];
if SYSPARAMS.realsystem == 1 && VideoParams.vidrecord == 1
    psyfname = [VideoParams.videofolder VideoParams.vidprefix '_' num2str(time(2)) '_' num2str(time(3)) '_' num2str(time(1)) '_' num2str(time(4)) '_' num2str(time(5)) '.psy'];
    command = ['VPC#' VideoParams.vidprefix '\' num2str(time(2)) '_' num2str(time(3)) '_' num2str(time(1)) '_' num2str(time(4)) '_' num2str(time(5)) '\#']; %#ok<NASGU>
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(command);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(command));
    end
    pause(1);
    %set video duration
    command = ['VL#' sprintf('%2.2f',VideoParams.videodur) '#']; %#ok<NASGU>
    if SYSPARAMS.board == 'm'
        MATLABAomControl32(command);
    else
        netcomm('write',SYSPARAMS.netcommobj,int8(command));
    end
else
    mkdir(VideoParams.videofolder);
    psyfname = [VideoParams.videofolder VideoParams.vidprefix '_' num2str(time(2)) '_' num2str(time(3)) '_' num2str(time(1)) '_' num2str(time(4)) '_' num2str(time(5)) '.psy'];
end