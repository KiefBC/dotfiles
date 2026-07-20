# Pattern taxonomy — NeetCode 18 categories (verified 2026-07)

Format: pattern | recognition cues | example rung-1/2 probe (turn the cue into a question).

| Pattern | Recognition cues | Probe question |
|---|---|---|
| Arrays & Hashing | "have we seen X", frequency counts, grouping by signature, complement lookup (target−x), prefix-sum for subarray-sum queries | "What could you remember as you scan so you never look back?" |
| Two Pointers | sorted (or sortable) input + pair/triplet condition; converge from ends; palindromes; in-place partition | "What does sortedness let you rule out without checking?" |
| Sliding Window | contiguous subarray/substring + longest/shortest/count satisfying a condition; fixed-k vs variable window | "What does *contiguous* buy you? When your range becomes invalid, what's the cheapest recovery?" |
| Stack / Monotonic | nesting/matching, most-recent-first, next-greater/smaller element, histogram areas | "Which earlier items become irrelevant the moment you see a bigger one?" |
| Binary Search | sorted/rotated input, O(log n) asks, monotonic answer space ("min capacity such that…"), first-true boundary | "Is there a yes/no question that flips exactly once as the answer grows?" |
| Linked List | in-place rewiring, cycle/middle/nth-from-end (fast & slow), merges, LRU-style designs | "What could two runners at different speeds tell you?" |
| Trees | recursive structure, depth/diameter/balance, level-by-level (BFS), BST ordering (inorder) | "What would each subtree need to report upward for you to combine?" |
| Tries | prefix queries, autocomplete, wildcard dictionaries, many-word grid search | "How would you share work between words with the same prefix?" |
| Heap / Priority Queue | k largest/smallest/closest, repeated extract-min/max, streaming kth, running median (two heaps) | "Do you need everything sorted, or just the extreme at each step?" |
| Backtracking | generate ALL subsets/permutations/combinations; constraint satisfaction with pruning | "Choose, explore, un-choose — what's the choice at each step, and when can you prune?" |
| Graphs | grid flood-fill, components, prerequisites/ordering (topo sort), shortest unweighted steps (BFS), multi-source spread | "Is this asking about reachability, ordering, or distance? Which traversal fits each?" |
| Advanced Graphs | weighted shortest path (Dijkstra), connect-all-min-cost (MST), use-every-edge (Eulerian), minimize-the-max edge | "Are edges weighted? Does greedy-nearest stay safe here?" |
| 1-D DP | "number of ways", min/max over a sequence, decision at i depends on i−1/i−2, non-adjacency | "If you knew the answer for every shorter prefix, how would you extend it one step?" |
| 2-D DP | two sequences compared (LCS/edit distance), grid paths, knapsack, interval DP | "What two indices pin down a subproblem completely?" |
| Greedy | provably-safe local choice (exchange argument), Kadane, sort-then-sweep | "Can you argue no future input ever makes this local choice wrong?" |
| Intervals | (start,end) pairs, merge/overlap/min-rooms; sort by start; overlap iff startB ≤ endA; heap of end times | "After sorting, what's the only interval a new one can conflict with?" |
| Math & Geometry | matrix rotate/spiral/zero in place, simulation, digit tricks, fast exponentiation | "Can you do it layer by layer / in place with a marker value?" |
| Bit Manipulation | XOR cancels pairs, count set bits, add without +, index-vs-value tricks | "What happens to duplicates under XOR?" |

Cross-cutting cues: prefix sum (repeated range sums), fast & slow pointers (cycles/middles), monotonic stack (next greater), top-K (heap), modified binary search (rotated/answer-space), BFS = shortest/levels vs DFS = exhaustive paths.

## Roadmap prerequisite order (neetcode.io/roadmap)

Arrays & Hashing → {Two Pointers, Stack}; Two Pointers → {Binary Search, Sliding Window, Linked List}; Binary Search & Linked List → Trees; Trees → {Tries, Heap/PQ, Backtracking}; Heap/PQ → {Intervals, Greedy, Advanced Graphs}; Backtracking → {Graphs, 1-D DP}; Graphs → {Advanced Graphs, 2-D DP, Math & Geometry}; 1-D DP → {2-D DP, Bit Manipulation}.

## Spacing (evidence-anchored)

- Optimal review gap ≈ 10–20% of the desired retention interval (Cepeda et al. 2008). Interview in ~30 days → review each weak pattern every ~3–6 days.
- Ladder: 1 → 3 → 7 → 14 → 30 days after first cold solve.
- Hinted/failed solve: repeat at the SAME or shorter interval — never advance the interval on a struggle.
- Track weakness at the PATTERN level, not per-problem; re-drill the category before moving on.
