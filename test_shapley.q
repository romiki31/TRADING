/
Test suite for Shapley value implementation
\

\l shapley.q

\d .test

/ Test helper - check if values are approximately equal
approx:{[a;b;tol] abs[a-b]<tol}

/ Test 1: Simple 2-player game
test_2player:{[]
    -1"Test 1: 2-player game";
    
    / Coalition values
    v:(`$"0")!10f;
    v[`$"1"]:20f;
    v[`$"0,1"]:50f;
    
    vfunc:.shapley.make_vfunc[v];
    
    / Exact calculation
    exact:.shapley.shapley_exact[vfunc;2];
    
    / Expected: Player 0 gets 20, Player 1 gets 30
    / v({0}) = 10, v({1}) = 20, v({0,1}) = 50
    / SV(0) = 0.5 * 10 + 0.5 * (50-20) = 5 + 15 = 20
    / SV(1) = 0.5 * 20 + 0.5 * (50-10) = 10 + 20 = 30
    
    if[not approx[exact[0];20f;0.001]; '"Test 1 failed: Player 0"];
    if[not approx[exact[1];30f;0.001]; '"Test 1 failed: Player 1"];
    
    / Test efficiency
    if[not .shapley.check_efficiency[vfunc;2;exact]; '"Test 1 failed: Efficiency"];
    
    -1"Test 1: PASSED";
    }

/ Test 2: Null player
test_null_player:{[]
    -1"Test 2: Null player test";
    
    / 3-player game where player 2 contributes nothing
    v:(`$"0")!10f;
    v[`$"1"]:15f;
    v[`$"2"]:0f;
    v[`$"0,1"]:30f;
    v[`$"0,2"]:10f;
    v[`$"1,2"]:15f;
    v[`$"0,1,2"]:30f;
    
    vfunc:.shapley.make_vfunc[v];
    
    / Calculate Shapley values
    exact:.shapley.shapley_exact[vfunc;3];
    
    / Player 2 should have Shapley value = 0
    if[not approx[exact[2];0f;0.001]; '"Test 2 failed: Null player should have SV=0"];
    
    / Test with MC approximation
    mc:.shapley.shapley_mc[vfunc;3;5000];
    if[not approx[mc[2];0f;0.1]; '"Test 2 failed: MC null player"];
    
    -1"Test 2: PASSED";
    }

/ Test 3: Symmetric players
test_symmetric:{[]
    -1"Test 3: Symmetric players";
    
    / 3-player game where players 0 and 1 are symmetric
    v:(`$"0")!10f;
    v[`$"1"]:10f;
    v[`$"2"]:5f;
    v[`$"0,1"]:25f;
    v[`$"0,2"]:20f;
    v[`$"1,2"]:20f;
    v[`$"0,1,2"]:40f;
    
    vfunc:.shapley.make_vfunc[v];
    
    / Calculate Shapley values
    exact:.shapley.shapley_exact[vfunc;3];
    
    / Players 0 and 1 should have equal Shapley values
    if[not approx[exact[0];exact[1];0.001]; '"Test 3 failed: Symmetric players"];
    
    -1"Test 3: PASSED";
    }

/ Test 4: Monte Carlo convergence
test_mc_convergence:{[]
    -1"Test 4: Monte Carlo convergence test";
    
    / Create a 4-player game
    v:(`$"0")!5f;
    v[`$"1"]:8f;
    v[`$"2"]:6f;
    v[`$"3"]:4f;
    v[`$"0,1"]:20f;
    v[`$"0,2"]:15f;
    v[`$"0,3"]:12f;
    v[`$"1,2"]:18f;
    v[`$"1,3"]:15f;
    v[`$"2,3"]:13f;
    v[`$"0,1,2"]:35f;
    v[`$"0,1,3"]:30f;
    v[`$"0,2,3"]:28f;
    v[`$"1,2,3"]:32f;
    v[`$"0,1,2,3"]:50f;
    
    vfunc:.shapley.make_vfunc[v];
    
    / Exact calculation
    exact:.shapley.shapley_exact[vfunc;4];
    
    / Test different sample sizes
    samples:100 500 1000 5000 10000;
    errors:{[vfunc;exact;k]
        mc:.shapley.shapley_mc[vfunc;4;k];
        avg abs[value[mc] - value[exact]]
        }[vfunc;exact;] each samples;
    
    / Errors should generally decrease with more samples
    if[not errors[0]>errors[4]; -1"Warning: MC may not be converging properly"];
    
    -1"Average errors by sample size:";
    show samples,'errors;
    
    -1"Test 4: PASSED";
    }

/ Test 5: Stratified vs regular MC
test_stratified:{[]
    -1"Test 5: Stratified sampling comparison";
    
    / 5-player game
    n:5;
    players:til n;
    
    / Generate random coalition values
    coalitions:raze {[n;k] {x[y,/:til[count x]except\:y]}/[til n;] each til k}[n;] each 1+til n-1;
    
    v:enlist[`$""]!enlist[0f];
    v,:(`$"," sv string each coalitions)!20+coalitions?\:80f;
    v[`$"0,1,2,3,4"]:sum v;
    
    vfunc:.shapley.make_vfunc[v];
    
    / Compare variance over multiple runs
    nruns:20;
    
    mc_results:{[vfunc;n;k;nr]
        {.shapley.shapley_mc[vfunc;n;k]}[vfunc;n;k;] each til nr
        }[vfunc;n;2000;nruns];
    
    strat_results:{[vfunc;n;k;nr]
        {.shapley.shapley_stratified[vfunc;n;k]}[vfunc;n;k;] each til nr
        }[vfunc;n;2000;nruns];
    
    / Calculate variance for each player
    mc_var:{var x[;y]}[mc_results;] each players;
    strat_var:{var x[;y]}[strat_results;] each players;
    
    -1"Variance comparison (MC vs Stratified):";
    show flip `player`mc_variance`strat_variance`reduction!(players;mc_var;strat_var;1-strat_var%mc_var);
    
    / Stratified should generally have lower variance
    if[avg[strat_var]>avg[mc_var]; -1"Warning: Stratified not showing variance reduction"];
    
    -1"Test 5: PASSED";
    }

/ Test 6: Large game performance
test_performance:{[]
    -1"Test 6: Performance test";
    
    / Test with different player counts
    ns:5 10 15 20;
    
    times:{[n]
        / Simple additive game
        v:{[c] sum c}; 
        
        t1:.z.t;
        sv:.shapley.shapley_mc[v;n;1000];
        t2:.z.t;
        
        `n`time!(n;`time$t2-t1)
        } each ns;
    
    -1"Performance (1000 samples):";
    show times;
    
    / Check that all completed without error
    if[any null times[;`time]; '"Test 6 failed: Performance test error"];
    
    -1"Test 6: PASSED";
    }

/ Run all tests
run_all:{[]
    -1"Running Shapley value test suite...";
    -1"==================================";
    
    tests:(test_2player;test_null_player;test_symmetric;
           test_mc_convergence;test_stratified;test_performance);
    
    failed:0;
    
    {[t;f]
        @[t;`;{[f;e] f+:1; -1"FAILED: ",e; f}[f]];
        f
    }/[failed;tests];
    
    -1"\n==================================";
    if[failed=0;
        -1"All tests PASSED!";
    ;
        -1"Tests failed: ",string failed;
    ];
    
    failed=0
    }

\d .

/ Run tests if called directly
if[`test_shapley.q~last` vs hsym .z.f; .test.run_all[]]