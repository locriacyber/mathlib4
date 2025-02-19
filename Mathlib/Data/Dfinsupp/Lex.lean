/-
Copyright (c) 2022 Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa, Junyan Xu

! This file was ported from Lean 3 source module data.dfinsupp.lex
! leanprover-community/mathlib commit dde670c9a3f503647fd5bfdf1037bad526d3397a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Data.Dfinsupp.Order
import Mathlib.Data.Dfinsupp.NeLocus
import Mathlib.Order.WellFoundedSet

/-!
# Lexicographic order on finitely supported dependent functions

This file defines the lexicographic order on `Dfinsupp`.
-/


variable {ι : Type _} {α : ι → Type _}

namespace Dfinsupp

section Zero

variable [∀ i, Zero (α i)]

/-- `Dfinsupp.Lex r s` is the lexicographic relation on `Π₀ i, α i`, where `ι` is ordered by `r`,
and `α i` is ordered by `s i`.
The type synonym `Lex (Π₀ i, α i)` has an order given by `Dfinsupp.Lex (· < ·) (· < ·)`.
-/
-- Porting note: Changed type of `s` from `∀ i, ...` to `∀ {i}, ...`
protected def Lex (r : ι → ι → Prop) (s : ∀ {i}, α i → α i → Prop) (x y : Π₀ i, α i) : Prop :=
  Pi.Lex r s x y
#align dfinsupp.lex Dfinsupp.Lex

-- Porting note: Added `_root_` to match more closely with Lean 3. Also updated `s`'s type.
theorem _root_.Pi.lex_eq_dfinsupp_lex {r : ι → ι → Prop} {s : ∀ {i}, α i → α i → Prop}
    (a b : Π₀ i, α i) : Pi.Lex r s (a : ∀ i, α i) b = Dfinsupp.Lex r s a b :=
  rfl
#align pi.lex_eq_dfinsupp_lex Pi.lex_eq_dfinsupp_lex

-- Porting note: Updated `s`'s type.
theorem lex_def {r : ι → ι → Prop} {s : ∀ {i}, α i → α i → Prop} {a b : Π₀ i, α i} :
    Dfinsupp.Lex r s a b ↔ ∃ j, (∀ d, r d j → a d = b d) ∧ s (a j) (b j) :=
  Iff.rfl
#align dfinsupp.lex_def Dfinsupp.lex_def

instance [LT ι] [∀ i, LT (α i)] : LT (Lex (Π₀ i, α i)) :=
  ⟨fun f g ↦ Dfinsupp.Lex (· < ·) (· < ·) (ofLex f) (ofLex g)⟩

theorem lex_lt_of_lt_of_preorder [∀ i, Preorder (α i)] (r) [IsStrictOrder ι r] {x y : Π₀ i, α i}
    (hlt : x < y) : ∃ i, (∀ j, r j i → x j ≤ y j ∧ y j ≤ x j) ∧ x i < y i := by
  obtain ⟨hle, j, hlt⟩ := Pi.lt_def.1 hlt
  classical
  have : (x.neLocus y : Set ι).WellFoundedOn r := (x.neLocus y).finite_toSet.wellFoundedOn
  obtain ⟨i, hi, hl⟩ := this.has_min { i | x i < y i } ⟨⟨j, mem_neLocus.2 hlt.ne⟩, hlt⟩
  refine' ⟨i, fun k hk ↦ ⟨hle k, _⟩, hi⟩
  exact of_not_not fun h ↦ hl ⟨k, mem_neLocus.2 (ne_of_not_le h).symm⟩ ((hle k).lt_of_not_le h) hk
#align dfinsupp.lex_lt_of_lt_of_preorder Dfinsupp.lex_lt_of_lt_of_preorder

theorem lex_lt_of_lt [∀ i, PartialOrder (α i)] (r) [IsStrictOrder ι r] {x y : Π₀ i, α i}
    (hlt : x < y) : Pi.Lex r (· < ·) x y := by
  simp_rw [Pi.Lex, le_antisymm_iff]
  exact lex_lt_of_lt_of_preorder r hlt
#align dfinsupp.lex_lt_of_lt Dfinsupp.lex_lt_of_lt

instance Lex.isStrictOrder [LinearOrder ι] [∀ i, PartialOrder (α i)] :
    IsStrictOrder (Lex (Π₀ i, α i)) (· < ·) :=
  let i : IsStrictOrder (Lex (∀ i, α i)) (· < ·) := Pi.Lex.isStrictOrder
  { irrefl := toLex.surjective.forall.2 fun _ ↦ @irrefl _ _ i.toIsIrrefl _
    trans := toLex.surjective.forall₃.2 fun _ _ _ ↦ @trans _ _ i.toIsTrans _ _ _ }
#align dfinsupp.lex.is_strict_order Dfinsupp.Lex.isStrictOrder

variable [LinearOrder ι]

/-- The partial order on `Dfinsupp`s obtained by the lexicographic ordering.
See `Dfinsupp.Lex.linearOrder` for a proof that this partial order is in fact linear. -/
instance Lex.partialOrder [∀ i, PartialOrder (α i)] : PartialOrder (Lex (Π₀ i, α i)) :=
  PartialOrder.lift (fun x ↦ toLex (⇑(ofLex x)))
    (FunLike.coe_injective (F := Dfinsupp fun i => α i))
#align dfinsupp.lex.partial_order Dfinsupp.Lex.partialOrder

section LinearOrder

variable [∀ i, LinearOrder (α i)]

/-- Auxiliary helper to case split computably. There is no need for this to be public, as it
can be written with `Or.by_cases` on `lt_trichotomy` once the instances below are constructed. -/
private def lt_trichotomy_rec {P : Lex (Π₀ i, α i) → Lex (Π₀ i, α i) → Sort _}
    (h_lt : ∀ {f g}, toLex f < toLex g → P (toLex f) (toLex g))
    (h_eq : ∀ {f g}, toLex f = toLex g → P (toLex f) (toLex g))
    (h_gt : ∀ {f g}, toLex g < toLex f → P (toLex f) (toLex g)) : ∀ f g, P f g :=
  Lex.rec fun f ↦ Lex.rec fun g ↦ match (motive := ∀ y, (f.neLocus g).min = y → _) _, rfl with
  | ⊤, h => h_eq (neLocus_eq_empty.mp <| Finset.min_eq_top.mp h)
  | (wit : ι), h => by
    apply (mem_neLocus.mp <| Finset.mem_of_min h).lt_or_lt.by_cases <;> intro hwit
    · exact h_lt ⟨wit, fun j hj ↦ not_mem_neLocus.mp (Finset.not_mem_of_lt_min hj h), hwit⟩
    · exact h_gt ⟨wit, fun j hj ↦
        not_mem_neLocus.mp (Finset.not_mem_of_lt_min hj <| by rwa [neLocus_comm]), hwit⟩

/-- The less-or-equal relation for the lexicographic ordering is decidable. -/
irreducible_def Lex.decidableLe : @DecidableRel (Lex (Π₀ i, α i)) (· ≤ ·) :=
  lt_trichotomy_rec (fun h ↦ isTrue <| Or.inr h)
    (fun h ↦ isTrue <| Or.inl <| congr_arg _ <| congr_arg _ h)
    fun h ↦ isFalse fun h' ↦ lt_irrefl _ (h.trans_le h')
#align dfinsupp.lex.decidable_le Dfinsupp.Lex.decidableLe

/-- The less-than relation for the lexicographic ordering is decidable. -/
irreducible_def Lex.decidableLt : @DecidableRel (Lex (Π₀ i, α i)) (· < ·) :=
  lt_trichotomy_rec (fun h ↦ isTrue h) (fun h ↦ isFalse h.not_lt) fun h ↦ isFalse h.asymm
#align dfinsupp.lex.decidable_lt Dfinsupp.Lex.decidableLt

-- Porting note: Added `DecidableEq` for `LinearOrder`.
instance : DecidableEq (Lex (Π₀ i, α i)) :=
  lt_trichotomy_rec (fun h ↦ isFalse fun h' => h'.not_lt h) (fun h ↦ isTrue h)
    fun h ↦ isFalse fun h' => h'.symm.not_lt h

/-- The linear order on `Dfinsupp`s obtained by the lexicographic ordering. -/
instance Lex.linearOrder : LinearOrder (Lex (Π₀ i, α i)) :=
  { Lex.partialOrder with
    le_total := lt_trichotomy_rec (fun h ↦ Or.inl h.le) (fun h ↦ Or.inl h.le) fun h ↦ Or.inr h.le
    decidable_lt := decidableLt
    decidable_le := decidableLe
    decidable_eq := inferInstance }
#align dfinsupp.lex.linear_order Dfinsupp.Lex.linearOrder

end LinearOrder

variable [∀ i, PartialOrder (α i)]

theorem toLex_monotone : Monotone (@toLex (Π₀ i, α i)) := by
  intro a b h
  refine' le_of_lt_or_eq (or_iff_not_imp_right.2 fun hne ↦ _)
  classical
  exact ⟨Finset.min' _ (nonempty_neLocus_iff.2 hne),
    fun j hj ↦ not_mem_neLocus.1 fun h ↦ (Finset.min'_le _ _ h).not_lt hj,
    (h _).lt_of_ne (mem_neLocus.1 <| Finset.min'_mem _ _)⟩
#align dfinsupp.to_lex_monotone Dfinsupp.toLex_monotone

theorem lt_of_forall_lt_of_lt (a b : Lex (Π₀ i, α i)) (i : ι) :
    (∀ j < i, ofLex a j = ofLex b j) → ofLex a i < ofLex b i → a < b :=
  fun h1 h2 ↦ ⟨i, h1, h2⟩
#align dfinsupp.lt_of_forall_lt_of_lt Dfinsupp.lt_of_forall_lt_of_lt

end Zero

section Covariants

variable [LinearOrder ι] [∀ i, AddMonoid (α i)] [∀ i, LinearOrder (α i)]

/-!  We are about to sneak in a hypothesis that might appear to be too strong.
We assume `CovariantClass` with *strict* inequality `<` also when proving the one with the
*weak* inequality `≤`. This is actually necessary: addition on `Lex (Π₀ i, α i)` may fail to be
monotone, when it is "just" monotone on `α i`. -/


section Left

variable [∀ i, CovariantClass (α i) (α i) (· + ·) (· < ·)]

instance Lex.covariantClass_lt_left :
    CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (· + ·) (· < ·) :=
  ⟨fun _ _ _ ⟨a, lta, ha⟩ ↦ ⟨a, fun j ja ↦ congr_arg _ (lta j ja), add_lt_add_left ha _⟩⟩
#align dfinsupp.lex.covariant_class_lt_left Dfinsupp.Lex.covariantClass_lt_left

instance Lex.covariantClass_le_left :
    CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (· + ·) (· ≤ ·) :=
  Add.to_covariantClass_left _
#align dfinsupp.lex.covariant_class_le_left Dfinsupp.Lex.covariantClass_le_left

end Left

section Right

variable [∀ i, CovariantClass (α i) (α i) (Function.swap (· + ·)) (· < ·)]

instance Lex.covariantClass_lt_right :
    CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (Function.swap (· + ·)) (· < ·) :=
  ⟨fun f _ _ ⟨a, lta, ha⟩ ↦
    ⟨a, fun j ja ↦ congr_arg (· + ofLex f j) (lta j ja), add_lt_add_right ha _⟩⟩
#align dfinsupp.lex.covariant_class_lt_right Dfinsupp.Lex.covariantClass_lt_right

instance Lex.covariantClass_le_right :
    CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (Function.swap (· + ·)) (· ≤ ·) :=
  Add.to_covariantClass_right _
#align dfinsupp.lex.covariant_class_le_right Dfinsupp.Lex.covariantClass_le_right

end Right

end Covariants

end Dfinsupp
