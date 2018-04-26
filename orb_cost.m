random_pool = [27 15 12 8; 2 2 0 2; 28 25 18 24]; % 5*e, 4-5*, 3-4*
free_pull = false;
banner = 'hf';
focus_5s = [1 1 1 1]; % R, B, G, C
num_wanted = 1;
num_trials = 100000;
in_pool = [true false false];
color = 'b';

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tic
switch banner
    case 'reg'
        start_pct = [0.03 0.03 0.00 0.58 0.36];
        focus_4s = [0 0 0 0];
    case 'hf'
        start_pct = [0.05 0.03 0.00 0.58 0.34];
        focus_5s = [1 1 1 1];
        focus_4s = [0 0 0 0];
    case 'leg'
        start_pct = [0.08 0.00 0.00 0.58 0.34];
        focus_5s = [3 3 3 3];
        focus_4s = [0 0 0 0];
    case '45'
        start_pct = [0.03 0.03 0.29 0.29 0.36];
        focus_5s = [3 3 3 3];
        focus_4s = [3 3 3 3];
    otherwise
        start_pct = [0.03 0.03 0.00 0.58 0.36];
        focus_4s = [0 0 0 0];
end

switch color
    case 'r'
        desired_color = 1;
    case 'b'
        desired_color = 2;
    case 'g'
        desired_color = 3;
    case 'c'
        desired_color = 4;
    otherwise
        desired_color = 1;
end

n_rar = [focus_5s; random_pool(1,:)+random_pool(2,:); ...
        focus_4s; random_pool(2,:)+random_pool(3,:); ...
        random_pool(3,:)];
ratio_in_rar = n_rar ./ (sum(n_rar,2)*ones(1,4));
ratio_in_rar(isnan(ratio_in_rar)) = 0;

orbs = zeros(1,num_trials);
parfor i = 1:num_trials
    orbs(i) = summon(desired_color, num_wanted, free_pull, in_pool, ...
        start_pct, n_rar, ratio_in_rar);
    if mod(i, floor(num_trials/100)) == 0
        i
    end
end
toc

%%
avg = mean(orbs)
med = median(orbs)
pct90 = prctile(orbs,90)
pct97 = prctile(orbs,97)
sd = std(orbs)
mean_ratio = avg/med
%%
% hist(orbs,1800)
table = tabulate(orbs);
val = table(:,1);
pct = table(:,3)*.01;
fsp_ratio = med*log(1-pct(5))/-log(2)

% figure
% plot(val, pct)

binVal = 1:ceil(length(val)/5);
binPct = zeros(1, length(binVal));
binVal2 = zeros(1, length(binVal));
for i = 1:length(binVal)
    binPct(i) = sum(pct(i*5-4:min(i*5,end)))/5;
    binVal(i) = dot(val(i*5-4:min(i*5,end)), pct(i*5-4:min(i*5,end))) ...
                / binPct(i) / 5;
    binVal2(i) = 5*i-2.5;
end

% figure
% diff = binVal2 - binVal;
% plot(diff)

pd_wdl = fitdist(orbs', 'wbl')
pd_exp = fitdist(orbs', 'Exponential');
x = 1:max(orbs);
y_wdl = pdf(pd_wdl, x);
y_exp = pdf(pd_exp, x);

slope = 1.37297;
fsp = pct(5);
kSolve = @(k) gamma(1+1/k)-slope*log(2)^(1/k);
k = fzero(kSolve,1);
med_approx = -4*log(2)/log(1-fsp);
lambda = med_approx/log(2)^(1/k);
pd_app = makedist('wbl','a', lambda,'b', k);
y_app = pdf(pd_app, x);

figure
plot(binVal, binPct, binVal2, binPct, x, y_exp, x, y_wdl, x, y_app)
legend('Avg', 'Avg2', 'Exp', 'wbl', 'app')
xlabel('Orbs spent')
ylabel('Probability')
title('PDF')
% histfit(orbs, floor(max(orbs)/5), 'wbl')
%%
o = 413;
cdf = 1-exp(-(o/lambda).^k)

% %%
% figure
% plot(val, pct)
% xlabel('Orbs spent');
% ylabel('Probability (PDF)');
% axis([0 150 0 3.5e-2])
% title('Probability Distribution of Color Sniping Blue on Hero Fest') 
% 
% %%
% figure
% plot(binVal2, binPct, x, y_exp, x, y_wdl)
% legend('Avg', 'Exp', 'Wbl')
% xlabel('Orbs spent')
% ylabel('Probability (PDF)')
% title('PDF Averaged Over Every Five Orbs with Fitted Distributions')
% axis([0 300 0 0.01])


