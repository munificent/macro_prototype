import 'package:build/build.dart';
import 'package:macro_builder/macro_builder.dart';

import 'macros/json.dart';
import 'macros/observable.dart';

Builder typesBuilder(_) => TypesMacroBuilder([]);
Builder declarationsBuilder(_) => DeclarationsMacroBuilder([toJson]);
Builder definitionsBuilder(_) => DefinitionsMacroBuilder([toJson, observable]);