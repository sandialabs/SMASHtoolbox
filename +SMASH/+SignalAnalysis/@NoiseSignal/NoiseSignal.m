% This class generates synthetic noise to mimic imperfections found in
% real signals.  Noise objects are created on specified grid:
%     >> object=NoiseSignal(t);
% where "t" is a 1D array of uniformly spaced values.  The grid array
% defines the number of noise points generated by the class and the
% frequency range of a hypothetical measurement on grid.
%
% The root-mean-square of the noise is controlled by the Amplitude
% property (default value is 1).  
%     >> object.Amplitude=0.05; % change RMS
% The transfer function of the hypothetical measurement is defined by the
% TransferTable property.  This two-column table ([frequency response])
% is controlled by the "defineTransfer" method.
%     >> object=defineTransfer(object,'fraction',1/5); % use a fraction of the Nyquist limit
% Noise settings are applied to the synthetic noise by the "generate"
% method.
%     >> object=generate(object);
%
% Synthetic noise is stored as a Signal sub-object in the Measurement
% property.  This noise can be displayed or used in conjunction with
% another Signal object.
%     >> view(object.Measurement);
%     >> myobj=myobj+object.Measurement; % myobj is a Signal object
% Synethic noise can also be extracted as a 1D array.
%     >> s=object.Measurement.Data
%
% See also SMASH.SignalAnalysis, Signal
%

%
% created June 11, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef NoiseSignal
    %%
    properties (SetAccess=protected)
        Measurement % Synthetic noise (Signal object)
        TransferTable % Frequency transfer table (two-column array)
    end   
    properties
        SeedValue = [] % Random number seed (32-bit unsigned integer)
        Amplitude = 1 % Root-mean-square value (positive real number)
    end
    properties (SetAccess=protected,Hidden=true)
        Npoints
        Npoints2
        ReciprocalGrid
        NyquistValue
    end
    %%
    methods (Hidden=true)
        function object=NoiseSignal(Grid)
            assert(nargin>=1,'ERROR: no Grid specified');
            if isempty(Grid)
                Grid=1:16;
            else
                assert(numel(Grid) >= 16,'ERROR: not enough Grid points');
            end            
            object.Measurement=SMASH.SignalAnalysis.Signal([],zeros(2,1));
            object=defineGrid(object,Grid);
            object=defineTransfer(object);
            object=generate(object);
        end
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin)
    end
    %%
    methods
        function object=set.Amplitude(object,value)
            test=isnumeric(value) && isscalar(value) && (value>0);
            assert(test,'ERROR: invalid Amplitude');
            object.Amplitude=value;
        end
        function object=set.SeedValue(object,value)
            if isempty(value)
                object.SeedValue=[];
                return;
            end
            previous=rng();
            try                
                rng(value);
                object.SeedValue=value;
            catch
                error('ERROR: invalid seed value');
            end
            rng(previous);      
        end
    end
    
end