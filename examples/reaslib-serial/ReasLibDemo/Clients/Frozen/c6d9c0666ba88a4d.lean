import ReasLib.Analysis.Convex.EffectiveDomain
noncomputable section
set_option autoImplicit false
universe u
example : {E : Type u} → (f : E → EReal) → Set.{u} E := @effectiveDomain
example : @effectiveDomain = (fun {E : Type u} (f : E → EReal) =>
  @setOf.{u} E fun (x : E) =>
    And
      (@LT.lt.{0} EReal (@Preorder.toLT.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal))
        (@Bot.bot.{0} EReal instBotEReal) (f x))
      (@LT.lt.{0} EReal (@Preorder.toLT.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal)) (f x)
        (@Top.top.{0} EReal instTopEReal))) := rfl
