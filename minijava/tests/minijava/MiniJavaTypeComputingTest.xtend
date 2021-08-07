package org.xtext.projects.minijava.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.runner.RunWith
import org.xtext.projects.minijava.MiniJavaModelUtil
import org.xtext.projects.minijava.MiniJavaTypeComputer
import org.xtext.projects.minijava.miniJava.Goal
import org.xtext.projects.minijava.miniJava.MiniJavaPackage
import org.xtext.projects.minijava.miniJava.Statement
import org.xtext.projects.minijava.miniJava.Expression
import org.xtext.projects.minijava.miniJava.CommonTypeDecl
import org.xtext.projects.minijava.miniJava.CommonType

import static extension org.junit.Assert.*
import org.junit.Test
import org.xtext.projects.minijava.miniJava.VarDecl
import org.xtext.projects.minijava.miniJava.Assignment
import org.xtext.projects.minijava.miniJava.Return
import org.xtext.projects.minijava.miniJava.IfStatement
import org.xtext.projects.minijava.miniJava.MemberSelection
import org.xtext.projects.minijava.miniJava.WhileStatement
import org.xtext.projects.minijava.miniJava.And
import org.xtext.projects.minijava.miniJava.CompExpression

@RunWith(XtextRunner)
@InjectWith(MiniJavaInjectorProvider)
class MiniJavaTypeComputingTest {
	@Inject extension ParseHelper<Goal> parseHelper
	@Inject extension MiniJavaModelUtil
	@Inject extension MiniJavaTypeComputer
	static val ep = MiniJavaPackage.eINSTANCE
	/*
	 * Direct test
	 * normal data
	 */
	@Test def void exprTypeInt() {
		"123".assertDataType('int')
	}
	@Test def void exprTypeDouble(){
		"123.123".assertDataType('double')
	}
	@Test def void exprTypeBool(){
		"true".assertDataType('boolean')
	}
	@Test def void exprNewData(){
		"new int a[]".assertDataType('int')
	}
	@Test def void exprNewObejct(){
		"new R()".assertObjectType('R')	
	}
	/*
	 * Ref Test
	 */
	@Test def void exprObjectFieldRef(){
		"this.f".assertObjectType('F')
	}
	@Test def void exprThis(){
		"this".assertObjectType('C')
	}
	@Test def void exprSuper(){
		"super".assertObjectType('R')
	}
	@Test def void exprSymbolPara(){
		"p".assertObjectType('P')
		
	}
	@Test def void testTypeForUnresolvedReferences() {
		'''
		class C {
			U m() {
				f ; // unresolved symbol
				this.n(); // unresolved method 
				this.f; // unresolved field
				return null;
			}
		}
		'''.parse => [
			classes.head.methods.head.body.statements => [
				get(0).statementExpressionType.assertNull
				get(1).statementExpressionType.assertNull
				get(2).statementExpressionType.assertNull
			]
		]
	}
	/*
	 * MemberSelection test
	 */
	@Test def void exprFieldSelection(){
		"this.f".assertObjectType('F')
	}
	@Test def void exprFieldSelectionD(){
		"this.a".assertDataType('int')
	}
	@Test def void exprMethodRef(){
		"this.one()".assertDataType('int')
	}
	@Test def void exprAssignment(){
		"this.a = 1".assertDataType('int')
	}
	@Test def void exprArrayRef(){
		"this.c[1] + this.a".assertDataType('double')
	}
	/*
	 * Computing Expression Type
	 * 
	 */
	@Test def void exprLogicAnd(){
		"this.a && true".assertDataType('boolean')	
	}
	@Test def void exprPlus(){
		"1+2".assertDataType('double')
	}
	@Test def void exprCompPlus(){
		"this.a + this.a".assertDataType('int')
	}
	@Test def void exprParenthesis(){
		"(this.a + this.a)".assertDataType('int')
	}
	@Test def void testIsPrimitiveType() {
		'''
		class C {
			C m() {
				return true;
			}
		}
		'''.parse.classes.head => [
			it.isPrimitive.assertFalse
		]
	}
	/*
	 * get expected type 
	 * 
	 */
	@Test def void arrayVarDeclExpr(){
	 	('''V v = null;'''.testStatements.parse.classes.last.methods.last.body.statements.head  as VarDecl)
	 	.expression.assertExpectedCommonType('V')
	 } 
	@Test def void testAssignmentRightExpectedType() {
		('''this.f = null;'''.testStatements.parse.classes.last.methods.last.body.statements.head as Assignment).
			right.assertExpectedCommonType("F")
	}
	@Test def void testAssignmentLeftExpectedType() {
		('''this.f = null;'''.testStatements.parse.classes.last.methods.last.body.statements.head as Assignment).
			left.expectedType.assertNull
	}
	@Test def void testReturnExpectedType() {
		("".testStatements.parse.classes.last.methods.last.body.statements.last as Return).
			expression.assertExpectedCommonType("R")
	}
	@Test def void testIfExpressionExpectedType() {
		("if(e){}".testStatements.parse.classes.last.methods.last.body.statements.head as IfStatement).
			expression.assertExpectedCommonType("boolean")
	}
	@Test def void testWhileExpressionExpectedType() {
		("while(e){}".testStatements.parse.classes.last.methods.last.body.statements.head as WhileStatement).
			expression.assertExpectedCommonType("boolean")
	}
	@Test def void testMethodInvocationArgsExpectedType() {
		("this.m(new P1(), new P2());".testStatements.parse.classes.last.methods.last.body.statements.head  as MemberSelection).
			args => [
				get(0).assertExpectedCommonType("P1")
				get(1).assertExpectedCommonType("P2")
			]
	}
	@Test def void testAndComExpectedType() {
		("this.a && this.b".testStatements.parse.classes.last.methods.last.body.statements.head as And).
			right.assertExpectedCommonType("boolean")
	}
	@Test def void testCompComExpectedType() {
		("this.a < this.b".testStatements.parse.classes.last.methods.last.body.statements.head as CompExpression).
			left.assertExpectedCommonType("double")
	}
	
	def private statementExpressionType(Statement s) {
		(s as Expression).typeFor
	}
	
	def private assertDataType(CharSequence testExp, String expectClassName){
		('''
			class R{}
			class P{}
			class V{}
			class N{}
			class F{}
			
			class C {
				F f;
				int a;
				int[] b;
				double[] c;
				int one(){
					111;
					return 1;
				}
				int m(P p) {
					123.2;
					'''+testExp+''';
				return a;
				}
			}
		''').parse => [
			expectClassName.assertEquals((classes.last.methods.last.body.statements.get(1).statementExpressionType as CommonType).typename)
		]
	}
	def private assertObjectType(CharSequence testExp, String expectClassName){
		('''
			class R{}
			class P{}
			class V{}
			class N{}
			class F{
				public int b;
			}
			
			class C extends R{
				F f;
				int a;
				int[] c;
				int m(P p){
					123.2;
					'''+testExp+'''
				return a;
				}
			}
		''').parse => [
			expectClassName.assertEquals((classes.last.methods.last.body.statements.get(1).statementExpressionType as CommonType).classname.name)
		]
	}
	def private testStatements(CharSequence statement) {
		'''
		class R {  }
		class P1 {  }
		class P2 {  }
		class V {  }
		class F {  }
		
		class C {
			F f;
			int a;
			double[] b;
			R m(P1 p1, P2 p2) {'''
				+statement+
		'''
				return null;
			}
		}
		'''
	}
	def private assertExpectedCommonType(Expression expr, String expectedClassName) {
		val fulltype = (expr.expectedType as CommonType)
		var fullname = fulltype.typename
		if(fulltype !== null){
			if(fulltype.classname !== null){
				fullname = fulltype.classname.name
			}else{
				fullname = fulltype.typename
			}
		} 
		expectedClassName.assertEquals(fullname)
	}
	
}