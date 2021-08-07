package org.xtext.projects.minijava

import static extension org.eclipse.xtext.EcoreUtil2.*
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.xtext.projects.minijava.miniJava.Expression
import org.xtext.projects.minijava.miniJava.SymbolRef
import org.xtext.projects.minijava.miniJava.Symbol
import org.xtext.projects.minijava.miniJava.Type
import org.xtext.projects.minijava.miniJava.NewObject
import org.xtext.projects.minijava.miniJava.New
import org.xtext.projects.minijava.miniJava.MiniJavaFactory
import org.xtext.projects.minijava.miniJava.IntConstant
import org.xtext.projects.minijava.miniJava.BoolConstant
import org.xtext.projects.minijava.miniJava.VarDecl
import org.xtext.projects.minijava.miniJava.VarListObj
import org.xtext.projects.minijava.miniJava.This
import org.xtext.projects.minijava.miniJava.Super
import org.xtext.projects.minijava.miniJava.StringConstant
import org.xtext.projects.minijava.miniJava.Return
import org.xtext.projects.minijava.miniJava.Assignment
import org.xtext.projects.minijava.miniJava.MethodDecl
import org.xtext.projects.minijava.miniJava.MiniJavaPackage
import org.xtext.projects.minijava.miniJava.MemberSelection
import org.xtext.projects.minijava.miniJava.And
import org.xtext.projects.minijava.miniJava.CompExpression
import org.xtext.projects.minijava.miniJava.SquareBrackets
import org.xtext.projects.minijava.miniJava.Parameter
import org.xtext.projects.minijava.miniJava.MultOrDiv
import org.xtext.projects.minijava.miniJava.LogicNegation
import org.xtext.projects.minijava.miniJava.PlusOrMinus
import org.xtext.projects.minijava.miniJava.CommonType
import org.xtext.projects.minijava.miniJava.DoubleConstant

class MiniJavaTypeComputer {
	/*
	 * This class aims to compute the type of an expression and compute an expression's expected type 
	 */
	static val factory = MiniJavaFactory.eINSTANCE
	static val ep = MiniJavaPackage.eINSTANCE
	public static val INT_TYPE = factory.createCommonType => [typename = 'int']
	public static val DOUBLE_TYPE = factory.createCommonType => [typename = 'double']
	public static val BOOLEAN_TYPE = factory.createCommonType => [typename = 'boolean']
	public static val NULL_TYPE = factory.createCommonType => [typename = 'null']
	
	def Type typeFor(Expression e){
		switch(e){
			Assignment:
				e.left.typeFor
			And:
				BOOLEAN_TYPE
			CompExpression:
				BOOLEAN_TYPE
			PlusOrMinus:{
				if(e.left.typeFor instanceof CommonType && e.right.typeFor instanceof CommonType){
					if((e.left.typeFor as CommonType).typename == 'double' || (e.right.typeFor as CommonType).typename == 'double')
						DOUBLE_TYPE
					else
						INT_TYPE
				}	
			}
			MultOrDiv:{
				if(e.left.typeFor instanceof CommonType && e.right.typeFor instanceof CommonType){
					if((e.left.typeFor as CommonType).typename == 'double' || (e.right.typeFor as CommonType).typename == 'double')
						DOUBLE_TYPE
					else
						INT_TYPE
				}	
			}
			LogicNegation:
				BOOLEAN_TYPE
			MemberSelection:
				e.member.type
			SquareBrackets:{
				val expr_type = factory.createCommonType()
				val leftType = e.left.typeFor
				if(leftType instanceof CommonType){
					expr_type.typename = leftType.typename
					expr_type.classname = leftType.classname
					for(i:0..<leftType.arrays.length-1){
						expr_type.arrays.add('[]')
					}
				}
				expr_type
			}
			NewObject:{
				val expr_type = factory.createCommonType()
			 	expr_type.classname = e.type
			 	expr_type
			}
			New:{
				val expr_type = factory.createCommonType()
				expr_type.typename = e.dataType.typename
				for(i:0..e.dataType.arrays.length){
					expr_type.arrays.add('[]')
				}
				expr_type 
			}
			DoubleConstant:{
				DOUBLE_TYPE
			}
			IntConstant:{
				INT_TYPE
			}
			BoolConstant:{
				BOOLEAN_TYPE
			}
			SymbolRef:{
				if(e.symbol instanceof Parameter){
					(e.symbol as Parameter).type
				}
				else if(e.symbol instanceof VarDecl){
					(e.symbol as VarDecl).decltype
				}
			}
			VarListObj:{
				val expr_type = factory.createVarListType()
				val vars = e.vars
				val varlist = factory.createVarList()
				val element_list = varlist.vars
				for(i:0 ..< vars.length){
					element_list.set(i,e.vars.get(i))
				}
				expr_type.setTypelist(varlist)
				expr_type
			}
			This:{
				val thisclass = e.getContainerOfType(ClassDecl);
				val expr_type = factory.createCommonType()
				expr_type.classname = thisclass
				expr_type
			}
			Super:{
				val superof = e.getContainerOfType(ClassDecl)
				val expr_type = factory.createCommonType()
				expr_type.classname = superof.superclass // wait minijavalib
				expr_type
			}
			StringConstant:{
				val expr_type = factory.createCommonType()
				expr_type.typename = 'string'
				expr_type
			}
		}
	}
	
	def isPrimitive(ClassDecl c){
		c.eResource === null	
	}
	
	def expectedType(Expression e) {
		val c = e.eContainer
		val f = e.eContainingFeature
		switch (c) {
			VarDecl:
				c.decltype
			Assignment case f == ep.getAssignment_Right:
				typeFor(c.left)
			Return:{
				val decl = c.getContainerOfType(MethodDecl).type 
				decl
			}
			case f == ep.getIfStatement_Expression || f == ep.getWhileStatement_Expression:
				BOOLEAN_TYPE
			And :
				BOOLEAN_TYPE
			PlusOrMinus :
				DOUBLE_TYPE
			CompExpression :
				DOUBLE_TYPE
			MultOrDiv :
				DOUBLE_TYPE
			LogicNegation:
				BOOLEAN_TYPE
			MemberSelection case f == ep.getMemberSelection_Args: {
				// assume that it refers to a method and that there
				// is a parameter corresponding to the argument
				try {
					(c.member as MethodDecl).params.get(c.args.indexOf(e)).type
				} catch (Throwable t) {
					null // otherwise there is no specific expected type
				}
			}
			VarListObj case f == ep.getVarListObj_Exprs:{
				(c as VarListObj).vars.get(c.exprs.indexOf(e)).decltype
			}
			SquareBrackets case f == ep.getSquareBrackets_Right:
				INT_TYPE
			New case f == ep.getNew_Capacity:
				INT_TYPE
		}
	}
}