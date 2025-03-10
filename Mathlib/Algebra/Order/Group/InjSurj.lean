/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.group.inj_surj
! leanprover-community/mathlib commit 655994e298904d7e5bbd1e18c95defd7b543eb94
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Algebra.Order.Monoid.Basic
import Mathlib.Algebra.Order.Group.Instances

/-!
# Pull back ordered groups along injective maps.
-/


variable {α β : Type _}

/-- Pullback an `OrderedCommGroup` under an injective map.
See note [reducible non-instances]. -/
@[reducible,
  to_additive
      "Pullback an `OrderedAddCommGroup` under an injective map."]
def Function.Injective.orderedCommGroup [OrderedCommGroup α] {β : Type _} [One β] [Mul β] [Inv β]
    [Div β] [Pow β ℕ] [Pow β ℤ] (f : β → α) (hf : Function.Injective f) (one : f 1 = 1)
    (mul : ∀ x y, f (x * y) = f x * f y) (inv : ∀ x, f x⁻¹ = (f x)⁻¹)
    (div : ∀ x y, f (x / y) = f x / f y) (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n)
    (zpow : ∀ (x) (n : ℤ), f (x ^ n) = f x ^ n) : OrderedCommGroup β :=
  { PartialOrder.lift f hf, hf.orderedCommMonoid f one mul npow,
    hf.commGroup f one mul inv div npow zpow with }
#align function.injective.ordered_comm_group Function.Injective.orderedCommGroup
#align function.injective.ordered_add_comm_group Function.Injective.orderedAddCommGroup

/-- Pullback a `LinearOrderedCommGroup` under an injective map.
See note [reducible non-instances]. -/
@[reducible,
  to_additive
      "Pullback a `LinearOrderedAddCommGroup` under an injective map."]
def Function.Injective.linearOrderedCommGroup [LinearOrderedCommGroup α] {β : Type _} [One β]
    [Mul β] [Inv β] [Div β] [Pow β ℕ] [Pow β ℤ] [HasSup β] [HasInf β] (f : β → α)
    (hf : Function.Injective f) (one : f 1 = 1) (mul : ∀ x y, f (x * y) = f x * f y)
    (inv : ∀ x, f x⁻¹ = (f x)⁻¹) (div : ∀ x y, f (x / y) = f x / f y)
    (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n) (zpow : ∀ (x) (n : ℤ), f (x ^ n) = f x ^ n)
    (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y)) (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) :
    LinearOrderedCommGroup β :=
  { LinearOrder.lift f hf hsup hinf, hf.orderedCommGroup f one mul inv div npow zpow with }
#align function.injective.linear_ordered_comm_group Function.Injective.linearOrderedCommGroup
#align function.injective.linear_ordered_add_comm_group Function.Injective.linearOrderedAddCommGroup
