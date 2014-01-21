------------------------------------------------------------------------
-- The Agda standard library
--
-- Heterogeneous equality
------------------------------------------------------------------------

module Relation.Binary.HeterogeneousEquality where

open import Data.Product
open import Function
open import Function.Inverse using (Inverse)
open import Level
open import Relation.Nullary
open import Relation.Binary
open import Relation.Binary.Consequences
open import Relation.Binary.Indexed as I using (_at_)
open import Relation.Binary.PropositionalEquality as P using (_≡_; refl)

import Relation.Binary.HeterogeneousEquality.Core as Core

------------------------------------------------------------------------
-- Heterogeneous equality

infix 4 _≇_

open Core public using (_≅_; refl)

-- Nonequality.

_≇_ : ∀ {a} {A : Set a} → A → ∀ {b} {B : Set b} → B → Set
x ≇ y = ¬ x ≅ y

------------------------------------------------------------------------
-- Conversion

open Core public using (≅-to-≡; ≡-to-≅)

------------------------------------------------------------------------
-- Some properties

open Core public using (reflexive; sym; trans)

subst : ∀ {a} {A : Set a} {p} → Substitutive {A = A} (λ x y → x ≅ y) p
subst P refl p = p

subst₂ : ∀ {a b p} {A : Set a} {B : Set b} (P : A → B → Set p) →
         ∀ {x₁ x₂ y₁ y₂} → x₁ ≅ x₂ → y₁ ≅ y₂ → P x₁ y₁ → P x₂ y₂
subst₂ P refl refl p = p

subst-removable : ∀ {a p} {A : Set a}
                  (P : A → Set p) {x y} (eq : x ≅ y) z →
                  subst P eq z ≅ z
subst-removable P refl z = refl

≡-subst-removable : ∀ {a p} {A : Set a}
                    (P : A → Set p) {x y} (eq : x ≡ y) z →
                    P.subst P eq z ≅ z
≡-subst-removable P refl z = refl

cong : ∀ {a b} {A : Set a} {B : A → Set b} {x y}
       (f : (x : A) → B x) → x ≅ y → f x ≅ f y
cong f refl = refl

cong₂ : ∀ {a b c} {A : Set a} {B : A → Set b} {C : ∀ x → B x → Set c}
          {x y u v}
        (f : (x : A) (y : B x) → C x y) → x ≅ y → u ≅ v → f x u ≅ f y v
cong₂ f refl refl = refl

resp₂ : ∀ {a ℓ} {A : Set a} (∼ : Rel A ℓ) → ∼ Respects₂ (λ x y → x ≅ y)
resp₂ _∼_ = subst⟶resp₂ _∼_ subst

proof-irrelevance : ∀ {a b} {A : Set a} {B : Set b} {x : A} {y : B}
                    (p q : x ≅ y) → p ≡ q
proof-irrelevance refl refl = refl

isEquivalence : ∀ {a} {A : Set a} →
                IsEquivalence {A = A} (λ x y → x ≅ y)
isEquivalence = record
  { refl  = refl
  ; sym   = sym
  ; trans = trans
  }

setoid : ∀ {a} → Set a → Setoid _ _
setoid A = record
  { Carrier       = A
  ; _≈_           = λ x y → x ≅ y
  ; isEquivalence = isEquivalence
  }

indexedSetoid : ∀ {a b} {A : Set a} → (A → Set b) → I.Setoid A _ _
indexedSetoid B = record
  { Carrier       = B
  ; _≈_           = λ x y → x ≅ y
  ; isEquivalence = record
    { refl  = refl
    ; sym   = sym
    ; trans = trans
    }
  }

≡↔≅ : ∀ {a b} {A : Set a} (B : A → Set b) {x : A} →
      Inverse (P.setoid (B x)) (indexedSetoid B at x)
≡↔≅ B = record
  { to         = record { _⟨$⟩_ = id; cong = ≡-to-≅ }
  ; from       = record { _⟨$⟩_ = id; cong = ≅-to-≡ }
  ; inverse-of = record
    { left-inverse-of  = λ _ → refl
    ; right-inverse-of = λ _ → refl
    }
  }

decSetoid : ∀ {a} {A : Set a} →
            Decidable {A = A} {B = A} (λ x y → x ≅ y) →
            DecSetoid _ _
decSetoid dec = record
  { _≈_              = λ x y → x ≅ y
  ; isDecEquivalence = record
      { isEquivalence = isEquivalence
      ; _≟_           = dec
      }
  }

isPreorder : ∀ {a} {A : Set a} →
             IsPreorder {A = A} (λ x y → x ≅ y) (λ x y → x ≅ y)
isPreorder = record
  { isEquivalence = isEquivalence
  ; reflexive     = id
  ; trans         = trans
  }

isPreorder-≡ : ∀ {a} {A : Set a} →
               IsPreorder {A = A} _≡_ (λ x y → x ≅ y)
isPreorder-≡ = record
  { isEquivalence = P.isEquivalence
  ; reflexive     = reflexive
  ; trans         = trans
  }

preorder : ∀ {a} → Set a → Preorder _ _ _
preorder A = record
  { Carrier    = A
  ; _≈_        = _≡_
  ; _∼_        = λ x y → x ≅ y
  ; isPreorder = isPreorder-≡
  }

------------------------------------------------------------------------
-- Convenient syntax for equational reasoning

module ≅-Reasoning where

  -- The code in Relation.Binary.EqReasoning cannot handle
  -- heterogeneous equalities, hence the code duplication here.

  infix  4 _IsRelatedTo_
  infix  2 _∎
  infixr 2 _≅⟨_⟩_ _≡⟨_⟩_ _≡⟨⟩_
  infix  1 begin_

  data _IsRelatedTo_ {a} {A : Set a} (x : A) {b} {B : Set b} (y : B) :
                     Set where
    relTo : (x≅y : x ≅ y) → x IsRelatedTo y

  begin_ : ∀ {a} {A : Set a} {x : A} {b} {B : Set b} {y : B} →
           x IsRelatedTo y → x ≅ y
  begin relTo x≅y = x≅y

  _≅⟨_⟩_ : ∀ {a} {A : Set a} (x : A) {b} {B : Set b} {y : B}
             {c} {C : Set c} {z : C} →
           x ≅ y → y IsRelatedTo z → x IsRelatedTo z
  _ ≅⟨ x≅y ⟩ relTo y≅z = relTo (trans x≅y y≅z)

  _≡⟨_⟩_ : ∀ {a} {A : Set a} (x : A) {y c} {C : Set c} {z : C} →
           x ≡ y → y IsRelatedTo z → x IsRelatedTo z
  _ ≡⟨ x≡y ⟩ relTo y≅z = relTo (trans (reflexive x≡y) y≅z)

  _≡⟨⟩_ : ∀ {a} {A : Set a} (x : A) {b} {B : Set b} {y : B} →
          x IsRelatedTo y → x IsRelatedTo y
  _ ≡⟨⟩ x≅y = x≅y

  _∎ : ∀ {a} {A : Set a} (x : A) → x IsRelatedTo x
  _∎ _ = relTo refl

------------------------------------------------------------------------
-- Functional extensionality

-- A form of functional extensionality for _≅_.

Extensionality : (a b : Level) → Set _
Extensionality a b =
  {A : Set a} {B₁ B₂ : A → Set b}
  {f₁ : (x : A) → B₁ x} {f₂ : (x : A) → B₂ x} →
  (∀ x → B₁ x ≡ B₂ x) → (∀ x → f₁ x ≅ f₂ x) → f₁ ≅ f₂

-- This form of extensionality follows from extensionality for _≡_.

≡-ext-to-≅-ext : ∀ {ℓ₁ ℓ₂} →
  P.Extensionality ℓ₁ (suc ℓ₂) → Extensionality ℓ₁ ℓ₂
≡-ext-to-≅-ext           ext B₁≡B₂ f₁≅f₂ with ext B₁≡B₂
≡-ext-to-≅-ext {ℓ₁} {ℓ₂} ext B₁≡B₂ f₁≅f₂ | P.refl =
  ≡-to-≅ $ ext′ (≅-to-≡ ∘ f₁≅f₂)
  where
  ext′ : P.Extensionality ℓ₁ ℓ₂
  ext′ = P.extensionality-for-lower-levels ℓ₁ (suc ℓ₂) ext
