/
Examples of Shapley value calculations for various game types
\

\l shapley.q

-1"Shapley Value Examples";
-1"=====================\n";

/ Example 1: Voting Game
-1"Example 1: Weighted Voting Game";
-1"------------------------------";
-1"Three parties with votes: A=45, B=35, C=20. Need 51 for majority.\n";

voting_game:{[]
    / Coalition values: 1 if coalition has majority, 0 otherwise
    v:enlist[`$""]!enlist[0f];
    v[`$"0"]:0f;      / Party A: 45 votes
    v[`$"1"]:0f;      / Party B: 35 votes  
    v[`$"2"]:0f;      / Party C: 20 votes
    v[`$"0,1"]:1f;    / A+B: 80 votes (majority)
    v[`$"0,2"]:1f;    / A+C: 65 votes (majority)
    v[`$"1,2"]:0f;    / B+C: 55 votes (majority)
    v[`$"0,1,2"]:1f;  / All: 100 votes
    
    vfunc:.shapley.make_vfunc[v];
    
    -1"Coalition values (1=winning coalition, 0=losing):";
    show v;
    
    -1"\nShapley values (voting power):";
    sv:.shapley.shapley_exact[vfunc;3];
    show `Party`Votes`Power!(`A`B`C;45 35 20;value sv);
    
    -1"\nInterpretation: Party C has no voting power despite 20 votes";
    -1"because it cannot change any losing coalition to winning.\n";
    };

/ Example 2: Airport Game
-1"\nExample 2: Airport Landing Fees";
-1"--------------------------------";
-1"Cost allocation for runway construction based on aircraft needs.\n";

airport_game:{[]
    / Costs for different runway lengths
    / Small planes need 1km, medium need 2km, large need 3km
    costs:`1km`2km`3km!100 180 240f;
    
    / Coalition cost = cost of longest runway needed
    v:enlist[`$""]!enlist[0f];
    v[`$"0"]:costs[`1km];     / Small plane
    v[`$"1"]:costs[`2km];     / Medium plane
    v[`$"2"]:costs[`3km];     / Large plane
    v[`$"0,1"]:costs[`2km];   
    v[`$"0,2"]:costs[`3km];
    v[`$"1,2"]:costs[`3km];
    v[`$"0,1,2"]:costs[`3km];
    
    vfunc:.shapley.make_vfunc[v];
    
    -1"Runway construction costs:";
    show costs;
    
    -1"\nCoalition costs:";
    show v;
    
    -1"\nCost allocation using Shapley values:";
    sv:.shapley.shapley_exact[vfunc;3];
    show `Aircraft`Needs`Cost!(`Small`Medium`Large;`1km`2km`3km;value sv);
    
    -1"\nNote: Each aircraft pays for its incremental runway extension.\n";
    };

/ Example 3: Production Game
-1"\nExample 3: Joint Production";
-1"---------------------------";
-1"Three firms can produce more together than separately.\n";

production_game:{[]
    / Production values with synergies
    v:enlist[`$""]!enlist[0f];
    v[`$"0"]:100f;    / Firm A alone
    v[`$"1"]:80f;     / Firm B alone
    v[`$"2"]:60f;     / Firm C alone
    v[`$"0,1"]:200f;  / A+B (synergy)
    v[`$"0,2"]:180f;  / A+C (synergy)
    v[`$"1,2"]:150f;  / B+C (synergy)
    v[`$"0,1,2"]:300f;/ All together (max synergy)
    
    vfunc:.shapley.make_vfunc[v];
    
    -1"Production values:";
    show v;
    
    -1"\nProfit allocation using Shapley values:";
    sv:.shapley.shapley_exact[vfunc;3];
    show `Firm`Alone`Shapley!(`A`B`C;100 80 60;value sv);
    
    -1"\nMonte Carlo approximation (5000 samples):";
    mc:.shapley.shapley_mc[vfunc;3;5000];
    show `Firm`MC_5000!(`A`B`C;value mc);
    
    -1"\nStratified sampling (5000 samples):";
    strat:.shapley.shapley_stratified[vfunc;3;5000];
    show `Firm`Stratified_5000!(`A`B`C;value strat);
    };

/ Example 4: Network Game
-1"\nExample 4: Network/Graph Game";
-1"-----------------------------";
-1"Value depends on network connectivity.\n";

network_game:{[]
    / 4 nodes: value = number of connected components * 10
    / Simplified: more connections = more value
    
    v:enlist[`$""]!enlist[0f];
    v[`$"0"]:10f;
    v[`$"1"]:10f;
    v[`$"2"]:10f;
    v[`$"3"]:10f;
    v[`$"0,1"]:25f;   / Connected pair
    v[`$"0,2"]:25f;
    v[`$"0,3"]:20f;   / Weaker connection
    v[`$"1,2"]:25f;
    v[`$"1,3"]:20f;
    v[`$"2,3"]:25f;
    v[`$"0,1,2"]:45f;
    v[`$"0,1,3"]:40f;
    v[`$"0,2,3"]:40f;
    v[`$"1,2,3"]:45f;
    v[`$"0,1,2,3"]:70f; / Full network
    
    vfunc:.shapley.make_vfunc[v];
    
    -1"Network with 4 nodes - coalition values:";
    -1"(Higher values for better connected subnetworks)";
    
    / Use Monte Carlo for 4 players
    -1"\nShapley values (10000 samples):";
    sv:.shapley.shapley_mc[vfunc;4;10000];
    show `Node`Value!(`N0`N1`N2`N3;value sv);
    
    -1"\nNodes 0,1,2 are more central (higher Shapley values).\n";
    };

/ Example 5: Machine Learning Feature Importance
-1"\nExample 5: ML Feature Importance (SHAP-style)";
-1"---------------------------------------------";
-1"Simplified model: predicting house prices with 3 features.\n";

ml_feature_game:{[]
    / Features: Size(0), Location(1), Age(2)
    / Model accuracy (R²) with different feature subsets
    
    v:enlist[`$""]!enlist[0f];
    v[`$"0"]:0.4f;     / Size alone
    v[`$"1"]:0.5f;     / Location alone  
    v[`$"2"]:0.2f;     / Age alone
    v[`$"0,1"]:0.75f;  / Size+Location
    v[`$"0,2"]:0.5f;   / Size+Age
    v[`$"1,2"]:0.6f;   / Location+Age
    v[`$"0,1,2"]:0.85f;/ All features
    
    vfunc:.shapley.make_vfunc[v];
    
    -1"Model R² with different feature combinations:";
    show v;
    
    -1"\nFeature importance (Shapley values):";
    sv:.shapley.shapley_exact[vfunc;3];
    show `Feature`Importance!(`Size`Location`Age;value sv);
    
    -1"\nLocation is most important, followed by Size.\n";
    };

/ Example 6: Performance comparison
-1"\nExample 6: Algorithm Performance Comparison";
-1"------------------------------------------";

performance_demo:{[]
    / Create a larger game (10 players)
    n:10;
    
    / Random additive game with interactions
    / v(S) = sum(S) + random interaction bonus
    vdict:enlist[`$""]!enlist[0f];
    
    / Single players
    vdict,:(`$string each til n)!10+til[n]*5f;
    
    / Some 2-player coalitions with synergy
    pairs:{x,/:x _ til y}[;n] each til n-1;
    pairs:raze pairs;
    vdict,:(`$"," sv' string each pairs)!{x+y+15}.'pairs;
    
    / Grand coalition
    vdict[`$"," sv string til n]:sum[vdict]+50;
    
    vfunc:.shapley.make_vfunc[vdict];
    
    -1"Testing with ",string[n]," players...";
    
    / Time different methods
    -1"\nMethod comparison:";
    
    / MC with different sample sizes
    samples:1000 5000 10000;
    
    results:{[vfunc;n;k]
        t1:.z.t;
        sv:.shapley.shapley_mc[vfunc;n;k];
        t2:.z.t;
        `method`samples`time`total!(`MC;k;`time$t2-t1;sum sv)
        }[vfunc;n;] each samples;
    
    / Stratified sampling
    results,:{[vfunc;n;k]
        t1:.z.t;
        sv:.shapley.shapley_stratified[vfunc;n;k];
        t2:.z.t;
        `method`samples`time`total!(`Stratified;k;`time$t2-t1;sum sv)
        }[vfunc;n;] each samples;
    
    show results;
    
    -1"\nAll methods satisfy efficiency (sum ≈ v(N) = ",string[vdict[`$"," sv string til n]],")";
    };

/ Run examples
run_examples:{[]
    examples:(
        (`voting;voting_game);
        (`airport;airport_game);
        (`production;production_game);
        (`network;network_game);
        (`ml;ml_feature_game);
        (`performance;performance_demo)
    );
    
    -1"Select an example to run:";
    -1"  1. voting     - Weighted voting game";
    -1"  2. airport    - Airport cost allocation";
    -1"  3. production - Joint production with synergies";
    -1"  4. network    - Network connectivity game";
    -1"  5. ml         - ML feature importance";
    -1"  6. performance- Performance comparison";
    -1"  7. all        - Run all examples\n";
    
    -1"Usage: run_examples.voting[] or run_examples.all[]";
    
    (`voting`airport`production`network`ml`performance`all)!(
        voting_game;airport_game;production_game;
        network_game;ml_feature_game;performance_demo;
        {voting_game[];airport_game[];production_game[];
         network_game[];ml_feature_game[];performance_demo[]}
    )
    };

run_examples:run_examples[];