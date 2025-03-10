import Mathlib.Algebra.Ring.Basic
import Mathlib.Data.Rat.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-!
## `field_simp` tests.
-/

/-
Check that `field_simp` works for units of a ring.
-/

variable {R : Type _} [CommRing R] (a b c d e f g : R) (u₁ u₂ : Rˣ)

/--
Check that `divp_add_divp_same` takes priority over `divp_add_divp`.
-/
example : a /ₚ u₁ + b /ₚ u₁ = (a + b) /ₚ u₁ :=
by field_simp

/--
Check that `divp_sub_divp_same` takes priority over `divp_sub_divp`.
-/
example : a /ₚ u₁ - b /ₚ u₁ = (a - b) /ₚ u₁ :=
by field_simp

/-
Combining `eq_divp_iff_mul_eq` and `divp_eq_iff_mul_eq`.

This example is currently commented out because it is weirdly slow.
See https://github.com/leanprover/lean4/issues/2055.

It works with `set_option maxHeartbeats 300000`.
-/
--example : a /ₚ u₁ = b /ₚ u₂ ↔ a * u₂ = b * u₁ :=
--by field_simp

/--
Making sure inverses of units are rewritten properly.
-/
example : ↑u₁⁻¹ = 1 /ₚ u₁ := by field_simp

/--
Checking arithmetic expressions.
-/
example : (f - (e + c * -(a /ₚ u₁) * b + d) - g) =
  (f * u₁ - (e * u₁ + c * (-a) * b + d * u₁) - g * u₁) /ₚ u₁ :=
by field_simp

/--
Division of units.
-/
example : a /ₚ (u₁ / u₂) = a * u₂ /ₚ u₁ :=
by field_simp

example : a /ₚ u₁ /ₚ u₂ = a /ₚ (u₂ * u₁) :=
by field_simp

/--
Test that the discharger can clear nontrivial denominators in ℚ.
-/
example (x : ℚ) (h₀ : x ≠ 0) :
    (4 / x)⁻¹ * ((3 * x^3) / x)^2 * ((1 / (2 * x))⁻¹)^3 = 18 * x^8 := by
  field_simp
  ring
