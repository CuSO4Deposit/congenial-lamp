#import "../index.typ": *
#show: template

= Curry-Howard Correspondence

#quote[Proofs can be represented as programs, and especially as lambda terms.]

There is an isomorphism between the proof systems and the models of
computation. In its more general formulation, the Curry-Howard correspondence
is a correspondence between formal proof calculi and type systems for models of
computation. #footnote[#link("https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence")[Curry-Howard Correspondence - Wikipedia]]

Here is a table on the correspondence:

#table(
  columns: (1.5fr, 1.5fr),
  inset: 10pt,
  align: horizon,
  table.header([*Logic side*], [*Programming side*]),
  [formula], [type],
  [proof], [term],
  [formula is true], [type has an element],
  [formula is false], [type does not have an element],
  [logical constant $top$ (truth)], [unit type],
  [logical constant $bot$ (falsehood)], [empty type],
  [implication], [function type],
  [conjunction], [product type],
  [disjunction], [sum type],
  [universal quantification], [dependent product type],
  [existential quantification], [dependent sum type],
)

== Examples

For example, for the formula $A arrow.r (B arrow.r A)$, we know it is always true.
It can be encoded as a type:
```haskell
const :: a -> b -> a
```

And we can construct a function of this type:
```haskell
const x _ = x
```

As there *is* a function of this type, we can conclude the formula is true.

#linebreak()

For a counter example, consider the formula $A and not A$,
as $not A$ means $A -> bot$, the formula's corresponding type is:
```haskell
p :: (a, a -> Void)
```

Can we find an element for this type? #footnote[
  `Void` in Haskell corresponds to the empty set ($emptyset$) in the set
  theory, and to the *initial object* in the category theory. Recognizing this
  immediately reveal the falsity.
  For more details, reference #link("https://bartoszmilewski.com/2014/11/24/types-and-functions/")[Types and Functions - Category Theory for Programmers].
]

If there is an element:
```haskell
p = (a, f)  -- a :: A, f :: A -> Void
```
Then we have:
```haskell
impossible :: Void
impossible = f a
```

But `Void` can never have an element! Then we know the original formula $A and not A$ is false.
