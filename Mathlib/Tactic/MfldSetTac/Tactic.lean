import Mathlib.Tactic.MfldSetTac.Attr
import Mathlib.Tactic.Core
import Mathlib.Init.Logic
import Mathlib.Init.Set

open Lean Meta Elab Tactic


namespace Tactic.MfldSetTac

theorem Set.ext {α : Type u} {a b : Set α} (h : ∀ (x : α), x ∈ a ↔ x ∈ b) : a = b :=
funext (fun x => propext (h x))

/-- A very basic tactic to show that sets showing up in manifolds coincide or are included
in one another. -/
elab (name := mfldSetTac) "mfld_set_tac" : tactic => withMainContext do
  let g ← getMainGoal
  let goalTy := (← instantiateMVars (← getMVarDecl g).type).getAppFnArgs
  match goalTy with
  | (``Eq, #[_ty, _e₁, _e₂]) =>
    evalTactic (← `(tactic| apply Set.ext;  intro my_y; constructor <;> { intro h_my_y;
                            try { simp only [*, mfld_simps] at h_my_y
                                  simp only [*, mfld_simps] } }))
  | (``Subset.subset, #[_ty, _inst, _e₁, _e₂]) =>
    evalTactic (← `(tactic| intro my_y h_my_y;
                            try { simp only [*, mfld_simps] at h_my_y
                                  simp only [*, mfld_simps] }))
  | _ => throwError "goal should be an equality or an inclusion"

attribute [mfld_simps] and_true eq_self_iff_true Function.comp_apply
