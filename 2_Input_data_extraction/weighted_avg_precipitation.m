function weighted_avg_precip = weighted_avg_precipitation(precipitation_data, distance, traj_step)
    % weighted_avg_precipitation computes the weighted average precipitation
    % varied R and weights
    
    % Inputs:
    % - precipitation: 2D matrix of precipitation values (e.g., 1800x3600)
    % - distance: 2D array of distance values (e.g., 1800x3600)
    % - traj_step: Integer trajectory step value
    
    % Output:
    % - weighted_avg_precip: Weighted average precipitation at the target location

    % Determine distance threshold based on traj_step
    if traj_step <= 6
        distance_threshold = 5.5; % Fixed distance threshold in km
    else
        distance_threshold = 0.6856 * traj_step^1.162; % Dynamic threshold
    end

    % Find the mask of points within the distance threshold
    mask = distance <= distance_threshold;

    % Extract precipitation values and corresponding distances within the mask
    precip_within_threshold = precipitation_data(mask);
    distances_within_threshold = distance(mask);

    % Calculate weights based on the distance formula
    weights = 1.012 ./ (1 + 0.001425 * distances_within_threshold.^1.613);

    % Compute the weighted average precipitation
    if ~isempty(precip_within_threshold)
        weighted_avg_precip = weighted_mean(precip_within_threshold,weights,1);
    else
        % Fallback to nearest precipitation if no points within threshold
        [~, min_index] = min(distance(:));
        weighted_avg_precip = precipitation_data(min_index);
    end
end
