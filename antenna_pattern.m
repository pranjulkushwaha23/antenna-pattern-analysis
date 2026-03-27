% =========================================================
% Antenna Pattern Analysis & Comparison
% Author: Pranjul Kumar
% Antennas: Patch, Dipole, Yagi, LPDA
% IIT Jammu M.Tech | Enercomp Solutions Pvt. Ltd.
% =========================================================

clc; clear; close all;

%% ---- ANTENNA PARAMETERS --------------------------------

% All antennas designed for 866 MHz ISM band
freq_MHz = 866;
lambda   = 3e8 / (freq_MHz * 1e6);   % wavelength in metres

fprintf('Antenna Analysis @ %d MHz\n', freq_MHz);
fprintf('Wavelength: %.3f m\n\n', lambda);

%% ---- RADIATION PATTERNS --------------------------------
% Analytical approximations for each antenna type
% Replace with CST-exported data if available (see section below)

theta = linspace(0, 2*pi, 3600);   % azimuth angle 0-360 deg

% 1. Half-wave Dipole pattern: cos²(π/2 · cosθ) / sin²θ
%    Approximated in 2D azimuth as near-omnidirectional
dipole = ones(size(theta));         % omnidirectional in azimuth
dipole_gain_dBi = 2.15;

% 2. Patch antenna (directional, ~70 deg HPBW)
patch = max(0, cos(theta - pi/2)).^3;
patch = patch / max(patch);
patch_gain_dBi = 7.0;

% 3. Yagi-Uda (3-element, ~60 deg HPBW)
yagi = max(0, cos(theta - pi/2)).^5;
yagi = yagi / max(yagi);
yagi_gain_dBi = 9.0;

% 4. LPDA (Log-Periodic Dipole Array, ~60 deg HPBW, wideband)
lpda = max(0, cos(theta - pi/2)).^5 .* ...
       (1 + 0.1*cos(4*(theta - pi/2)));
lpda = lpda / max(lpda);
lpda_gain_dBi = 10.5;

%% ---- PLOT 1: POLAR RADIATION PATTERNS -----------------

figure(1);
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

antennas = {dipole, patch, yagi, lpda};
names    = {'Half-wave Dipole', 'Patch Antenna', ...
            'Yagi-Uda (3-el)', 'LPDA'};
gains    = {dipole_gain_dBi, patch_gain_dBi, ...
            yagi_gain_dBi, lpda_gain_dBi};
colors   = {'b', 'r', 'g', 'm'};

for i = 1:4
    nexttile;
    polarplot(theta, antennas{i}, colors{i}, 'LineWidth', 2);
    title(sprintf('%s\nGain: %.1f dBi', names{i}, gains{i}));
    pax = gca;
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir = 'clockwise';
end

sgtitle(sprintf('Antenna Radiation Patterns @ %d MHz', freq_MHz), ...
        'FontSize', 14, 'FontWeight', 'bold');

%% ---- PLOT 2: GAIN COMPARISON BAR CHART ----------------

figure(2);
gain_values = [dipole_gain_dBi, patch_gain_dBi, ...
               yagi_gain_dBi, lpda_gain_dBi];
antenna_names = {'Dipole', 'Patch', 'Yagi', 'LPDA'};

b = bar(gain_values, 0.5);
b.FaceColor = 'flat';
b.CData = [0 0.4 0.8;
           0.8 0.2 0.2;
           0.2 0.7 0.2;
           0.6 0.2 0.8];

set(gca, 'XTickLabel', antenna_names, 'FontSize', 12);
ylabel('Gain (dBi)');
title(sprintf('Antenna Gain Comparison @ %d MHz', freq_MHz));
grid on; ylim([0 15]);

for i = 1:length(gain_values)
    text(i, gain_values(i) + 0.2, sprintf('%.1f dBi', gain_values(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 11, ...
         'FontWeight', 'bold');
end

%% ---- PLOT 3: VSWR vs FREQUENCY ------------------------

figure(3);
freq_sweep = 700:1:1100;     % MHz

% Typical VSWR curves for each antenna (modelled as resonant systems)
vswr_dipole = 1 + 3.0 * ((freq_sweep - 866).^2 / (866*0.05)^2);
vswr_patch  = 1 + 4.0 * ((freq_sweep - 866).^2 / (866*0.03)^2);
vswr_yagi   = 1 + 3.5 * ((freq_sweep - 866).^2 / (866*0.04)^2);
vswr_lpda   = 1 + 1.5 * ((freq_sweep - 800).^2 / (866*0.20)^2);

% Clip to realistic range
vswr_dipole = min(vswr_dipole, 6);
vswr_patch  = min(vswr_patch,  6);
vswr_yagi   = min(vswr_yagi,   6);
vswr_lpda   = min(vswr_lpda,   6);

plot(freq_sweep, vswr_dipole, 'b-',  'LineWidth', 2); hold on;
plot(freq_sweep, vswr_patch,  'r-',  'LineWidth', 2);
plot(freq_sweep, vswr_yagi,   'g-',  'LineWidth', 2);
plot(freq_sweep, vswr_lpda,   'm-',  'LineWidth', 2);
yline(1.5, '--k', 'VSWR = 1.5 (target)', ...
      'LabelHorizontalAlignment', 'left', 'LineWidth', 1.5);
xline(865, ':k', '865 MHz'); xline(867, ':k', '867 MHz');

xlabel('Frequency (MHz)'); ylabel('VSWR');
title('VSWR vs Frequency — 865–867 MHz ISM Band');
legend('Dipole', 'Patch', 'Yagi', 'LPDA', 'Location', 'northwest');
grid on; ylim([1 6]);
xlim([700 1100]);

%% ---- PLOT 4: LINK RANGE vs ANTENNA GAIN ---------------

figure(4);
TX_power_dBm     = 30;
TX_ant_dBi       = 2.5;
TX_cable_dB      = 1.0;
RX_cable_dB      = 1.0;
RX_sens_dBm      = -121;
required_margin  = 10;

rx_gains = 0:0.5:20;
ranges   = zeros(size(rx_gains));

for i = 1:length(rx_gains)
    budget = TX_power_dBm + TX_ant_dBi - TX_cable_dB + ...
             rx_gains(i) - RX_cable_dB - RX_sens_dBm;
    ranges(i) = 10^((budget - required_margin - ...
                20*log10(freq_MHz) - 32.45) / 20);
end

plot(rx_gains, ranges, 'b-', 'LineWidth', 2); hold on;

% Mark each antenna type
ant_gains  = [dipole_gain_dBi, patch_gain_dBi, ...
              yagi_gain_dBi,   lpda_gain_dBi];
ant_names  = {'Dipole', 'Patch', 'Yagi', 'LPDA'};
ant_colors = {'bo', 'rs', 'g^', 'md'};

for i = 1:4
    budget = TX_power_dBm + TX_ant_dBi - TX_cable_dB + ...
             ant_gains(i) - RX_cable_dB - RX_sens_dBm;
    r = 10^((budget - required_margin - ...
             20*log10(freq_MHz) - 32.45) / 20);
    plot(ant_gains(i), r, ant_colors{i}, 'MarkerSize', 10, ...
         'MarkerFaceColor', ant_colors{i}(1), 'LineWidth', 2);
    text(ant_gains(i) + 0.3, r, sprintf('%s\n%.1f km', ...
         ant_names{i}, r), 'FontSize', 10);
end

xlabel('RX Antenna Gain (dBi)');
ylabel('Practical Range (km)');
title('Practical Range vs RX Antenna Gain @ 866 MHz');
legend('Range curve', 'Dipole', 'Patch', 'Yagi', 'LPDA', ...
       'Location', 'northwest');
grid on;

%% ---- RESULTS TABLE ------------------------------------

fprintf('==============================================\n');
fprintf('  ANTENNA COMPARISON @ %d MHz\n', freq_MHz);
fprintf('==============================================\n');
fprintf('%-12s %-10s %-10s %-12s\n', 'Antenna', ...
        'Gain(dBi)', 'VSWR', 'Range(km)');
fprintf('%s\n', repmat('-', 1, 46));

for i = 1:4
    budget = TX_power_dBm + TX_ant_dBi - TX_cable_dB + ...
             ant_gains(i) - RX_cable_dB - RX_sens_dBm;
    r = 10^((budget - required_margin - ...
             20*log10(freq_MHz) - 32.45) / 20);
    fprintf('  %-10s %-10.1f %-10s %-12.1f\n', ...
            ant_names{i}, ant_gains(i), '<1.5', r);
end
fprintf('==============================================\n');
