/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yury Kudryashov

! This file was ported from Lean 3 source module data.finsupp.antidiagonal
! leanprover-community/mathlib commit 0a0ec35061ed9960bf0e7ffb0335f44447b58977
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Data.Finsupp.Multiset
import Mathlib.Data.Multiset.Antidiagonal

/-!
# The `Finsupp` counterpart of `Multiset.antidiagonal`.

The antidiagonal of `s : α →₀ ℕ` consists of
all pairs `(t₁, t₂) : (α →₀ ℕ) × (α →₀ ℕ)` such that `t₁ + t₂ = s`.
-/


noncomputable section

open Classical BigOperators

namespace Finsupp

open Finset

universe u

variable {α : Type u}

/-- The `Finsupp` counterpart of `Multiset.antidiagonal`: the antidiagonal of
`s : α →₀ ℕ` consists of all pairs `(t₁, t₂) : (α →₀ ℕ) × (α →₀ ℕ)` such that `t₁ + t₂ = s`.
The finitely supported function `antidiagonal s` is equal to the multiplicities of these pairs. -/
def antidiagonal' (f : α →₀ ℕ) : (α →₀ ℕ) × (α →₀ ℕ) →₀ ℕ :=
  Multiset.toFinsupp
    ((Finsupp.toMultiset f).antidiagonal.map (Prod.map Multiset.toFinsupp Multiset.toFinsupp))
#align finsupp.antidiagonal' Finsupp.antidiagonal'

/-- The antidiagonal of `s : α →₀ ℕ` is the finset of all pairs `(t₁, t₂) : (α →₀ ℕ) × (α →₀ ℕ)`
such that `t₁ + t₂ = s`. -/
def antidiagonal (f : α →₀ ℕ) : Finset ((α →₀ ℕ) × (α →₀ ℕ)) := f.antidiagonal'.support
#align finsupp.antidiagonal Finsupp.antidiagonal

@[simp]
theorem mem_antidiagonal {f : α →₀ ℕ} {p : (α →₀ ℕ) × (α →₀ ℕ)} :
    p ∈ antidiagonal f ↔ p.1 + p.2 = f := by
  rcases p with ⟨p₁, p₂⟩
  simp [antidiagonal, antidiagonal', ← and_assoc, ← Finsupp.toMultiset.apply_eq_iff_eq]
#align finsupp.mem_antidiagonal Finsupp.mem_antidiagonal

theorem swap_mem_antidiagonal {n : α →₀ ℕ} {f : (α →₀ ℕ) × (α →₀ ℕ)} :
    f.swap ∈ antidiagonal n ↔ f ∈ antidiagonal n := by
  simp only [mem_antidiagonal, add_comm, Prod.swap]
#align finsupp.swap_mem_antidiagonal Finsupp.swap_mem_antidiagonal

theorem antidiagonal_filter_fst_eq (f g : α →₀ ℕ)
    [D : ∀ p : (α →₀ ℕ) × (α →₀ ℕ), Decidable (p.1 = g)] :
    ((antidiagonal f).filter fun p ↦ p.1 = g) = if g ≤ f then {(g, f - g)} else ∅ := by
  ext ⟨a, b⟩
  suffices a = g → (a + b = f ↔ g ≤ f ∧ b = f - g) by
    have h₁ : (if g ≤ f then a = g ∧ b = f - g else False) ↔ g ≤ f ∧ a = g ∧ b = f - g := by
      by_cases h : g ≤ f <;> simp [h]
    simpa [apply_ite (fun f ↦ (a, b) ∈ f), mem_filter, mem_antidiagonal, mem_singleton,
      Prod.mk.inj_iff, h₁, ← and_assoc, @and_right_comm _ (a = _), and_congr_left_iff]
  rintro rfl
  constructor
  · rintro rfl
    exact ⟨le_add_right le_rfl, (add_tsub_cancel_left _ _).symm⟩
  · rintro ⟨h, rfl⟩
    exact add_tsub_cancel_of_le h
#align finsupp.antidiagonal_filter_fst_eq Finsupp.antidiagonal_filter_fst_eq

theorem antidiagonal_filter_snd_eq (f g : α →₀ ℕ)
    [D : ∀ p : (α →₀ ℕ) × (α →₀ ℕ), Decidable (p.2 = g)] :
    ((antidiagonal f).filter fun p ↦ p.2 = g) = if g ≤ f then {(f - g, g)} else ∅ := by
  ext ⟨a, b⟩
  suffices b = g → (a + b = f ↔ g ≤ f ∧ a = f - g) by
    have h₁ : (if g ≤ f then a = f - g ∧ b = g else False) ↔ g ≤ f ∧ a = f - g ∧ b = g := by
      by_cases h : g ≤ f <;> simp [h]
    simpa [apply_ite (fun f ↦ (a, b) ∈ f), mem_filter, mem_antidiagonal, mem_singleton,
      Prod.mk.inj_iff, h₁, ← and_assoc, and_congr_left_iff]
  rintro rfl
  constructor
  · rintro rfl
    exact ⟨le_add_left le_rfl, (add_tsub_cancel_right _ _).symm⟩
  · rintro ⟨h, rfl⟩
    exact tsub_add_cancel_of_le h
#align finsupp.antidiagonal_filter_snd_eq Finsupp.antidiagonal_filter_snd_eq

@[simp]
theorem antidiagonal_zero : antidiagonal (0 : α →₀ ℕ) = singleton (0, 0) := by
  rw [antidiagonal, antidiagonal', Multiset.toFinsupp_support]; rfl
#align finsupp.antidiagonal_zero Finsupp.antidiagonal_zero

@[to_additive]
theorem prod_antidiagonal_swap {M : Type _} [CommMonoid M] (n : α →₀ ℕ)
    (f : (α →₀ ℕ) → (α →₀ ℕ) → M) :
    (∏ p in antidiagonal n, f p.1 p.2) = ∏ p in antidiagonal n, f p.2 p.1 :=
  Finset.prod_bij (fun p _hp ↦ p.swap) (fun _p ↦ swap_mem_antidiagonal.2) (fun _p _hp ↦ rfl)
    (fun _p₁ _p₂ _ _ h ↦ Prod.swap_injective h) fun p hp ↦
    ⟨p.swap, swap_mem_antidiagonal.2 hp, p.swap_swap.symm⟩
#align finsupp.prod_antidiagonal_swap Finsupp.prod_antidiagonal_swap
#align finsupp.sum_antidiagonal_swap Finsupp.sum_antidiagonal_swap

end Finsupp
