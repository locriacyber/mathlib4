/-
Copyright (c) 2019 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Floris van Doorn

! This file was ported from Lean 3 source module data.set.pointwise.finite
! leanprover-community/mathlib commit 0a0ec35061ed9960bf0e7ffb0335f44447b58977
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Data.Set.Finite
import Mathlib.Data.Set.Pointwise.SMul

/-! # Finiteness lemmas for pointwise operations on sets -/


open Pointwise

variable {F α β γ : Type _}

namespace Set

section InvolutiveInv

variable [InvolutiveInv α] {s : Set α}

@[to_additive]
theorem Finite.inv (hs : s.Finite) : s⁻¹.Finite :=
  hs.preimage <| inv_injective.injOn _
#align set.finite.inv Set.Finite.inv
#align set.finite.neg Set.Finite.neg

end InvolutiveInv

section Mul

variable [Mul α] {s t : Set α}

@[to_additive]
theorem Finite.mul : s.Finite → t.Finite → (s * t).Finite :=
  Finite.image2 _
#align set.finite.mul Set.Finite.mul
#align set.finite.add Set.Finite.add

/-- Multiplication preserves finiteness. -/
@[to_additive "Addition preserves finiteness."]
def fintypeMul [DecidableEq α] (s t : Set α) [Fintype s] [Fintype t] : Fintype (s * t : Set α) :=
  Set.fintypeImage2 _ _ _
#align set.fintype_mul Set.fintypeMul
#align set.fintype_add Set.fintypeAdd

end Mul

section Monoid

variable [Monoid α] {s t : Set α}

@[to_additive]
instance decidableMemMul [Fintype α] [DecidableEq α] [DecidablePred (· ∈ s)]
    [DecidablePred (· ∈ t)] : DecidablePred (· ∈ s * t) := fun _ ↦ decidable_of_iff _ mem_mul.symm
#align set.decidable_mem_mul Set.decidableMemMul
#align set.decidable_mem_add Set.decidableMemAdd

@[to_additive]
instance decidableMemPow [Fintype α] [DecidableEq α] [DecidablePred (· ∈ s)] (n : ℕ) :
    DecidablePred (· ∈ s ^ n) := by
  induction' n with n ih
  · simp only [Nat.zero_eq, pow_zero, mem_one]
    infer_instance
  · letI := ih
    rw [pow_succ]
    infer_instance
#align set.decidable_mem_pow Set.decidableMemPow
#align set.decidable_mem_nsmul Set.decidableMemNSMul

end Monoid

section SMul

variable [SMul α β] {s : Set α} {t : Set β}

@[to_additive]
theorem Finite.smul : s.Finite → t.Finite → (s • t).Finite :=
  Finite.image2 _
#align set.finite.smul Set.Finite.smul
#align set.finite.vadd Set.Finite.vadd

end SMul

section HasSmulSet

variable [SMul α β] {s : Set β} {a : α}

@[to_additive]
theorem Finite.smul_set : s.Finite → (a • s).Finite :=
  Finite.image _
#align set.finite.smul_set Set.Finite.smul_set
#align set.finite.vadd_set Set.Finite.vadd_set

end HasSmulSet

section Vsub

variable [VSub α β] {s t : Set β}

theorem Finite.vsub (hs : s.Finite) (ht : t.Finite) : Set.Finite (s -ᵥ t) :=
  hs.image2 _ ht
#align set.finite.vsub Set.Finite.vsub

end Vsub

end Set

open Set

namespace Group

variable {G : Type _} [Group G] [Fintype G] (S : Set G)

@[to_additive]
theorem card_pow_eq_card_pow_card_univ [∀ k : ℕ, DecidablePred (· ∈ S ^ k)] :
    ∀ k, Fintype.card G ≤ k → Fintype.card (↥(S ^ k)) = Fintype.card (↥(S ^ Fintype.card G)) := by
  have hG : 0 < Fintype.card G := Fintype.card_pos_iff.mpr ⟨1⟩
  by_cases hS : S = ∅
  · refine' fun k hk ↦ Fintype.card_congr _
    rw [hS, empty_pow (ne_of_gt (lt_of_lt_of_le hG hk)), empty_pow (ne_of_gt hG)]
  obtain ⟨a, ha⟩ := Set.nonempty_iff_ne_empty.2 hS
  have key : ∀ (a) (s t : Set G) [Fintype s] [Fintype t],
      (∀ b : G, b ∈ s → a * b ∈ t) → Fintype.card s ≤ Fintype.card t := by
    refine' fun a s t _ _ h ↦ Fintype.card_le_of_injective (fun ⟨b, hb⟩ ↦ ⟨a * b, h b hb⟩) _
    rintro ⟨b, hb⟩ ⟨c, hc⟩ hbc
    exact Subtype.ext (mul_left_cancel (Subtype.ext_iff.mp hbc))
  have mono : Monotone (fun n ↦ Fintype.card (↥(S ^ n)) : ℕ → ℕ) :=
    monotone_nat_of_le_succ fun n ↦ key a _ _ fun b hb ↦ Set.mul_mem_mul ha hb
  refine' card_pow_eq_card_pow_card_univ_aux mono (fun n ↦ set_fintype_card_le_univ (S ^ n))
    fun n h ↦ le_antisymm (mono (n + 1).le_succ) (key a⁻¹ (S ^ (n + 2)) (S ^ (n + 1)) _)
  replace h₂ : {a} * S ^ n = S ^ (n + 1)
  · have : Fintype (Set.singleton a * S ^ n) := by
      classical!
      apply fintypeMul
    refine' Set.eq_of_subset_of_card_le _ (le_trans (ge_of_eq h) _)
    · exact mul_subset_mul (Set.singleton_subset_iff.mpr ha) Set.Subset.rfl
    · convert key a (S ^ n) ({a} * S ^ n) fun b hb ↦ Set.mul_mem_mul (Set.mem_singleton a) hb
  rw [pow_succ', ← h₂, mul_assoc, ← pow_succ', h₂]
  rintro _ ⟨b, c, hb, hc, rfl⟩
  rwa [Set.mem_singleton_iff.mp hb, inv_mul_cancel_left]
#align group.card_pow_eq_card_pow_card_univ Group.card_pow_eq_card_pow_card_univ
#align add_group.card_nsmul_eq_card_nsmul_card_univ AddGroup.card_nsmul_eq_card_nsmul_card_univ

end Group
