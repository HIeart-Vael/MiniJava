package org.xtext.projects.minijava.tests

import org.eclipse.xtext.testing.XtextRunner
import org.junit.runner.RunWith
import org.eclipse.xtext.testing.InjectWith
import org.xtext.projects.minijava.miniJava.Goal
import org.eclipse.xtext.testing.util.ParseHelper
import com.google.inject.Inject
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.eclipse.emf.ecore.resource.ResourceSet
import com.google.inject.Provider
import org.junit.Test
import org.xtext.projects.minijava.miniJava.MiniJavaPackage

import static extension org.junit.Assert.*
import org.xtext.projects.minijava.validation.MiniJavaValidator
import org.xtext.projects.minijava.MiniJavaLib
import org.eclipse.emf.ecore.EClass
import org.xtext.projects.minijava.miniJava.CommonType
import org.xtext.projects.minijava.miniJava.Type

@RunWith(XtextRunner)
@InjectWith(MiniJavaInjectorProvider)
class MiniJavaValidatorTest {
	@Inject extension ParseHelper<Goal>
	@Inject extension ValidationTestHelper
	@Inject extension MiniJavaLib
	@Inject Provider<ResourceSet> resourceSetProvider
    /*
     * 
     * 
     */
     def private void assertHierarchyCycle(Goal p, String expectedClassName) {
		p.assertError(
			MiniJavaPackage.eINSTANCE.getClassDecl,
			MiniJavaValidator.HIERARCHY_CYCLE,
			"cycle in hierarchy of class '" + expectedClassName + "'"
		)
	}
	
	@Test def void testClassHierarchyCycle() {
		'''
			class A extends C {}
			class C extends B {}
			class B extends A {}
		'''.parse => [
			assertHierarchyCycle("A")
			assertHierarchyCycle("B")
			assertHierarchyCycle("C")
		]
	}
	/*
	 * 
	 * 
	 */
	@Test def void testInvocationOnField(){
		'''
			class A{
				A f;
				A m(){
					return this.f();
				}
			}
		''' =>[
			parse.assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.METHOD_INVOCATION_ON_FIELD,
				lastIndexOf("("),1,
				"Method invocation on a field"
			)
		]
	}
	
	@Test def void testInvocationOnMethod(){
		'''
			class A{
				A m(){
					return this.m;
				}
			}
		''' =>[
			parse.assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.FIELD_SELECTION_ON_METHOD,
				lastIndexOf("m"),1,
				"Field selection on a method"
			)
		]
	}
	@Test def void testUnreachableCode() {
		'''
			class C {
				C m() {
					return null;
					this.m();
				}
			}
		'''.parse.assertError(
			MiniJavaPackage.eINSTANCE.getMemberSelection,
			MiniJavaValidator.UNREACHABLE_CODE,
			"Unreachable code"
		)
	}
	@Test def void testUnreachableCodeOnlyOnce() {
		'''
			class C {
				C m() {
					return null;
					C i = null; // error only here
					return null;
					return null; // no error here
				}
			}
		'''.parse => [
			assertError(
				MiniJavaPackage.eINSTANCE.getVarDecl,
				MiniJavaValidator.UNREACHABLE_CODE,
				"Unreachable code"
			)
			1.assertEquals(validate.size)
		]
	}
	
	@Test def void testCorrectMemberSelection() {
		'''
			class A{
			  A f;
			  A m() {
			  	A v = this.f;
			    return this.m();
			  }
			}
		'''.parse.assertNoErrors
	}
	@Test def void testMissingFinalReturn() {
		'''
		class C {
			C m() {
				this.m();
			}
		}
		'''.parse.assertError(
			MiniJavaPackage.eINSTANCE.getMethodDecl,
			MiniJavaValidator.MISSING_FINAL_RETURN,
			"Method must end with a return statement"
		)
	}
	/*
	 * 
	 * 
	 */
	 def private void assertDuplicate(String input, EClass type, String desc, String name) {
		input.parse => [
			// check that the error is on both duplicates
			assertError(type,
				MiniJavaValidator.DUPLICATE_ELEMENT,
				input.indexOf(name), name.length,
				"Duplicate " + desc + " '" + name + "'")
			assertError(type,
				MiniJavaValidator.DUPLICATE_ELEMENT,
				input.lastIndexOf(name), name.length,
				"Duplicate " + desc + " '" + name + "'")
		]
	}
	@Test def void testDuplicateClasses() {
		'''
		class C {}
		class C {}
		'''.toString.assertDuplicate(MiniJavaPackage.eINSTANCE.getClassDecl, "class", "C")
	}
	@Test def void testDuplicateFields() {
		'''
		class C {
			C f;
			C f;
		}
		'''.toString.assertDuplicate(MiniJavaPackage.eINSTANCE.getFieldDecl, "field", "f")
	}
	@Test def void testDuplicateMethods() {
		'''
		class C {
			C m() { return null; }
			C m() { return null; }
		}
		'''.toString.assertDuplicate(MiniJavaPackage.eINSTANCE.getMethodDecl, "method", "m")
	}
	@Test def void testDuplicateParams() {
		'''
		class C {
			C m(C p, C p) { return null; }
		}
		'''.toString.assertDuplicate(MiniJavaPackage.eINSTANCE.getParameter, "parameter", "p")
	}
	@Test def void testDuplicateVariables() {
		'''
		class C {
			C m() {
				C v = null;
				if (true)
					C v = null;
				return null;
			}
		}
		'''.toString.assertDuplicate(MiniJavaPackage.eINSTANCE.getVarDecl, "variable", "v")
	}
	
	@Test def void testDuplicateVariables2() {
	// wait to solve
		'''
		class C {
			C m() {
				if (true)
					C v = null;
				else
					C v = null;
				return null;
			}
		}
		'''.toString.assertDuplicate(MiniJavaPackage.eINSTANCE.getVarDecl, "variable", "v")
	}
	@Test def void testFieldAndMethodWithTheSameNameAreValid() {
		'''
			class C {
			  C f;
			  C f() { return null; }
			}
		'''.parse.assertNoErrors
	}
	/*
	 * 
	 */
	 def private getTypeName(Type t){
		if((t as CommonType).classname !== null){
			(t as CommonType).classname.name
		}
		else{
			var fullname = (t as CommonType).typename
			for(i:0..<(t as CommonType).arrays.length)
				fullname += '[]'
			fullname
		}
	}
	 def private void assertIncompatibleTypes(CharSequence methodBody, EClass c, String expectedType, String actualType) {
		('''
			class A {}
			class B extends A {}
			class C {
			  A f;
			  A m(A p) {
			    ''' + methodBody + 
			'''
				return null;
				}
			}    
			''').parse.assertError(
			c,
			MiniJavaValidator.INCOMPATIBLE_TYPES,
			"Incompatible types. Expected '" + expectedType + "' but was '" + actualType + "' "
		)
	}
	@Test def void testVariableDeclExpIncompatibleTypes() {
		"A v = new C();".assertIncompatibleTypes(MiniJavaPackage.eINSTANCE.getNewObject, "A", "C")
	}
	@Test def void testArgExpIncompatibleTypes() {
		"this.m(new C());".assertIncompatibleTypes(MiniJavaPackage.eINSTANCE.getNewObject, "A", "C")
	}
	
	@Test def void testIfExpressionIncompatibleTypes() {
		"if (new C()) { return null; } ".
			assertIncompatibleTypes(
				MiniJavaPackage.eINSTANCE.getNewObject,
				"boolean", "C"
			)
	}
	
	@Test def void testAssignmentIncompatibleTypes() {
		"A v = null; v = new C();".
			assertIncompatibleTypes(
				MiniJavaPackage.eINSTANCE.getNewObject,
				"A", "C"
			)
	}
	@Test def void testWrongMethodOverride() {
		'''
		class A {
			A m(A a) { return null; }
			B n(A a) { return null; }
		}
		
		class B extends A {
			A m(B a) { return null; }
			A n(A a) { return null; }
		}
		
		class C extends A {
			B m(A a) { return null; }
		}
		'''.parse=>[
			assertError(MiniJavaPackage.eINSTANCE.getMethodDecl,
				MiniJavaValidator.WRONG_METHOD_OVERRIDE,
				"The method 'm' must override a superclass method"
			)
			assertError(MiniJavaPackage.eINSTANCE.getMethodDecl,
				MiniJavaValidator.WRONG_METHOD_OVERRIDE,
				"The method 'n' must override a superclass method"
			)
			2.assertEquals(validate.size)
		]
	}
	
	@Test def void testCorrectMethodOverride() {
		'''
		class A {
			A m(A a) { return null; }
		}
		
		class B extends A {
			A m(A a) { return null; }
		}
		
		class C extends A {
			// return type can be a subtype
			B m(A a) { return null; }
		}
		'''.parse.assertNoErrors
	}
	@Test def void testFieldAccessibility() {
		'''
		class A {
			private A priv;
			protected A prot;
			public A pub;
			A m() {
				this.priv = null; // private field
				this.prot = null; // protected field
				this.pub = null; // public field
				return null;
			}
		}
		
		class B extends A {
			A m() {
				this.priv = null; // private field ERROR
				this.prot = null; // protected field
				this.pub = null; // public field
				return null;
			}
		}
		'''.parse => [
			1.assertEquals(validate.size)
			assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.MEMBER_NOT_ACCESSIBLE,
				"The private member priv is not accessible here"
			)
		]
	}
	
	@Test def void testFieldAccessibilityInSubclass() {
		'''
		class A {
			private A priv;
			protected A prot;
			public A pub;
			A m() {
				this.priv = null; // private field
				this.prot = null; // protected field
				this.pub = null; // public field
				return null;
			}
		}
		
		class C {
			A m() {
				(new A()).priv = null; // private field ERROR
				(new A()).prot = null; // protected field ERROR
				(new A()).pub = null; // public field
				return null;
			}
		}
		'''.parse => [
			2.assertEquals(validate.size)
			assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.MEMBER_NOT_ACCESSIBLE,
				"The private member priv is not accessible here"
			)
			assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.MEMBER_NOT_ACCESSIBLE,
				"The protected member prot is not accessible here"
			)
		]
	}
	@Test def void testMethodAccessibility() {
		'''
		class A {
			private A priv() { return null; }
			protected A prot() { return null; }
			public A pub() { return null; }
			A m() {
				A a = null;
				a = this.priv(); // private method
				a = this.prot(); // protected method
				a = this.pub(); // public method
				return null;
			}
		}
		
		class B extends A {
			A m() {
				A a = null;
				a = this.priv(); // private method ERROR
				a = this.prot(); // protected method
				a = this.pub(); // public method
				return null;
			}
		}
		'''.parse => [
			1.assertEquals(validate.size)
			assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.MEMBER_NOT_ACCESSIBLE,
				"The private member priv is not accessible here"
			)
		]
	}
	@Test def void testMethodAccessibilityInSubclass() {
		'''
		class A {
			private A priv() { return null; }
			protected A prot() { return null; }
			public A pub() { return null; }
			A m() {
				A a = null;
				a = this.priv(); // private method
				a = this.prot(); // protected method
				a = this.pub(); // public method
				return null;
			}
		}
		
		class C {
			A m() {
				A a = null;
				a = (new A()).priv(); // private method ERROR
				a = (new A()).prot(); // protected method ERROR
				a = (new A()).pub(); // public method
				return null;
			}
		}
		'''.parse => [
			2.assertEquals(validate.size)
			assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.MEMBER_NOT_ACCESSIBLE,
				"The private member priv is not accessible here"
			)
			assertError(
				MiniJavaPackage.eINSTANCE.getMemberSelection,
				MiniJavaValidator.MEMBER_NOT_ACCESSIBLE,
				"The protected member prot is not accessible here"
			)
		]
	}
	@Test def void testUnresolvedMethodAccessibility() {
		'''
		class A {
			A m() {
				A a = this.foo();
				return null;
			}
		}
		'''.parse => [
			// expect only the "Couldn't resolve reference..." error
			// and no error about accessibility is expected
			1.assertEquals(validate.size)
		]
	}
		@Test def void testTwoFiles() {
		val resourceSet = resourceSetProvider.get
		val first = '''class B extends A {}'''.parse(resourceSet)
		val second = '''class A { B b; }'''.parse(resourceSet)
		first.assertNoErrors
		second.assertNoErrors

		second.classes.head.assertSame(first.classes.head.superclass)
	}
	
	@Test def void testTwoFilesAlternative() {
		val first = '''class B extends A {}'''.parse
		val second = '''class A { B b; } '''.parse(first.eResource.resourceSet)
		first.assertNoErrors
		second.assertNoErrors

		second.classes.head.assertSame(first.classes.head.superclass)
	}
	
	@Test def void testPackagesAndClassQualifiedNames() {
		val first = '''
			package my.first.pack;
			class B extends my.second.pack.A {}
		'''.parse
		val second = '''
			package my.second.pack;
			class A {
			  my.first.pack.B b;
			}
		'''.parse(first.eResource.resourceSet)
		first.assertNoErrors
		second.assertNoErrors

		second.classes.head.assertSame(first.classes.head.superclass)
	}
	
	@Test def void testImports() {
		val first = '''
			package my.first.pack;
			class C1 { }
			class C2 { }
		'''.parse

		'''
			package my.second.pack;
			class D1 { }
			class D2 { }
		'''.parse(first.eResource.resourceSet)

		'''
			package my.third.pack;
			import my.first.pack.C1;
			import my.second.pack.*;
			
			class E extends C1 { // C1 is imported
			  my.first.pack.C2 c; // C2 not imported, but fully qualified
			  D1 d1; // D1 imported by wildcard
			  D2 d2; // D2 imported by wildcard
			}
		'''.parse(first.eResource.resourceSet).assertNoErrors
	}
	
	@Test def void testDuplicateClassesInFiles() {
		val first = '''
		package my.first.pack;
		
		class C {}'''.parse
		
		'''
		package my.first.pack;
		class D {}
		class C {}
		'''.parse(first.eResource.resourceSet).assertError(
				MiniJavaPackage.eINSTANCE.getClassDecl,
				MiniJavaValidator.DUPLICATE_CLASS,
				"The type C is already defined"
		)
		
		first.assertError(
			MiniJavaPackage.eINSTANCE.getClassDecl,
			MiniJavaValidator.DUPLICATE_CLASS,
			"The type C is already defined"
		)
	}
	@Test def void testStringConformance() {
		'''
			class A {
				string m() { return "foo"; }
			}
		'''.parse.assertNoErrors
	}
	
	@Test def void testWrongSuperUsage() {
		'''
		class C {
			C m() {
				return super;
			}
		}
		'''.parse.assertError(MiniJavaPackage.eINSTANCE.getSuper,
			MiniJavaValidator.WRONG_SUPER_USAGE,
			"'super' can be used only as member selection receiver"
		)
	}
	
	@Test def void testReducedAccessibility() {
		'''
		class A {
			public A m() {
				return null;
			}
		}
		
		class B extends A {
			A m() {
				return null;
			}
		}
		'''.parse.assertError(MiniJavaPackage.eINSTANCE.getMethodDecl,
			MiniJavaValidator.REDUCED_ACCESSIBILITY,
			"Cannot reduce access from public to private"
		)
	}
	@Test def void testReducedAccessibility2() {
		'''
		class A {
			protected A m() {
				return null;
			}
		}
		
		class B extends A {
			A m() {
				return null;
			}
		}
		'''.parse.assertError(MiniJavaPackage.eINSTANCE.getMethodDecl,
			MiniJavaValidator.REDUCED_ACCESSIBILITY,
			"Cannot reduce access from protected to private"
		)
	}
	
	@Test def void testReducedAccessibility3() {
		'''
		class A {
			public A m() {
				return null;
			}
		}
		
		class B extends A {
			protected A m() {
				return null;
			}
		}
		'''.parse.assertError(MiniJavaPackage.eINSTANCE.getMethodDecl,
			MiniJavaValidator.REDUCED_ACCESSIBILITY,
			"Cannot reduce access from public to protected"
		)
	}
	
	@Test def void testClassesWithSameNameButWithDifferentQNAreOK() {
		val first = '''
		package my.first.pack;
		
		class C {}'''.parse
		
		'''
		package my.second.pack;
		class C {}
		'''.parse(first.eResource.resourceSet).assertNoErrors
	}
	
	@Test def void testArrayIndex(){
		'''
			class A{
			  int[] a;
			  A n(){
			  	int[] b = new int[5];
			  	b[2.2];
			  	return null;
			  }
			}
		'''=>[
			parse.assertError(
				MiniJavaPackage.eINSTANCE.getDoubleConstant,
				MiniJavaValidator.INCOMPATIBLE_TYPES,
				lastIndexOf("2.2"),3,
				"Expected 'int' but was 'double' "
			)
		]
	}
	@Test def void testArrayAssignment(){
		'''
			class A{
			  A n(){
			  	int[] b = new int[5];
			  	b[2] = 2.2;
			  	return null;
			  }
			}
		'''=>[
			parse.assertError(
				MiniJavaPackage.eINSTANCE.getDoubleConstant,
				MiniJavaValidator.INCOMPATIBLE_TYPES,
				lastIndexOf("2.2"),3,
				"Expected 'int' but was 'double' "
			)
		]
	}
	@Test def void testWrongRefOnArray(){
		'''
			class A{
			  A n(){
			  	int b = 5;
			  	b[2] = 2;
			  	return null;
			  }
			}
		'''=>[
			parse.assertError(
				MiniJavaPackage.eINSTANCE.getSquareBrackets,
				MiniJavaValidator.WRONG_ARRAY_REF,
				lastIndexOf("b"),1,
				"Can not use '[]' on an unarray type variable"
			)
		]
	}
	
	@Test def void testNewArray(){
		'''
			class A{
			  int[] a;
			  double b;
			  A n(){
			  	this.a = new int[5];
			  	return null;
			  }
			}
		'''.parse.assertNoErrors
	}
	
	@Test def void testIntAssignedToDouble(){
		'''
			class A{
			  double b;
			  A n(){
			  	int[] a = new int[5];
			  	this.b = a[1];
			  	return null;
			  }
			}
		'''.parse.assertNoErrors
	}
	
	@Test def void testInvalidNumberOfArgs() {
		'''
		class A {}
		class B {}
		class C {
			C m(A a, B b) { return this.m(new B()); }
		}
		'''.parse.assertError(
			MiniJavaPackage.eINSTANCE.getMemberSelection,
			MiniJavaValidator.INVALID_ARGS,
			'''Invalid number of arguments: expected 2 but was 1'''
		)
	}
	
	
}