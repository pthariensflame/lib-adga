------------------------------------------------------------------------
-- The Agda standard library
--
-- Heterogeneous equality
------------------------------------------------------------------------

-- This file contains some core definitions which are reexported by
-- Relation.Binary.HeterogeneousEquality.

module Relation.Binary.HeterogeneousEquality.Core where

open import Relation.Binary.Core using (_≡_; refl)

------------------------------------------------------------------------
-- Heterogeneous equality

infix 4 _≅_

data _≅_ {a} {A : Set a} (x : A) : ∀ {b} {B : Set b} → B → Set where
  refl : x ≅ x

------------------------------------------------------------------------
-- Conversion

≅-to-≡ : ∀ {a} {A : Set a} {x y : A} → x ≅ y → x ≡ y
≅-to-≡ refl = refl

≡-to-≅ : ∀ {a} {A : Set a} {x y : A} → x ≡ y → x ≅ y
≡-to-≅ refl = refl

------------------------------------------------------------------------
-- Some properties

reflexive : ∀ {a} {A : Set a} → {x y : A} → x ≡ y → x ≅ y
reflexive refl = refl

sym : ∀ {a b} {A : Set a} {B : Set b} {x : A} {y : B} → x ≅ y → y ≅ x
sym refl = refl

trans : ∀ {a b c} {A : Set a} {B : Set b} {C : Set c}
          {x : A} {y : B} {z : C} →
        x ≅ y → y ≅ z → x ≅ z
trans refl eq = eq
