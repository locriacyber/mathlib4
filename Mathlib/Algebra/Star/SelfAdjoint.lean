/-
Copyright (c) 2021 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis

! This file was ported from Lean 3 source module algebra.star.self_adjoint
! leanprover-community/mathlib commit f93c11933efbc3c2f0299e47b8ff83e9b539cbf6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Algebra.Star.Basic
import Mathlib.GroupTheory.Subgroup.Basic

/-!
# Self-adjoint, skew-adjoint and normal elements of a star additive group

This file defines `selfAdjoint R` (resp. `skewAdjoint R`), where `R` is a star additive group,
as the additive subgroup containing the elements that satisfy `star x = x` (resp. `star x = -x`).
This includes, for instance, (skew-)Hermitian operators on Hilbert spaces.

We also define `IsStarNormal R`, a `Prop` that states that an element `x` satisfies
`star x * x = x * star x`.

## Implementation notes

* When `R` is a `StarModule R₂ R`, then `selfAdjoint R` has a natural
  `Module (selfAdjoint R₂) (selfAdjoint R)` structure. However, doing this literally would be
  undesirable since in the main case of interest (`R₂ = ℂ`) we want `Module ℝ (selfAdjoint R)`
  and not `Module (selfAdjoint ℂ) (selfAdjoint R)`. We solve this issue by adding the typeclass
  `[TrivialStar R₃]`, of which `ℝ` is an instance (registered in `Data/Real/Basic`), and then
  add a `[Module R₃ (selfAdjoint R)]` instance whenever we have
  `[module R₃ R] [TrivialStar R₃]`. (Another approach would have been to define
  `[starInvariantScalars R₃ R]` to express the fact that `star (x • v) = x • star v`, but
  this typeclass would have the disadvantage of taking two type arguments.)

## TODO

* Define `fun z x ↦ z * x * star z` (i.e. conjugation by `z`) as a monoid action of `R` on `R`
  (similar to the existing `ConjAct` for groups), and then state the fact that `selfAdjoint R` is
  invariant under it.

-/


variable {R A : Type _}

/-- An element is self-adjoint if it is equal to its star. -/
def IsSelfAdjoint [Star R] (x : R) : Prop :=
  star x = x
#align is_self_adjoint IsSelfAdjoint

/-- An element of a star monoid is normal if it commutes with its adjoint. -/
class IsStarNormal [Mul R] [Star R] (x : R) : Prop where
  /-- A normal element of a star monoid commutes with its adjoint. -/
  star_comm_self : Commute (star x) x
#align is_star_normal IsStarNormal

export IsStarNormal (star_comm_self)

theorem star_comm_self' [Mul R] [Star R] (x : R) [IsStarNormal x] : star x * x = x * star x :=
  IsStarNormal.star_comm_self
#align star_comm_self' star_comm_self'

namespace IsSelfAdjoint

theorem star_eq [Star R] {x : R} (hx : IsSelfAdjoint x) : star x = x :=
  hx
#align is_self_adjoint.star_eq IsSelfAdjoint.star_eq

theorem _root_.isSelfAdjoint_iff [Star R] {x : R} : IsSelfAdjoint x ↔ star x = x :=
  Iff.rfl
#align is_self_adjoint_iff isSelfAdjoint_iff

@[simp]
theorem star_iff [InvolutiveStar R] {x : R} : IsSelfAdjoint (star x) ↔ IsSelfAdjoint x := by
  simpa only [IsSelfAdjoint, star_star] using eq_comm
#align is_self_adjoint.star_iff IsSelfAdjoint.star_iff

@[simp]
theorem star_mul_self [Semigroup R] [StarSemigroup R] (x : R) : IsSelfAdjoint (star x * x) := by
  simp only [IsSelfAdjoint, star_mul, star_star]
#align is_self_adjoint.star_mul_self IsSelfAdjoint.star_mul_self

@[simp]
theorem mul_star_self [Semigroup R] [StarSemigroup R] (x : R) : IsSelfAdjoint (x * star x) := by
  simpa only [star_star] using star_mul_self (star x)
#align is_self_adjoint.mul_star_self IsSelfAdjoint.mul_star_self

/-- Functions in a `StarHomClass` preserve self-adjoint elements. -/
theorem starHom_apply {F R S : Type _} [Star R] [Star S] [StarHomClass F R S] {x : R}
    (hx : IsSelfAdjoint x) (f : F) : IsSelfAdjoint (f x) :=
  show star (f x) = f x from map_star f x ▸ congr_arg f hx
#align is_self_adjoint.star_hom_apply IsSelfAdjoint.starHom_apply

section AddGroup

variable [AddGroup R] [StarAddMonoid R]

variable (R)

theorem _root_.isSelfAdjoint_zero : IsSelfAdjoint (0 : R) :=
  star_zero R
#align is_self_adjoint_zero isSelfAdjoint_zero

variable {R}

theorem add {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x + y) := by
  simp only [isSelfAdjoint_iff, star_add, hx.star_eq, hy.star_eq]
#align is_self_adjoint.add IsSelfAdjoint.add

theorem neg {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint (-x) := by
  simp only [isSelfAdjoint_iff, star_neg, hx.star_eq]
#align is_self_adjoint.neg IsSelfAdjoint.neg

theorem sub {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x - y) := by
  simp only [isSelfAdjoint_iff, star_sub, hx.star_eq, hy.star_eq]
#align is_self_adjoint.sub IsSelfAdjoint.sub

set_option linter.deprecated false in
@[deprecated]
theorem bit0 {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint (bit0 x) := by
  simp only [isSelfAdjoint_iff, star_bit0, hx.star_eq]
#align is_self_adjoint.bit0 IsSelfAdjoint.bit0

end AddGroup

section NonUnitalSemiring

variable [NonUnitalSemiring R] [StarRing R]

theorem conjugate {x : R} (hx : IsSelfAdjoint x) (z : R) : IsSelfAdjoint (z * x * star z) := by
  simp only [isSelfAdjoint_iff, star_mul, star_star, mul_assoc, hx.star_eq]
#align is_self_adjoint.conjugate IsSelfAdjoint.conjugate

theorem conjugate' {x : R} (hx : IsSelfAdjoint x) (z : R) : IsSelfAdjoint (star z * x * z) := by
  simp only [isSelfAdjoint_iff, star_mul, star_star, mul_assoc, hx.star_eq]
#align is_self_adjoint.conjugate' IsSelfAdjoint.conjugate'

theorem isStarNormal {x : R} (hx : IsSelfAdjoint x) : IsStarNormal x where
  star_comm_self := show star x * x = x * star x by simp only [hx.star_eq]
#align is_self_adjoint.is_star_normal IsSelfAdjoint.isStarNormal

end NonUnitalSemiring

section Ring

variable [Ring R] [StarRing R]

variable (R)

theorem _root_.isSelfAdjoint_one : IsSelfAdjoint (1 : R) :=
  star_one R
#align is_self_adjoint_one isSelfAdjoint_one

variable {R}

set_option linter.deprecated false in
@[deprecated]
theorem bit1 {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint (bit1 x) := by
  -- Porting note: added
  let inst : StarRing R := ‹_›
  rw [isSelfAdjoint_iff, @star_bit1 _ _ inst, hx.star_eq]
#align is_self_adjoint.bit1 IsSelfAdjoint.bit1

theorem pow {x : R} (hx : IsSelfAdjoint x) (n : ℕ) : IsSelfAdjoint (x ^ n) := by
  simp only [isSelfAdjoint_iff, star_pow, hx.star_eq]
#align is_self_adjoint.pow IsSelfAdjoint.pow

end Ring

section NonUnitalCommRing

variable [NonUnitalCommRing R] [StarRing R]

theorem mul {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x * y) := by
  simp only [isSelfAdjoint_iff, star_mul', hx.star_eq, hy.star_eq]
#align is_self_adjoint.mul IsSelfAdjoint.mul

end NonUnitalCommRing

section Field

variable [Field R] [StarRing R]

theorem inv {x : R} (hx : IsSelfAdjoint x) : IsSelfAdjoint x⁻¹ := by
  simp only [isSelfAdjoint_iff, star_inv', hx.star_eq]
#align is_self_adjoint.inv IsSelfAdjoint.inv

theorem div {x y : R} (hx : IsSelfAdjoint x) (hy : IsSelfAdjoint y) : IsSelfAdjoint (x / y) := by
  simp only [isSelfAdjoint_iff, star_div', hx.star_eq, hy.star_eq]
#align is_self_adjoint.div IsSelfAdjoint.div

theorem zpow {x : R} (hx : IsSelfAdjoint x) (n : ℤ) : IsSelfAdjoint (x ^ n) := by
  simp only [isSelfAdjoint_iff, star_zpow₀, hx.star_eq]
#align is_self_adjoint.zpow IsSelfAdjoint.zpow

end Field

section SMul

variable [Star R] [TrivialStar R] [AddGroup A] [StarAddMonoid A]

theorem smul [SMul R A] [StarModule R A] (r : R) {x : A} (hx : IsSelfAdjoint x) :
    IsSelfAdjoint (r • x) := by simp only [isSelfAdjoint_iff, star_smul, star_trivial, hx.star_eq]
#align is_self_adjoint.smul IsSelfAdjoint.smul

end SMul

end IsSelfAdjoint

variable (R)

/-- The self-adjoint elements of a star additive group, as an additive subgroup. -/
def selfAdjoint [AddGroup R] [StarAddMonoid R] : AddSubgroup R
    where
  carrier := { x | IsSelfAdjoint x }
  zero_mem' := star_zero R
  add_mem' hx := hx.add
  neg_mem' hx := hx.neg
#align self_adjoint selfAdjoint

/-- The skew-adjoint elements of a star additive group, as an additive subgroup. -/
def skewAdjoint [AddCommGroup R] [StarAddMonoid R] : AddSubgroup R
    where
  carrier := { x | star x = -x }
  zero_mem' := show star (0 : R) = -0 by simp only [star_zero, neg_zero]
  add_mem' := @fun x y (hx : star x = -x) (hy : star y = -y) =>
    show star (x + y) = -(x + y) by rw [star_add, hx, hy, neg_add]
  neg_mem' := @fun x (hx : star x = -x) =>
    show star (-x) = - -x by simp only [hx, star_neg]
#align skew_adjoint skewAdjoint

variable {R}

namespace selfAdjoint

section AddGroup

variable [AddGroup R] [StarAddMonoid R]

theorem mem_iff {x : R} : x ∈ selfAdjoint R ↔ star x = x := by
  rw [← AddSubgroup.mem_carrier]
  exact Iff.rfl
#align self_adjoint.mem_iff selfAdjoint.mem_iff

@[simp, norm_cast]
theorem star_val_eq {x : selfAdjoint R} : star (x : R) = x :=
  x.prop
#align self_adjoint.star_coe_eq selfAdjoint.star_val_eq

instance : Inhabited (selfAdjoint R) :=
  ⟨0⟩

end AddGroup

section Ring

variable [Ring R] [StarRing R]

instance : One (selfAdjoint R) :=
  ⟨⟨1, isSelfAdjoint_one R⟩⟩

@[simp, norm_cast]
theorem val_one : ↑(1 : selfAdjoint R) = (1 : R) :=
  rfl
#align self_adjoint.coe_one selfAdjoint.val_one

instance [Nontrivial R] : Nontrivial (selfAdjoint R) where
  exists_pair_ne := ⟨0, 1, fun h => zero_ne_one (congrArg Subtype.val h)⟩
-- porting note: `Subtype.ne_of_val_ne` has not been ported

instance : NatCast (selfAdjoint R) where
  natCast := fun n =>
    ⟨n, Nat.recOn n (by simp [zero_mem]) fun k hk =>
      (@Nat.cast_succ R _ k).symm ▸ add_mem hk (isSelfAdjoint_one R)⟩

instance : IntCast (selfAdjoint R) where
  intCast := fun n => ⟨n, by
    cases' n with n n <;> simp [show ↑n ∈ selfAdjoint R from (n : selfAdjoint R).2]
    refine' add_mem (isSelfAdjoint_one R).neg (n : selfAdjoint R).2.neg⟩

instance : Pow (selfAdjoint R) ℕ where
  pow := fun x n => ⟨(x : R) ^ n, x.prop.pow n⟩

@[simp, norm_cast]
theorem val_pow (x : selfAdjoint R) (n : ℕ) : ↑(x ^ n) = (x : R) ^ n :=
  rfl
#align self_adjoint.coe_pow selfAdjoint.val_pow

end Ring

section NonUnitalCommRing

variable [NonUnitalCommRing R] [StarRing R]

instance : Mul (selfAdjoint R) :=
  ⟨fun x y => ⟨(x : R) * y, x.prop.mul y.prop⟩⟩

@[simp, norm_cast]
theorem val_mul (x y : selfAdjoint R) : ↑(x * y) = (x : R) * y :=
  rfl
#align self_adjoint.coe_mul selfAdjoint.val_mul

end NonUnitalCommRing

section CommRing

variable [CommRing R] [StarRing R]

-- porting note: this takes waaaaay too long
instance : CommRing (selfAdjoint R) :=
  Function.Injective.commRing _ Subtype.coe_injective (selfAdjoint R).coe_zero val_one
    (selfAdjoint R).coe_add val_mul (selfAdjoint R).coe_neg (selfAdjoint R).coe_sub
    (selfAdjoint R).coe_nsmul (selfAdjoint R).coe_zsmul val_pow (fun _ => rfl) fun _ => rfl

end CommRing

section Field

variable [Field R] [StarRing R]

instance : Inv (selfAdjoint R) where inv x := ⟨x.val⁻¹, x.prop.inv⟩

@[simp, norm_cast]
theorem val_inv (x : selfAdjoint R) : ↑x⁻¹ = (x : R)⁻¹ :=
  rfl
#align self_adjoint.coe_inv selfAdjoint.val_inv

instance : Div (selfAdjoint R) where div x y := ⟨x / y, x.prop.div y.prop⟩

@[simp, norm_cast]
theorem val_div (x y : selfAdjoint R) : ↑(x / y) = (x / y : R) :=
  rfl
#align self_adjoint.coe_div selfAdjoint.val_div

instance : Pow (selfAdjoint R) ℤ where pow x z := ⟨(x : R) ^ z, x.prop.zpow z⟩

@[simp, norm_cast]
theorem val_zpow (x : selfAdjoint R) (z : ℤ) : (x ^ z : R) = (x : R) ^ z :=
  rfl
#align self_adjoint.coe_zpow selfAdjoint.val_zpow

theorem ratCast_mem : ∀ x : ℚ, IsSelfAdjoint (x : R)
  | ⟨a, b, h1, h2⟩ => by
    -- Porting note: added
    let inst : StarRing R := ‹_›
    rw [IsSelfAdjoint, Rat.cast_mk', star_mul', star_inv']
    rw [@star_natCast _ _ inst]
    rw [star_intCast]
#align self_adjoint.rat_cast_mem selfAdjoint.ratCast_mem

instance : RatCast (selfAdjoint R) :=
  ⟨fun n => ⟨n, ratCast_mem n⟩⟩

@[simp, norm_cast]
theorem val_ratCast (x : ℚ) : ↑(x : selfAdjoint R) = (x : R) :=
  rfl
#align self_adjoint.coe_rat_cast selfAdjoint.val_ratCast

instance instQSMul : SMul ℚ (selfAdjoint R) :=
  ⟨fun a x => ⟨a • (x : R), by rw [Rat.smul_def]; exact (ratCast_mem a).mul x.prop⟩⟩
#align self_adjoint.has_qsmul selfAdjoint.instQSMul

@[simp, norm_cast]
theorem val_rat_smul (x : selfAdjoint R) (a : ℚ) : ↑(a • x) = a • (x : R) :=
  rfl
#align self_adjoint.coe_rat_smul selfAdjoint.val_rat_smul

-- Porting note: This takes too long. lean#2003?
set_option maxHeartbeats 800000 in
set_option synthInstance.maxHeartbeats 800000 in
instance : Field (selfAdjoint R) :=
  Function.Injective.field (↑) Subtype.coe_injective (selfAdjoint R).coe_zero val_one
    (selfAdjoint R).coe_add val_mul (selfAdjoint R).coe_neg (selfAdjoint R).coe_sub val_inv val_div
    (selfAdjoint R).coe_nsmul (selfAdjoint R).coe_zsmul val_rat_smul val_pow val_zpow (fun _ => rfl)
    (fun _ => rfl) val_ratCast

end Field

section SMul

variable [Star R] [TrivialStar R] [AddGroup A] [StarAddMonoid A]

instance [SMul R A] [StarModule R A] : SMul R (selfAdjoint A) :=
  ⟨fun r x => ⟨r • (x : A), x.prop.smul r⟩⟩

@[simp, norm_cast]
theorem val_smul [SMul R A] [StarModule R A] (r : R) (x : selfAdjoint A) : ↑(r • x) = r • (x : A) :=
  rfl
#align self_adjoint.coe_smul selfAdjoint.val_smul

instance [Monoid R] [MulAction R A] [StarModule R A] : MulAction R (selfAdjoint A) :=
  Function.Injective.mulAction Subtype.val Subtype.coe_injective val_smul

instance [Monoid R] [DistribMulAction R A] [StarModule R A] : DistribMulAction R (selfAdjoint A) :=
  Function.Injective.distribMulAction (selfAdjoint A).subtype Subtype.coe_injective val_smul

end SMul

section Module

variable [Star R] [TrivialStar R] [AddCommGroup A] [StarAddMonoid A]

instance [Semiring R] [Module R A] [StarModule R A] : Module R (selfAdjoint A) :=
  Function.Injective.module R (selfAdjoint A).subtype Subtype.coe_injective val_smul

end Module

end selfAdjoint

namespace skewAdjoint

section AddGroup

variable [AddCommGroup R] [StarAddMonoid R]

theorem mem_iff {x : R} : x ∈ skewAdjoint R ↔ star x = -x := by
  rw [← AddSubgroup.mem_carrier]
  exact Iff.rfl
#align skew_adjoint.mem_iff skewAdjoint.mem_iff

@[simp, norm_cast]
theorem star_val_eq {x : skewAdjoint R} : star (x : R) = -x :=
  x.prop
#align skew_adjoint.star_coe_eq skewAdjoint.star_val_eq

instance : Inhabited (skewAdjoint R) :=
  ⟨0⟩

set_option linter.deprecated false in
@[deprecated]
theorem bit0_mem {x : R} (hx : x ∈ skewAdjoint R) : bit0 x ∈ skewAdjoint R := by
  rw [mem_iff, star_bit0, mem_iff.mp hx, bit0, bit0, neg_add]
#align skew_adjoint.bit0_mem skewAdjoint.bit0_mem

end AddGroup

section Ring

variable [Ring R] [StarRing R]

theorem conjugate {x : R} (hx : x ∈ skewAdjoint R) (z : R) : z * x * star z ∈ skewAdjoint R := by
  simp only [mem_iff, star_mul, star_star, mem_iff.mp hx, neg_mul, mul_neg, mul_assoc]
#align skew_adjoint.conjugate skewAdjoint.conjugate

theorem conjugate' {x : R} (hx : x ∈ skewAdjoint R) (z : R) : star z * x * z ∈ skewAdjoint R := by
  simp only [mem_iff, star_mul, star_star, mem_iff.mp hx, neg_mul, mul_neg, mul_assoc]
#align skew_adjoint.conjugate' skewAdjoint.conjugate'

theorem isStarNormal_of_mem {x : R} (hx : x ∈ skewAdjoint R) : IsStarNormal x where
  star_comm_self := by
    rw [mem_iff.mpr hx]
    exact Commute.neg_left rfl
#align skew_adjoint.is_star_normal_of_mem skewAdjoint.isStarNormal_of_mem

instance (x : skewAdjoint R) : IsStarNormal (x : R) :=
  isStarNormal_of_mem (SetLike.coe_mem _)

end Ring

section SMul

variable [Star R] [TrivialStar R] [AddCommGroup A] [StarAddMonoid A]

theorem smul_mem [Monoid R] [DistribMulAction R A] [StarModule R A] (r : R) {x : A}
    (h : x ∈ skewAdjoint A) : r • x ∈ skewAdjoint A := by
  rw [mem_iff, star_smul, star_trivial, mem_iff.mp h, smul_neg r]
#align skew_adjoint.smul_mem skewAdjoint.smul_mem

instance [Monoid R] [DistribMulAction R A] [StarModule R A] : SMul R (skewAdjoint A) :=
  ⟨fun r x => ⟨r • (x : A), smul_mem r x.prop⟩⟩

@[simp, norm_cast]
theorem val_smul [Monoid R] [DistribMulAction R A] [StarModule R A] (r : R) (x : skewAdjoint A) :
    ↑(r • x) = r • (x : A) :=
  rfl
#align skew_adjoint.coe_smul skewAdjoint.val_smul

instance [Monoid R] [DistribMulAction R A] [StarModule R A] : DistribMulAction R (skewAdjoint A) :=
  Function.Injective.distribMulAction (skewAdjoint A).subtype Subtype.coe_injective val_smul

instance [Semiring R] [Module R A] [StarModule R A] : Module R (skewAdjoint A) :=
  Function.Injective.module R (skewAdjoint A).subtype Subtype.coe_injective val_smul

end SMul

end skewAdjoint

instance isStarNormal_zero [Semiring R] [StarRing R] : IsStarNormal (0 : R) where
  star_comm_self := by simpa only [star_zero] using Commute.refl 0
#align is_star_normal_zero isStarNormal_zero

instance isStarNormal_one [Monoid R] [StarSemigroup R] : IsStarNormal (1 : R) where
  star_comm_self := by simpa only [star_one] using Commute.refl 1
#align is_star_normal_one isStarNormal_one

instance isStarNormal_star_self [Monoid R] [StarSemigroup R] {x : R} [IsStarNormal x] :
    IsStarNormal (star x) :=
  ⟨show star (star x) * star x = star x * star (star x) by rw [star_star, star_comm_self']⟩
#align is_star_normal_star_self isStarNormal_star_self

-- see Note [lower instance priority]
instance (priority := 100) TrivialStar.isStarNormal [Monoid R] [StarSemigroup R] [TrivialStar R]
    {x : R} : IsStarNormal x :=
  ⟨by rw [star_trivial]⟩
#align has_trivial_star.is_star_normal TrivialStar.isStarNormal

-- see Note [lower instance priority]
instance (priority := 100) CommMonoid.isStarNormal [CommMonoid R] [StarSemigroup R] {x : R} :
    IsStarNormal x :=
  ⟨mul_comm _ _⟩
#align comm_monoid.is_star_normal CommMonoid.isStarNormal
