# Shapley Value Decomposition in KDB+/Q

Implementation of polynomial-time Shapley value calculation based on Castro et al. (2009) sampling algorithm.

## Overview

The Shapley value is a solution concept in cooperative game theory that assigns a unique distribution of a coalition's total gains to its players. This implementation provides:

- **Exact calculation** for small games (exponential complexity)
- **Monte Carlo approximation** with polynomial complexity O(k×n)
- **Stratified sampling** for improved variance reduction
- **Validation tools** for Shapley axioms

## Algorithm

Based on Castro et al. (2009) "Polynomial calculation of the Shapley value based on sampling":

1. Generate random permutations of players
2. Calculate marginal contributions for each permutation
3. Average contributions across samples
4. Stratified version samples by coalition size for variance reduction

## Installation

```bash
# Clone and navigate to directory
cd /workspaces/TRADING

# Load in Q
q shapley.q
```

## Usage

### Basic Example

```q
/ Load the library
\l shapley.q

/ Define coalition values
v:(`$"0")!15f;
v[`$"1"]:25f;
v[`$"0,1"]:50f;

/ Create value function
vfunc:.shapley.make_vfunc[v];

/ Calculate exact Shapley values
exact:.shapley.shapley_exact[vfunc;2]
/ 0| 20
/ 1| 30

/ Monte Carlo approximation
mc:.shapley.shapley_mc[vfunc;2;1000]
```

### API Reference

#### Main Functions

- **`.shapley.shapley_exact[vfunc;n]`**
  - Exact Shapley value calculation
  - Parameters: `vfunc` (value function), `n` (number of players)
  - Returns: Dictionary of player→value
  - Complexity: O(2^n)

- **`.shapley.shapley_mc[vfunc;n;k]`**
  - Monte Carlo approximation
  - Parameters: `vfunc`, `n`, `k` (number of samples)
  - Returns: Dictionary of player→value
  - Complexity: O(k×n)

- **`.shapley.shapley_stratified[vfunc;n;k]`**
  - Stratified sampling approximation
  - Lower variance than basic MC
  - Same parameters and complexity as `shapley_mc`

#### Helper Functions

- **`.shapley.make_vfunc[dict]`**
  - Creates value function from coalition dictionary
  - Input: Dictionary mapping coalition keys to values
  - Returns: Function that evaluates coalition values

- **`.shapley.check_efficiency[vfunc;n;sv]`**
  - Validates efficiency axiom (sum equals v(N))
  - Returns: Boolean

### Examples

Run comprehensive examples:

```q
\l examples.q

/ Individual examples
run_examples.voting[]      / Weighted voting game
run_examples.airport[]     / Airport cost allocation
run_examples.production[]  / Production with synergies
run_examples.network[]     / Network connectivity
run_examples.ml[]          / ML feature importance

/ All examples
run_examples.all[]
```

### Testing

Run the test suite:

```q
q test_shapley.q

/ Or from within Q:
\l test_shapley.q
.test.run_all[]
```

## Performance

For n players and k samples:
- Exact calculation: O(2^n) - feasible up to ~15 players
- Monte Carlo: O(k×n) - scales to thousands of players
- Memory: O(n) for MC methods

Typical performance (1000 samples):
- 10 players: <10ms
- 20 players: ~20ms
- 50 players: ~100ms

## Theory

The Shapley value satisfies four axioms:
1. **Efficiency**: Sum of values equals v(N)
2. **Symmetry**: Symmetric players get equal values
3. **Null player**: Players contributing nothing get zero
4. **Additivity**: Values are additive across games

## Applications

- **Game Theory**: Fair profit/cost allocation
- **Machine Learning**: Feature importance (SHAP values)
- **Economics**: Coalition formation and bargaining
- **Networks**: Centrality and influence measurement
- **Voting**: Power indices in weighted voting systems

## References

1. Castro, J., Gómez, D., & Tejada, J. (2009). Polynomial calculation of the Shapley value based on sampling. Computers & Operations Research, 36(5), 1726-1730.

2. Castro, J., Gómez, D., Molina, E., & Tejada, J. (2017). Improving polynomial estimation of the Shapley value by stratified random sampling with optimum allocation. Computers & Operations Research, 82, 180-188.

3. Shapley, L. S. (1953). A value for n-person games. Contributions to the Theory of Games, 2(28), 307-317.

## License

This implementation is provided for educational and research purposes.