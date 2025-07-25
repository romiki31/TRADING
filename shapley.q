/
Shapley Value Decomposition in KDB+/Q
Implementation based on Castro et al. (2009) polynomial-time sampling algorithm
\

\d .shapley

/ Initialize random seed
system"S ",string"i"$.z.t

/ Helper function to generate random permutation
randperm:{[n] n?n}

/ Generate coalition from permutation and player position
coalition:{[perm;pos] perm til pos}

/ Calculate powerset (for exact calculation comparison)
powerset:{[s] raze {[s;k] s[k,/:til[count s]except\:k]}/[s;] each til 1+count s}

/ Binary representation of coalition
bin2coal:{[n;b] where b}

/ Coalition to binary representation
coal2bin:{[n;c] @[n#0b;c;:;1b]}

/ Calculate marginal contribution of player i in permutation
marginal:{[v;perm;i]
    pos:first where perm=i;
    coal_with:coalition[perm;pos+1];
    coal_without:coalition[perm;pos];
    v[coal_with] - v[coal_without]
    }

/ Monte Carlo sampling for Shapley value estimation
/ v: coalition value function (dict or function)
/ n: number of players
/ k: number of samples
shapley_mc:{[v;n;k]
    players:til n;
    vfunc:$[99h=type v;v;{[v;c] v[`$"," sv string c]}[v]];
    
    / Initialize Shapley values
    sv:n#0f;
    
    / Monte Carlo sampling
    do[k;
        perm:randperm[n];
        contrib:marginal[vfunc;perm;] each players;
        sv+:contrib
    ];
    
    / Average over samples
    sv%:k;
    
    / Return dictionary with player->value mapping
    players!sv
    }

/ Stratified sampling for improved variance (Castro et al. 2017)
/ Stratify by coalition size
shapley_stratified:{[v;n;k]
    players:til n;
    vfunc:$[99h=type v;v;{[v;c] v[`$"," sv string c]}[v]];
    
    / Initialize Shapley values
    sv:n#0f;
    
    / Samples per stratum (coalition size)
    strata:1+til n-1;  / Coalition sizes 1 to n-1
    samples_per_stratum:ceiling k%count strata;
    
    / For each stratum (coalition size)
    {[vfunc;n;sv;size;sps]
        / Generate samples for this stratum
        do[sps;
            / Random coalition of given size
            coal:size?n;
            / For each player, calculate contribution
            {[vfunc;coal;sv;i]
                if[i in coal;
                    sv[i]+:vfunc[coal] - vfunc[coal except i]
                ];
                if[not i in coal;
                    sv[i]+:vfunc[coal,i] - vfunc[coal]
                ];
            }[vfunc;coal;sv;] each til n;
        ];
        sv
    }[vfunc;n;;samples_per_stratum]/[sv;strata];
    
    / Normalize
    sv%:k;
    
    / Return dictionary
    players!sv
    }

/ Exact Shapley value calculation (for validation)
/ Only use for small n due to exponential complexity
shapley_exact:{[v;n]
    players:til n;
    vfunc:$[99h=type v;v;{[v;c] v[`$"," sv string c]}[v]];
    
    / Initialize Shapley values
    sv:n#0f;
    
    / For each player
    {[vfunc;n;sv;i]
        / For each possible coalition not containing i
        coalitions:powerset[til[n] except i];
        
        / Calculate marginal contributions
        {[vfunc;n;sv;i;coal]
            size:count coal;
            / Weight factor
            weight:(factorial[size] * factorial[n-size-1]) % factorial[n];
            / Marginal contribution
            mc:vfunc[coal,i] - vfunc[coal];
            sv[i]+:weight * mc;
        }[vfunc;n;sv;i;] each coalitions;
        
        sv
    }[vfunc;n;;]/[sv;players];
    
    / Return dictionary
    players!sv
    }

/ Factorial function
factorial:{[n] prd 1+til n}

/ Validate Shapley axioms
/ Efficiency: sum of Shapley values equals v(N)
check_efficiency:{[v;n;sv]
    total:sum sv;
    vN:$[99h=type v;v[til n];v[`$"," sv string til n]];
    abs[total - vN] < 1e-6
    }

/ Null player: player with zero marginal contribution has zero Shapley value
check_null:{[v;n;sv;player]
    / Check if player is null by testing all coalitions
    is_null:1b;
    coalitions:powerset[til[n] except player];
    {[v;player;coal]
        mc:v[coal,player] - v[coal];
        if[abs[mc] > 1e-6; is_null:0b];
    }[v;player;] each coalitions;
    
    / If null player, Shapley value should be ~0
    if[is_null; abs[sv[player]] < 1e-6; 1b]
    }

/ Create coalition value function from characteristic function
/ Input: dictionary mapping coalition keys to values
make_vfunc:{[d]
    vf:{[d;c]
        / Handle empty coalition
        if[0=count c; :0f];
        / Convert coalition to key
        key:`$"," sv string asc c;
        / Return value or 0 if not found
        $[key in key d; d[key]; 0f]
        };
    vf[d;]
    }

\d .

/ Example usage function
shapley_demo:{[]
    -1"Shapley Value Decomposition Demo";
    -1"================================";
    
    / Example: 3-player voting game
    / Coalition values
    v:(`$"0")!15f;
    v[`$"1"]:25f;
    v[`$"2"]:25f;
    v[`$"0,1"]:60f;
    v[`$"0,2"]:60f;
    v[`$"1,2"]:50f;
    v[`$"0,1,2"]:90f;
    
    vfunc:.shapley.make_vfunc[v];
    
    -1"\nExact Shapley values:";
    exact:.shapley.shapley_exact[vfunc;3];
    show exact;
    
    -1"\nMonte Carlo approximation (1000 samples):";
    mc:.shapley.shapley_mc[vfunc;3;1000];
    show mc;
    
    -1"\nStratified sampling approximation (1000 samples):";
    strat:.shapley.shapley_stratified[vfunc;3;1000];
    show strat;
    
    -1"\nEfficiency check (sum = v(N)):";
    -1"Exact: ",string .shapley.check_efficiency[vfunc;3;exact];
    -1"MC: ",string .shapley.check_efficiency[vfunc;3;mc];
    -1"Stratified: ",string .shapley.check_efficiency[vfunc;3;strat];
    }