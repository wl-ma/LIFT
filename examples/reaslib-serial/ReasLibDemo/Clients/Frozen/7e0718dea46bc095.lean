import ReasLibDemo.Sources.Beck.Example521_Indicator
noncomputable section
set_option autoImplicit false
universe u
example : ∀ {α : Type u} (C : Set.{u} α) (x : α),
  @LT.lt.{0} EReal (@Preorder.toLT.{0} EReal (@PartialOrder.toPreorder.{0} EReal instPartialOrderEReal))
    (@Bot.bot.{0} EReal instBotEReal) (@erealIndicator.{u} α C x) := @bot_lt_erealIndicator
