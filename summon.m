function [orbs_spent] = summon(desired_color, num_wanted, free_pull, ...
                                in_pool, start_pct, n_rar, ratio_in_rar)
summon_complete = false;
num_pulled = 0;
pity_rate_count = 0;
orbs_spent = 0;
pity_breakers = 0;
while ~summon_complete
    pull = rand(1,5);
    pity_incr = floor(pity_rate_count / 5) * .005;
    curr_pct = start_pct + pity_incr * start_pct ./ ...
                [ones(1,2)*(start_pct(1)+start_pct(2)) ...
                -ones(1,3)*(start_pct(3)+start_pct(4)+start_pct(5))];
    p_d = ratio_in_rar .* curr_pct(ones(1,4),:)'; % Probability of draw
    color_prob = sum(p_d);
    color_cutoff = [0 cumsum(color_prob)];
    stone_color = sum(pull(ones(1,5),:) > color_cutoff(ones(1,5),:)');
    stone_remainder = pull - color_cutoff(stone_color);
    if sum(stone_color == desired_color) > 0
        cost_index = 1;
        pity_broken = false;
        for i = 1:5
            c = stone_color(i);
            r = stone_remainder(i);
            if c == desired_color
                orbs_spent = orbs_spent + 5 - floor((cost_index + 1)/3);
                pity_rate_count = pity_rate_count + 1;
                cost_index = cost_index + 1;
                if r < p_d(1,c)/n_rar(1,c)
                    num_pulled = num_pulled + 1;
                    pity_broken = true;
                elseif in_pool(1) && r > p_d(1,c) && ...
                        r < p_d(1,c)+p_d(2,c)/n_rar(2,c)
                    num_pulled = num_pulled + 1;
                    pity_broken = true;
                elseif r < sum(p_d(1:2,c))
                    pity_breakers = pity_breakers + 1;
                    pity_broken = true;
                elseif n_rar(3,c) > 0 && ...
                        r < sum(p_d(1:2,c))+p_d(3,c)/n_rar(3,c)
                    num_pulled = num_pulled + 1;
                elseif in_pool(2) && r > sum(p_d(1:3,c)) && ...
                        r < sum(p_d(1:3,c))+p_d(4,c)/n_rar(4,c)
                    num_pulled = num_pulled + 1;
                elseif in_pool(3) && r > sum(p_d(1:4,c)) && ...
                        r < sum(p_d(1:4,c))+p_d(5,c)/n_rar(5,c)
                    num_pulled = num_pulled + 1;
                end
                if num_pulled == num_wanted
                    summon_complete = true;
                    break
                end
            end
        end
        if pity_broken
            pity_rate_count = 0;
        end
    else
        [~, alt_color] = min((p_d(1,:)+p_d(2,:)) ./ color_prob ...
            + ~ismember([1 2 3 4], stone_color));
        for i = 1:5
            if stone_color(i) == alt_color
                orbs_spent = orbs_spent + 5;
                pity_rate_count = pity_rate_count + 1;
                if stone_remainder(i) < sum(p_d(1:2,alt_color))
                    pity_breakers = pity_breakers + 1;
                    pity_rate_count = 0;
                end
                break
            end
        end
    end
end
if free_pull
    orbs_spent = orbs_spent - 5;
end
end

% stone_color = sum(pull(ones(1,5),:)' > color_cutoff(ones(1,5),:), 2)';
% stone_color = zeros(1,5);
% stone_remainder = zeros(1,5);
% for i = 1:5
%     stone_color(i) = sum(pull(i) > color_cutoff);;
%     stone_remainder(i) = pull(i) - color_cutoff(stone_color(i));
% end

