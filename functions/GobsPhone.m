classdef GobsPhone < gt.Gobs
    % GobsPhone: Smartphone's GNSS observation data class
    % ---------------------------------------------------------------------
    % This class inherits from MatRTKLIB's gt.Gobs class.
    % Some properties have been added for smart phones.
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki

    properties
        clk       % Receiver clock calculated inside smartphone (m)
        dclk      % Receiver clock drift calculated inside smartphone (m/s)
        clkjump   % Clock jump flag
        hcdc      % Hardware clock discontinue flag reported from smartphone
        timems    % gt.Gtime object converted from utcms
        utcms     % Raw utcms
        elapsedns % Raw elapsedns
    end
    properties(Access=private)
        FTYPE = ["L1","L2","L5","L6","L7","L8","L9"];
    end
    methods
        %% constractor
        function obj = GobsPhone(varargin)
            if nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setLogFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setObsStruct(varargin{1}); % obs struct
            else
                error('Wrong input arguments');
            end
        end
        %% set observation from LOG file
        function setLogFile(obj, file)
            arguments
                obj GobsPhone
                file (1,:) char
            end
            obs = gnsslog2obs(file); % gnss_log.txt to observation struct
            obj.setObsStruct(obs);
        end
        %% set observation from observation struct
        function setObsStruct(obj, obsstr)
            arguments
                obj GobsPhone
                obsstr (1,1) struct
            end
            setObsStruct@gt.Gobs(obj, obsstr);
            obj.clk = obsstr.clk;
            obj.dclk = obsstr.dclk;
            obj.clkjump = obsstr.clkjump;
            obj.hcdc = obsstr.hcdc;
            obj.timems = obsstr.timems;
            obj.utcms = obsstr.utcms;
            obj.elapsedns = obsstr.elapsedns;
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obj.(f).Perr = obj.(f).Perr;
                    obj.(f).Lerr = obj.(f).Lerr;
                    obj.(f).Derr = obj.(f).Derr;
                    obj.(f).Pstat = obj.(f).Pstat;
                    obj.(f).Lstat = obj.(f).Lstat;
                    obj.(f).multipath = obj.(f).multipath;
                end
            end
        end

        function obsstr = mystruct(obj, tidx, sidx)
            arguments
                obj GobsPhone
                tidx {mustBeInteger, mustBeVector} = 1:obj.n
                sidx {mustBeInteger, mustBeVector} = 1:obj.nsat
            end
            obsstr.clk = obj.clk;
            obsstr.dclk = obj.dclk;
            obsstr.clkjump = obj.clkjump;
            obsstr.hcdc = obj.hcdc;
            obsstr.timems = obj.timems;
            obsstr.utcms = obj.utcms;
            obsstr.elapsedns = obj.elapsedns;

            obsstr.sat = obj.sat;
            obsstr.prn = obj.prn;
            obsstr.sys = double(obj.sys);
            obsstr.ep = obj.time.ep;
            obsstr.tow = obj.time.tow;
            obsstr.week = obj.time.week;
            obsstr.n = size(obsstr.ep,1);
            obsstr.nsat = size(obsstr.sat,2);
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obsstr.(f) = obj.myselectFreqStruct(obj.(f), tidx, sidx);
                end
            end
        end

        function Fsel = myselectFreqStruct(obj,F,tidx,sidx)
            if isfield(F,"P"); Fsel.P = F.P(tidx,sidx); end
            if isfield(F,"L"); Fsel.L = F.L(tidx,sidx); end
            if isfield(F,"D"); Fsel.D = F.D(tidx,sidx); end
            if isfield(F,"S"); Fsel.S = F.S(tidx,sidx); end
            if isfield(F,"I"); Fsel.I = F.I(tidx,sidx); end
            if isfield(F,'ctype'); Fsel.ctype = F.ctype(sidx);end
            if isfield(F,'freq'); Fsel.freq = F.freq(sidx);end
            if isfield(F,'lam'); Fsel.lam = F.lam(sidx); end
            if isfield(F,"multipath"); Fsel.multipath = F.multipath(tidx,sidx); end
            if isfield(F,"Pstat"); Fsel.Pstat = F.Pstat(tidx,sidx); end
            if isfield(F,"Lstat"); Fsel.Lstat = F.Lstat(tidx,sidx); end
            if isfield(F,"resP"); Fsel.resP = F.resP(tidx,sidx); end
            if isfield(F,"resL"); Fsel.resL = F.resL(tidx,sidx); end
            if isfield(F,"resD"); Fsel.resD = F.resD(tidx,sidx); end
            if isfield(F,"resPc"); Fsel.resPc = F.resPc(tidx,sidx); end
            if isfield(F,"resLc"); Fsel.resLc = F.resLc(tidx,sidx); end
        end
    end
end