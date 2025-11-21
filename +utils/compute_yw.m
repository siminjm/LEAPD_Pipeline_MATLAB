% +utils/compute_yw.m (simpler version)
function LPC = compute_yw(Xf, order)
% COMPUTE_YW - AR (Burg) coefficients per subject

    n = numel(Xf);
    LPC = zeros(n, order);  % Always return n x order
    
    for i = 1:n
        x = Xf{i};
        if isempty(x) || numel(x) < order*2
            LPC(i,:) = zeros(1, order);
            continue;
        end
        
        try
            a = arburg(x, order);
            % Always take exactly 'order' coefficients
            if length(a) >= order + 1
                LPC(i,:) = a(2:order+1);
            else
                % Pad with zeros if not enough coefficients
                LPC(i,:) = [a(2:end), zeros(1, order - (length(a)-1))];
            end
        catch ME
            % If AR fails, use zeros and continue
            LPC(i,:) = zeros(1, order);
        end
    end
end