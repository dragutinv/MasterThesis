function unified_edges = unify_edges(edges,L)
% 
% unified_edges = unify_edges(edges,L)
%
% Unifies edge segments detected between pairs of adjacent strips, which
% belong to the same long edge.
% 
% INPUT:
% -------------------------------------------------------------------------
% edges             - edges detected between pairs of adjacent strips
% L                 - width of strip
%
% OUTPUT:
% -------------------------------------------------------------------------
% unified_edges     - list of unified edges
% 
% Written by Inbal Horev, 2013

delta_a = 0.2;
delta_b = 2;    % allowing 2 pixels divergence in location of the two 
                % parts of the edge

% creating an edge bank. each new edge is checked against these for
% possible unification. initially the bank consists of the edges detected 
% between the first two adjacent strips.
y_i = edges{1,1};
y_f = edges{1,2};
X_i = edges{1,3};  % top
X_f = edges{1,4};  % bottom
A = (y_f-y_i)./(X_f-X_i);   % slope
B = y_i - A.*X_i;           % intercept

for i = 2:size(edges,1)
    % computing parameters of edges detected between the i, i+1 strips
    y_i = edges{i,1};
    y_f = edges{i,2};
    x_i = edges{i,3};
    x_f = edges{i,4};
    a = (y_f-y_i)./(x_f-x_i);
    b = y_i - a.*x_i;           % intercept at zero
    b_c = b + a.*(x_i + L/2);   % intercept at center of overlap                    
    
    for j = 1:length(a)
        B_c = B + A*(x_i(j) + L/2); % intercept at center of potential 
                                    % overlap region
        
        % an overlap is required for two edges to be unified
        % slope and intercept must be within certain bounds
        idx = (abs(a(j)-A)<delta_a) & (x_i(j) + L - 1 == X_f) & (abs(b_c(j)-B_c)<delta_b);                       
        
        if (sum(idx) > 0) % found an edge 
            
            dB = abs(b_c(j)-B_c);
            idx = idx & (dB == min(dB)); % choosing the edge with closest intercept
                        
            % averaging the slope and intercept
            A(idx) = 0.5*(A(idx) + a(j));   
            B(idx) = 0.5*(y_i(j) - a(j)*x_i(j) + B(idx));
            X_f(idx) = x_f(j);                        
        else % no match found, adding to edge bank for possible matches in 
             % neighboring strips
            A = [A a(j)];
            B = [B b(j)];
            X_i = [X_i x_i(j)];
            X_f = [X_f x_f(j)];
        end
    end
end

% returning a list of start and end points of the unified edges and those
% that did not need to be unified
unified_edges = cell(1,4);
unified_edges{1} = A.*X_i + B;
unified_edges{2} = A.*X_f + B;
unified_edges{3} = X_i;
unified_edges{4} = X_f;

