/*
 * generated by Xtext 2.25.0
 */
package org.xtext.projects.minijava.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.util.ParseHelper
import org.xtext.projects.minijava.miniJava.Goal
import org.xtext.projects.minijava.MiniJavaModelUtil
import org.xtext.projects.minijava.miniJava.FieldDecl
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import static extension org.junit.Assert.*
import org.xtext.projects.minijava.miniJava.VarListTypeDecl
import org.xtext.projects.minijava.miniJava.Expression
import org.xtext.projects.minijava.miniJava.This
import org.xtext.projects.minijava.miniJava.MemberSelection
import org.xtext.projects.minijava.miniJava.Assignment
import org.xtext.projects.minijava.miniJava.CommonTypeDecl
import org.xtext.projects.minijava.miniJava.MemberDecl
import org.xtext.projects.minijava.miniJava.MethodDecl
import org.xtext.projects.minijava.miniJava.CommonType
import org.xtext.projects.minijava.miniJava.VarListType
import org.xtext.projects.minijava.miniJava.Type
import org.xtext.projects.minijava.miniJava.SymbolRef
import org.xtext.projects.minijava.miniJava.Parameter
import org.xtext.projects.minijava.miniJava.SquareBrackets

@RunWith(XtextRunner)
@InjectWith(MiniJavaInjectorProvider)
class MiniJavaParsingTest {
	@Inject extension ParseHelper<Goal> parseHelper
	@Inject extension MiniJavaModelUtil
	@Test
	def void loadModel() {
		val result = parseHelper.parse('''
			class A{
				
			}
		''')
		Assert.assertNotNull(result)
	}
	@Test
	def void arrayDecl(){
		'''
			class F{}
			class A{
				F f;
				int a;
				double[] b;
				int m(){
					 this.a = 1;
				}
			}
		'''.parse =>[
			val ifs = 
				classes.last.fields.get(2).type
			if(ifs instanceof CommonType){
				ifs.typename.assertEquals('double') 
				ifs.arrays.assertNotNull
			}
		]
	}
	@Test def void arrayRef(){
		'''
			class F{}
			class A{
				F f;
				int a;
				double [] b;
				int m(){
					int[] c;
					this.b[0];
				}
			}
		'''.parse =>[
			val ifs = 
				classes.last.methods.last.body.statements.get(1) as Expression
				(ifs instanceof SquareBrackets).assertTrue
			]
	}
	@Test
	def void MemberExpDecl(){
		'''
			class C{
				(int a, int b) c;
			}
		'''.parse =>[
			val ifs = 
				classes.head as ClassDecl
			ifs.fields.head.assertNotNull
		]
	} 
	@Test
	def void VarListRef(){
		'''
			class F{}
			class A{
				F f;
				int a;
				int m(){
					this.f;
					f;
				}
			}
		'''.parse =>[
			val ifs = 
				classes.last.methods.head.body.statements.get(1) as Expression
			if(ifs instanceof SymbolRef)
				ifs.symbol.assertEquals(classes.last.fields.head)
		]
	}
	
	@Test
	def void VarListThis(){
		'''
			class F{
				int 
			}
			class A extends F{
				int a;
				F f;
				int X(){
					
					return 1;
				}
				int m(){
					this.f;
				}
			}
		'''.parse =>[
			val ifs = 
				classes.last.methods.last.body.statements.get(0) as Expression
			if(ifs instanceof MemberSelection)
				(ifs.member.type as CommonType).classname.name.assertEquals('F')
		]
	}
	
	@Test
	def void VarListAssignment(){
		'''
			class F{}
			class A{
				F f;
				int a;
				int m(){
					a = 1;
				}
			}
		'''.parse =>[
			val ifs = 
				classes.last.methods.head.body.statements.get(0) as Expression
			if(ifs instanceof Assignment)
				(ifs.left instanceof SymbolRef).assertTrue
		]
	}
	
	
}


/* 
val result = parseHelper.parse('''
			Hello Xtext!
		''')
		Assertions.assertNotNull(result)
		val errors = result.eResource.errors
		Assertions.assertTrue(errors.isEmpty, '''Unexpected errors: ?errors.join(", ")?''')*/