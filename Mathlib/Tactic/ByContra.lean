/-
Copyright (c) 2022 Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Kevin Buzzard
-/
import Lean
--import Mathlib.Mathport.Syntax
import Mathlib.Tactic.Basic
import Lean.Elab.Command
import Lean.Elab.Quotation
import Mathlib.Tactic.Alias
import Mathlib.Tactic.Cases
import Mathlib.Tactic.ClearExcept
import Mathlib.Tactic.Clear_
import Mathlib.Tactic.Core
import Mathlib.Tactic.CommandQuote
import Mathlib.Tactic.Ext
import Mathlib.Tactic.Find
import Mathlib.Tactic.InferParam
import Mathlib.Tactic.LeftRight
import Mathlib.Tactic.LibrarySearch
import Mathlib.Tactic.NormCast
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.RCases
import Mathlib.Tactic.Replace
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Set
import Mathlib.Tactic.ShowTerm
import Mathlib.Tactic.Simps
import Mathlib.Tactic.SolveByElim
import Mathlib.Tactic.Trace
import Mathlib.Init.ExtendedBinder
import Mathlib.Util.WithWeakNamespace
import Mathlib.Util.Syntax
open Lean Lean.Parser Parser.Tactic Elab Command Elab.Tactic Meta

/--
IMPORTANT: this tactic will not perform correctly until `push_neg` is implemented.

If the target of the main goal is a proposition `p`,
`by_contra'` reduces the goal to proving `false` using the additional hypothesis `this : ¬ p`.
`by_contra' h` can be used to name the hypothesis `h : ¬ p`.
The hypothesis `¬ p` will be negation normalized using `push_neg`.
For instance, `¬ a < b` will be changed to `b ≤ a`.
`by_contra' h : q` will normalize negations in `¬ p`, normalize negations in `q`,
and then check that the two normalized forms are equal.
The resulting hypothesis is the pre-normalized form, `q`.
If the name `h` is not explicitly provided, then `this` will be used as name.
This tactic uses classical reasoning.
It is a variant on the tactic `by_contra`.
Examples (IMPORTANT: these will not work until `push_neg` is implemented):
```lean
example : 1 < 2 :=
begin
  by_contra' h,
  -- h : 2 ≤ 1 ⊢ false
end
example : 1 < 2 :=
begin
  by_contra' h : ¬ 1 < 2,
  -- h : ¬ 1 < 2 ⊢ false
end
```
-/
syntax (name := byContra') "by_contra'" (ppSpace ident)? Term.optType : tactic
syntax (name := pushNeg) "push_neg" (ppSpace location)? : tactic

macro_rules
  | `(tactic| by_contra') => `(tactic| (by_contra $(mkIdent `this); push_neg at this))
  | `(tactic| by_contra' $e) => `(tactic| (by_contra $e; push_neg at ($e)))
  | `(tactic| by_contra' $e : $y) => `(tactic|
       ( by_contra';
         -- if the below `exact` call fails then this tactic should fail with the message
         -- tactic failed: <goal type> and <type of definitely_not_dollar_e> are not definitionally equal
         have $e : $y := by { push_neg; exact this };
         clear this
       ))


macro_rules
  | `(tactic| push_neg) => `(tactic| simp only [not_not])
  | `(tactic| push_neg at $e) => `(tactic| simp only [not_not, not_lt] at $e)

example (p : Prop): ¬ ¬ ¬ ¬ ¬ ¬ P := by
  by_contra' foo : ¬ ¬ ¬ P;
  sorry


example : 1 < 2 := by
  by_contra' h

set_option pp.all true
example (a b : ℕ) (foo : False)  : a < b := by
  by_contra' bar;
  guard_hyp bar : b ≤ a;
  exact foo

#exit
begin
  by_contra' h : 2 ≤ 1,
  guard_hyp' h : 2 ≤ 1, -- this is not defeq to `¬ 1 < 2`
  revert h,
  exact dec_trivial
end

example : 1 < 2 :=
begin
  by_contra' h : ¬ 1 < 2,
  guard_hyp' h : ¬ 1 < 2, -- this is not defeq to `2 ≤ 1`
  revert h,
  exact dec_trivial
end

example : 1 < 2 :=
begin
  by_contra' : 2 ≤ 1,
  guard_hyp' this : 2 ≤ 1, -- this is not defeq to `¬ 1 < 2`
  revert this,
  exact dec_trivial
end
