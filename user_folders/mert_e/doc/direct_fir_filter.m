% Systolic FIR Filter Simulation

% Define filter coefficients
coefficients = [0.1, -0.15, 0.2, -0.25, 0.3, -0.35, 0.4, -0.45, 0.5]; 

% Define input signal
x = [1, 2, 3, 4, 5, 6, 7, 8]; % Input signal
N = length(x); % Number of samples

% Initialize pipeline stages
num_coeffs = length(coefficients);
pipeline = zeros(num_coeffs, 1);

% Output signal
output_signal = zeros(1, N);

% Systolic FIR filter operation
for n = 1:N
    % Shift pipeline stages
    pipeline(2:end) = pipeline(1:end-1);
    pipeline(1) = x(n); % New input sample
    
    % Compute the filter output
    output_signal(n) = sum(pipeline .* coefficients(:));
end

% Plot input and output signals
figure;

subplot(2, 1, 1);
stem(0:N-1, x, 'filled', 'LineWidth', 1.5);
title('Input Signal');
xlabel('k');
ylabel('x[k]');
grid on;

subplot(2, 1, 2);
stem(0:N-1, output_signal, 'filled', 'LineWidth', 1.5);
title('Output Signal');
xlabel('k');
ylabel('y[k]');
grid on;

