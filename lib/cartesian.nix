{ ... }:
let
  crossMap = set: attrName: attrValues: let
      f = attrValue: (set // { "${attrName}" = attrValue; });
    in builtins.map f attrValues;
  crossApply = attrName: attrValues: list:
    builtins.concatMap (set: crossMap set attrName attrValues) list;
  crossSet = set: let
      names = builtins.attrNames set;
      f = (list: name: crossApply name (set."${name}") list);
    in builtins.foldl' f [{}] names;
in {
  cartesianProductFromSet = crossSet;
}
