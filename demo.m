% Filter an example simulated chirp timeseries (simData.downedRecording with 
% 150 Hz stimulation artifact using PARRM
%% PARRM Filter
load('simData')
fs=200; % Sampling rate of simulated data
sepChirp=200; % Separation between subequent chirps in samples
winSize=2000; % Width of the window in sample space for PARRM filter
skipSize=20; % Number of samples to ignore in each window in sample space
perDist=Period/120; % Window in period space for which samples will be averaged
winDir='both'; % Filter using samples from the past and future
guessPeriod=fs/simData.stimRate; % Starting point for period grid search

% Find the period of stimulation in simulated data
Period=FindPeriodLFP(simData.downedRecording,[1,length(simData.downedRecording)-1],guessPeriod);
% Create the linear filter
PARRM=PeriodicFilter(Period,winSize,perDist,skipSize,winDir);
% Filter using the linear filter and remove edge effects
Filtered=((filter2(PARRM.',simData.downedRecording','same')-simData.downedRecording')./(1-filter2(PARRM.',ones(size(simData.downedRecording')),'same'))+simData.downedRecording')';

%% Time Domain Comparison
% Plots overlapping timeseries for the first chirp when there is
% stimulation artifact, when there is no stimulation artifact, and when
% stimulation artifact is filtered using PARRM

figure
hold on
plot(((simData.downedTimes(1):simData.downedTimes(2)-sepChirp)-simData.downedTimes(1))/fs, simData.downedRecording(simData.downedTimes(1):simData.downedTimes(2)-sepChirp),'k','LineWidth',1)
plot(((simData.downedTimes(1):simData.downedTimes(2)-sepChirp)-simData.downedTimes(1))/fs, simData.downedChirps(simData.downedTimes(1):simData.downedTimes(2)-sepChirp),'Color',[17,193,184]/255,'LineWidth',1)
plot(((simData.downedTimes(1):simData.downedTimes(2)-sepChirp)-simData.downedTimes(1))/fs, Filtered(simData.downedTimes(1):simData.downedTimes(2)-sepChirp),'Color',[0,0,225]/255,'LineWidth',1)
axis tight
xlabel('Time (s)')
ylabel('Amplitude (mV)')
legend(["Raw","Artifact Free","PARRM Filtered"])
%% Chirp Spectrograms
% Plots continuous wavelet transforms for the first chirp when there is
% stimulation artifact, when there is no stimulation artifact, and when
% stimulation artifact is filtered using PARRM

fmax=100; % Max wavelet frequency
f=linspace(0,fmax,500); % All wavelet frequencies
cycles=linspace(1,30,500); % All wavelet cycles
f=f(2:end); % Remove the zero wavelet
cycles=cycles(2:end);
wavelet_half_win_size=11; % Window size for convolution
% Calculate wavelet transforms for the three cases
allWt=wavelet_transform_scratch(downedRecording, newFs, f, cycles, wavelet_half_win_size);
chirpsWt=wavelet_transform_scratch(downedChirps, newFs, f, cycles, wavelet_half_win_size);
filteredWt=wavelet_transform_scratch(Filtered, newFs, f, cycles, wavelet_half_win_size);

figure
subplot(1,3,1)
surface(((simData.downedTimes(1):simData.downedTimes(2)-sepChirp)-simData.downedTimes(1))/fs,f,10*log10(abs(allWt(:,simData.downedTimes(1):simData.downedTimes(2)-sepChirp))))
axis tight
shading interp
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('Raw')
caxis([-43.175285170456526,2.504559835797593])
subplot(1,3,2)
surface(((simData.downedTimes(1):simData.downedTimes(2)-sepChirp)-simData.downedTimes(1))/fs,f,10*log10(abs(chirpsWt(:,simData.downedTimes(1):simData.downedTimes(2)-sepChirp))))
axis tight
shading interp
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('Artifact Free')
caxis([-43.175285170456526,2.504559835797593])
subplot(1,3,3)
surface(((simData.downedTimes(1):simData.downedTimes(2)-sepChirp)-simData.downedTimes(1))/fs,f,10*log10(abs(filteredWt(:,simData.downedTimes(1):simData.downedTimes(2)-sepChirp))))
axis tight
shading interp
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('PARRM Filtered')
caxis([-43.175285170456526,2.504559835797593])