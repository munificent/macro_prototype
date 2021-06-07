import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import '../code.dart';
import '../macro.dart';

class AnalyzerTypeDeclaration implements TypeDeclaration {
  final TypeDefiningElement element;
  final DartType? originalReference;

  AnalyzerTypeDeclaration(this.element, {this.originalReference});

  @override
  bool get isNullable =>
      originalReference?.nullabilitySuffix == NullabilitySuffix.question;

  @override
  bool isSubtype(TypeDeclaration other) => throw UnimplementedError();

  @override
  String get name => element.name!;

  @override
  Scope get scope => throw UnimplementedError();

  @override
  Iterable<TypeDeclaration> get typeArguments sync* {
    var reference = originalReference;
    if (reference is ParameterizedType) {
      for (var typeArgument in reference.typeArguments) {
        yield AnalyzerTypeDeclaration(
            typeArgument.element! as TypeDefiningElement,
            originalReference: typeArgument);
      }
    }
  }

  @override
  Iterable<TypeParameterDeclaration> get typeParameters sync* {
    var e = element;
    if (e is ClassElement) {
      for (var parameter in e.typeParameters) {
        yield AnalyzerTypeParameterDeclaration(parameter);
      }
    }
  }
}

class AnalyzerTypeDefinition extends AnalyzerTypeDeclaration
    implements TypeDefinition {
  AnalyzerTypeDefinition(TypeDefiningElement element,
      {DartType? originalReference})
      : super(element, originalReference: originalReference);

  @override
  Iterable<FieldDefinition> get fields sync* {
    var e = element;
    if (e is ClassElement) {
      for (var field in e.fields) {
        yield AnalyzerFieldDefinition(field);
      }
    }
  }

  @override
  bool isSubtype(TypeDeclaration other) => throw UnimplementedError();

  @override
  Iterable<MethodDefinition> get methods sync* {
    var e = element;
    if (e is ClassElement) {
      for (var method in e.methods) {
        yield AnalyzerMethodDefinition(method);
      }
    }
  }

  @override
  Iterable<TypeDefinition> get superinterfaces sync* {
    var e = element;
    if (e is ClassElement) {
      for (var interface in e.allSupertypes) {
        yield AnalyzerTypeDefinition(interface.element,
            originalReference: interface);
      }
    }
  }

  @override
  Iterable<TypeDefinition> get typeArguments sync* {
    var reference = originalReference;
    if (reference is ParameterizedType) {
      for (var typeArgument in reference.typeArguments) {
        yield AnalyzerTypeDefinition(
            typeArgument.element! as TypeDefiningElement,
            originalReference: typeArgument);
      }
    }
  }

  @override
  Iterable<TypeParameterDefinition> get typeParameters sync* {
    var e = element;
    if (e is ClassElement) {
      for (var parameter in e.typeParameters) {
        yield AnalyzerTypeParameterDefinition(parameter);
      }
    }
  }
}

class AnalyzerMethodDeclaration implements MethodDeclaration {
  final MethodElement element;

  AnalyzerMethodDeclaration(this.element);

  @override
  String get name => element.name;

  @override
  Map<String, ParameterDeclaration> get namedParameters => {
        for (var param in element.parameters)
          if (param.isNamed) param.name: AnalyzerParameterDeclaration(param),
      };

  @override
  Iterable<ParameterDeclaration> get positionalParameters sync* {
    for (var param in element.parameters) {
      if (!param.isPositional) continue;
      yield AnalyzerParameterDeclaration(param);
    }
  }

  @override
  TypeDeclaration get returnType => AnalyzerTypeDeclaration(
      element.returnType.element! as TypeDefiningElement,
      originalReference: element.returnType);

  @override
  Iterable<TypeParameterDeclaration> get typeParameters sync* {
    for (var typeParam in element.typeParameters) {
      yield AnalyzerTypeParameterDeclaration(typeParam);
    }
  }
}

class AnalyzerMethodDefinition extends AnalyzerMethodDeclaration
    implements MethodDefinition {
  AnalyzerMethodDefinition(MethodElement element) : super(element);

  @override
  Map<String, ParameterDefinition> get namedParameters => {
        for (var param in element.parameters)
          if (param.isNamed) param.name: AnalyzerParameterDefinition(param),
      };

  @override
  Iterable<ParameterDefinition> get positionalParameters sync* {
    for (var param in element.parameters) {
      if (!param.isPositional) continue;
      yield AnalyzerParameterDefinition(param);
    }
  }

  @override
  TypeDefinition get returnType =>
      AnalyzerTypeDefinition(element.returnType.element! as TypeDefiningElement,
          originalReference: element.returnType);

  @override
  Iterable<TypeParameterDefinition> get typeParameters sync* {
    for (var typeParam in element.typeParameters) {
      yield AnalyzerTypeParameterDefinition(typeParam);
    }
  }
}

class AnalyzerFieldDeclaration implements FieldDeclaration {
  final FieldElement element;

  AnalyzerFieldDeclaration(this.element);

  @override
  String get name => element.name;

  @override
  TypeDeclaration get type =>
      AnalyzerTypeDeclaration(element.type.element! as TypeDefiningElement,
          originalReference: element.type);
}

class AnalyzerFieldDefinition extends AnalyzerFieldDeclaration
    implements FieldDefinition {
  AnalyzerFieldDefinition(FieldElement element) : super(element);

  @override
  TypeDefinition get type =>
      AnalyzerTypeDefinition(element.type.element! as TypeDefiningElement,
          originalReference: element.type);
}

class AnalyzerParameterDeclaration implements ParameterDeclaration {
  final ParameterElement element;

  AnalyzerParameterDeclaration(this.element);

  @override
  String get name => element.name;

  @override
  bool get required => element.isRequiredPositional || element.isRequiredNamed;

  @override
  TypeDeclaration get type =>
      AnalyzerTypeDeclaration(element.type.element! as TypeDefiningElement,
          originalReference: element.type);
}

class AnalyzerParameterDefinition extends AnalyzerParameterDeclaration
    implements ParameterDefinition {
  AnalyzerParameterDefinition(ParameterElement element) : super(element);

  @override
  TypeDefinition get type =>
      AnalyzerTypeDefinition(element.type.element! as TypeDefiningElement,
          originalReference: element.type);
}

class AnalyzerTypeParameterDeclaration implements TypeParameterDeclaration {
  final TypeParameterElement element;

  AnalyzerTypeParameterDeclaration(this.element);

  @override
  TypeDeclaration? get bounds => element.bound == null
      ? null
      : AnalyzerTypeDeclaration(element.bound!.element! as TypeDefiningElement,
          originalReference: element.bound);

  @override
  String get name => element.name;
}

class AnalyzerTypeParameterDefinition extends AnalyzerTypeParameterDeclaration
    implements TypeParameterDefinition {
  AnalyzerTypeParameterDefinition(TypeParameterElement element)
      : super(element);

  @override
  TypeDefinition? get bounds => element.bound == null
      ? null
      : AnalyzerTypeDefinition(element.bound!.element! as TypeDefiningElement,
          originalReference: element.bound);
}
