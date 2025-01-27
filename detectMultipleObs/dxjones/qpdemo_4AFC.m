% qpdemo_4AFC.m

clear

addpath(genpath('../toolboxes/mQUESTPlus'));


fprintf('Quest+ Demo, 4AFC\n');

%% simulate constrast threshold experiment

nTrials = 60;

% slope of psychometric function
beta = 3.5;
% percent correct when stimulus is invisible (random guessing)
gamma = 0.25;
% percent of trials when subject blinks; percent wrong responses on easy trials
delta = 0.01;

% simulate an observer

simulated_threshold_percent_contrast = 8.0;
simulated_threshold = contrast2db( simulated_threshold_percent_contrast );
simulatedPsiParams = [ simulated_threshold, beta, gamma, delta ];

fprintf('Simulated Threshold = %.3f percent contrast\n', db2contrast(simulated_threshold));
fprintf('Simulated Threshold = %.3f log units\n', simulated_threshold);


% ask QuestPlus to search between 0.1 and 100 percent contrast
% note: we convert to log(contrast) units for Quest

stimMin = contrast2db(  0.1 );
stimMax = contrast2db( 100.0 );

fprintf('QuestPlus will search between %.3f and %.3f log units\n', stimMin, stimMax);


stimDomain = linspace(stimMin, stimMax, 1000);

psiParamsDomain = { stimDomain, beta, gamma, delta };

param = qpParams( ...
    'nOutcomes', 2, ...
    'stimParamsDomainList', { stimDomain }, ...
    'psiParamsDomainList', psiParamsDomain, ...
    'stopRule', 'nTrials', ...
    'verbose', true );
    
questData = qpInitialize(param);

%% plot Psychometric Curve

figure(1);
N = numel(stimDomain);
percentCorrect = zeros(N,1);
for i = 1 : N
    p = qpPFWeibull(stimDomain(i), simulatedPsiParams);
    percentCorrect(i) = p(2);
end
figure(1);
semilogx(db2contrast(stimDomain), percentCorrect, 'b-', db2contrast(simulated_threshold), 0.750, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
legend('4AFC Psychometric Curve', '75% Correct Threshold', 'Location', 'NorthWest');
xlabel('Percent Contrast (log axis)');
ylabel('Percent Correct Responses');
title('Simulated Psychometric Function');
drawnow


%% run simulated experiment

numEasyTrials = 6;
for t = 1 : nTrials
%     stimulus = qpQuery(questData);
    stimulus = easy_stimulus(t, numEasyTrials, contrast2db(90), questData);

    p = qpPFWeibull(stimulus, simulatedPsiParams);
    
    response = qpSimulatedObserver(stimulus, @qpPFWeibull, simulatedPsiParams);

    fprintf('trial %2d, stimulus = %.2f, (%.2f percent contrast), p = [%.3f %.3f], response = %d\n', ...
        t, stimulus, db2contrast(stimulus), p(1), p(2), response);
    
    questData = qpUpdate(questData, stimulus, response);

end

%% summarize results

psiParamsIndex = qpListMaxArg(questData.posterior);
psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
fprintf('\n');
fprintf('Simulated parameters:              %0.3f, %0.3f, %0.3f, %0.3f\n', ...
    simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4));
fprintf('Max posterior QUEST+ parameters:   %0.3f, %0.3f, %0.3f, %0.3f\n', ...
    psiParamsQuest(1), psiParamsQuest(2), psiParamsQuest(3), psiParamsQuest(4));


psiParamsFit = qpFit(questData.trialData, questData.qpPF, psiParamsQuest, questData.nOutcomes, ...
    'lowerBounds', [stimMin beta gamma delta], 'upperBounds', [stimMax beta gamma delta]);
fprintf('Maximum likelihood fit parameters: %0.3f, %0.3f, %0.3f, %0.3f\n', ...
    psiParamsFit(1), psiParamsFit(2), psiParamsFit(3), psiParamsFit(4));

%% express in regular contrast units

measured_threshold_percent_contrast = db2contrast( psiParamsFit(1) );

fprintf('\n');
fprintf('Simulated threshold = %.3f percent contrast\n', simulated_threshold_percent_contrast);
fprintf('Measured threshold  = %.3f percent contrast\n', measured_threshold_percent_contrast);

