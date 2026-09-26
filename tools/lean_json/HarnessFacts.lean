import Lean
open Lean Elab Command Meta

namespace HarnessFacts

def kindOf : ConstantInfo → String
  | .axiomInfo _ => "axiom"
  | .defnInfo _ => "def"
  | .thmInfo _ => "theorem"
  | .opaqueInfo _ => "opaque"
  | .quotInfo _ => "quotient"
  | .inductInfo _ => "inductive"
  | .ctorInfo _ => "constructor"
  | .recInfo _ => "recursor"

def nameList (xs : Array Name) : Json :=
  Json.arr ((xs.qsort (fun a b => a.toString < b.toString)).map (fun n => Json.str n.toString))

def moduleOf (env : Environment) (name : Name) : String :=
  match env.getModuleIdxFor? name with
  | some idx => match env.header.modules[idx]? with
    | some m => m.module.toString
    | none => "<unknown>"
  | none => env.mainModule.toString

def rangeJson (r : DeclarationRange) : Json :=
  Json.mkObj [("line_start", toJson r.pos.line), ("column_start", toJson r.pos.column),
    ("line_end", toJson r.endPos.line), ("column_end", toJson r.endPos.column)]

def fullPretty (e : Expr) : TermElabM String := do
  withOptions (fun opts => opts.set pp.fullNames.name true
    |>.set pp.proofs.name true
    |>.set pp.funBinderTypes.name true
    |>.set pp.piBinderTypes.name true
    |>.set pp.deepTerms.name true
    |>.set pp.maxSteps.name 1000000) do
    return (← ppExpr e).pretty

def dumpOne (name : Name) (ci : ConstantInfo) : CommandElabM Json := do
  let env ← getEnv
  let ty ← liftTermElabM <| fullPretty ci.type
  let val := ci.value? (allowOpaque := true)
  let constructors := match ci with
    | .inductInfo v => v.ctors.toArray
    | _ => #[]
  let fields := (getStructureInfo? env name).map (fun v => v.fieldInfo.map (·.projFn)) |>.getD #[]
  let td := ci.type.getUsedConstants ++ constructors ++ fields
  let vd := val.map Expr.getUsedConstants |>.getD #[]
  let ax ← collectAxioms name
  let loc ← findDeclarationRanges? name
  let familyNames := match ci with
    | .defnInfo v => v.all.toArray
    | .thmInfo v => v.all.toArray
    | .opaqueInfo v => v.all.toArray
    | _ => #[name]
  let vp ← match ci with
    | .defnInfo _ => match val with
      | some v => liftTermElabM <| fullPretty v
      | none => pure ""
    | _ => pure ""
  let depMods := (td ++ vd).foldl (fun (acc : Array Name) n =>
    if acc.contains n then acc else acc.push n) #[]
  return Json.mkObj [
    ("name", Json.str name.toString), ("kind", Json.str (kindOf ci)),
    ("module", Json.str (moduleOf env name)),
    ("type", Json.str ty), ("definition_value", if vp == "" then Json.null else Json.str vp),
    ("constructors", nameList constructors), ("structure_fields", nameList fields),
    ("type_dependencies", nameList td), ("value_dependencies", nameList vd),
    ("dependency_modules", Json.mkObj (depMods.toList.map (fun n =>
      (n.toString, Json.str (moduleOf env n))))),
    ("axioms", nameList ax), ("is_unsafe", Json.bool ci.isUnsafe),
    ("is_partial", Json.bool ci.isPartial),
    ("mutual_family", nameList familyNames),
    ("value_available", Json.bool val.isSome),
    ("source_range", loc.map (fun r => rangeJson r.range) |>.getD Json.null),
    ("selection_range", loc.map (fun r => rangeJson r.selectionRange) |>.getD Json.null)]

syntax "#harness_dump_module" str str : command
elab_rules : command
  | `(command| #harness_dump_module $modName:str $requested:str) => do
    let env ← getEnv
    let wanted := requested.getString.splitOn "\n"
    let es := env.constants.fold (fun (acc : Array (Name × ConstantInfo)) n ci =>
      if moduleOf env n == modName.getString &&
        (requested.getString == "*" || wanted.any (fun s =>
          n.toString == s || n.toString.endsWith ("." ++ s)))
      then acc.push (n, ci) else acc) #[]
    for (n, ci) in es.qsort (fun a b => a.1.toString < b.1.toString) do
      IO.println ((← dumpOne n ci).compress)

syntax "#harness_dump_context" str str : command
elab_rules : command
  | `(#harness_dump_context $modName:str $requested:str) => do
    let env ← getEnv
    let wanted := requested.getString.splitOn "\n"
    let mut pending := env.constants.fold (fun (acc : Array Name) n _ =>
      if moduleOf env n == modName.getString &&
        wanted.any (fun s => n.toString == s || n.toString.endsWith ("." ++ s))
      then acc.push n else acc) #[]
    let mut visited : NameSet := {}
    let mut results : Array Name := #[]
    while !pending.isEmpty do
      let n := pending.back!
      pending := pending.pop
      if visited.contains n then continue
      visited := visited.insert n
      let some ci := env.find? n | continue
      results := results.push n
      let mut deps := ci.type.getUsedConstants
      match ci with
      | .defnInfo _ =>
        if let some v := ci.value? (allowOpaque := true) then deps := deps ++ v.getUsedConstants
      | _ => pure ()
      for d in deps do
        let m := moduleOf env d
        if m.startsWith "Books." || m.startsWith "Papers." then pending := pending.push d
    for n in results.qsort (fun a b => a.toString < b.toString) do
      if let some ci := env.find? n then IO.println ((← dumpOne n ci).compress)

syntax "#harness_dump_context_scope" str str str : command
elab_rules : command
  | `(#harness_dump_context_scope $modName:str $requested:str $allowed:str) => do
    let env ← getEnv
    let allowedModules := allowed.getString.splitOn "\n"
    let wanted := requested.getString.splitOn "\n"
    let mut pending := env.constants.fold (fun (acc : Array Name) n _ =>
      if moduleOf env n == modName.getString && wanted.any (fun s => n.toString == s)
      then acc.push n else acc) #[]
    let mut visited : NameSet := {}
    let mut results : Array Name := #[]
    while !pending.isEmpty do
      let n := pending.back!
      pending := pending.pop
      if visited.contains n then continue
      visited := visited.insert n
      let some ci := env.find? n | continue
      results := results.push n
      -- External declarations are recorded as leaves. Explicit expansion modules
      -- join the project scope; only those bodies are traversed recursively.
      if allowedModules.contains (moduleOf env n) then
        let mut deps := ci.type.getUsedConstants
        deps := deps ++ ((getStructureInfo? env n).map (fun v => v.fieldInfo.map (·.projFn)) |>.getD #[])
        match ci with
        | .inductInfo v => deps := deps ++ v.ctors.toArray
        | _ => pure ()
        if let some v := ci.value? (allowOpaque := true) then
          deps := deps ++ v.getUsedConstants
        for d in deps do pending := pending.push d
    for n in results.qsort (fun a b => a.toString < b.toString) do
      if let some ci := env.find? n then IO.println ((← dumpOne n ci).compress)
end HarnessFacts
