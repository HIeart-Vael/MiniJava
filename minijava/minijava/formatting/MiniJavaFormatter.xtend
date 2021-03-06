/*
 * generated by Xtext 2.25.0
 */
package org.xtext.projects.minijava.formatting2

import com.google.inject.Inject
//import static org.xtext.projects.minijava.*

import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument

import org.xtext.projects.minijava.miniJava.Goal
import org.xtext.projects.minijava.miniJava.ImportDecl
import org.xtext.projects.minijava.miniJava.MainClass
import org.xtext.projects.minijava.miniJava.MainMethod
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.xtext.projects.minijava.miniJava.FieldDecl
import org.xtext.projects.minijava.miniJava.MethodDecl

import org.xtext.projects.minijava.miniJava.Block
import org.xtext.projects.minijava.miniJava.BranchBlock
import org.xtext.projects.minijava.miniJava.Statement
import org.xtext.projects.minijava.miniJava.VarDecl
import org.xtext.projects.minijava.miniJava.Return
import org.xtext.projects.minijava.miniJava.Expression
import org.xtext.projects.minijava.miniJava.IfStatement
import org.xtext.projects.minijava.miniJava.WhileStatement

import org.xtext.projects.minijava.miniJava.Assignment
import org.xtext.projects.minijava.miniJava.And
import org.xtext.projects.minijava.miniJava.CompExpression
import org.xtext.projects.minijava.miniJava.PlusOrMinus
import org.xtext.projects.minijava.miniJava.MultOrDiv
import org.xtext.projects.minijava.miniJava.LogicNegation
import org.xtext.projects.minijava.miniJava.MiniJavaPackage //mwe2生成的接口
import org.xtext.projects.minijava.miniJava.MemberDecl
import org.xtext.projects.minijava.services.MiniJavaGrammarAccess

class MiniJavaFormatter extends AbstractFormatter2 {
	
	@Inject extension MiniJavaGrammarAccess
	
	//setNewLines(INT minNewLines, INT defaultNewLines, INT maxNewLines)
	def dispatch void format(Goal goal, extension IFormattableDocument document) {
		goal.prepend[setNewLines(0, 0, 2); noSpace; highPriority].append[newLine]
	
		for (importDecl : goal.imports) {
			importDecl.format
		}
		for (mainclass : goal.mainclass) {
			mainclass.format
		}
		for (classDecl : goal.classes) {
			classDecl.format
		}
	}
	
	def dispatch void format(ImportDecl importDecl, extension IFormattableDocument document) {
		importDecl.regionFor.keyword(';').prepend[oneSpace].append[newLine]
	}
	
	def dispatch void format(MainClass mainclass, extension IFormattableDocument document) {
		mainclass.regionFor.keyword('class').prepend[setNewLines(2, 2, 3); noSpace]
		mainclass.regionFor.feature(MiniJavaPackage.Literals.MAIN_CLASS__NAME).surround[oneSpace]
		
		val open = mainclass.regionFor.keyword('{')
		val close = mainclass.regionFor.keyword('}')
		
		open.prepend[newLine].append[setNewLines(1, 1, 2)]
		interior(open, close)[indent] //内部缩进
		close.prepend[setNewLines(1, 1, 2)]
		
		mainclass.mainMethod.format
		for (members : mainclass.members) {
			members.format  //TODO
		}
	}
	
	def dispatch void format(ClassDecl classDecl, extension IFormattableDocument document) {
		classDecl.regionFor.keyword('class').prepend[setNewLines(2, 2, 3); noSpace]
		classDecl.regionFor.keyword('extend').surround[oneSpace]
		classDecl.regionFor.feature(MiniJavaPackage.Literals.MJ_NAMED_ELEMENT__NAME).surround[oneSpace]
		classDecl.regionFor.feature(MiniJavaPackage.Literals.CLASS_DECL__SUPERCLASS).surround[oneSpace]
		
		val open = classDecl.regionFor.keyword('{')
		val close = classDecl.regionFor.keyword('}')
		
		open.prepend[newLine].append[setNewLines(1, 1, 2)]
		interior(open, close)[indent] //内部缩进
		close.prepend[setNewLines(1, 1, 2)]

		for (members : classDecl.members) {
			members.format 
		}
	}
	
	def dispatch void format(MemberDecl member, extension IFormattableDocument document) {
		if(member == FieldDecl) {
			FieldDecl.format
		}
		else {
			MethodDecl.format
		}
	}
	
	def dispatch void format(FieldDecl fieldDecl, extension IFormattableDocument document) {
		fieldDecl.prepend[newLine]
		fieldDecl.regionFor.feature(MiniJavaPackage.Literals.COMMON_TYPE__TYPENAME).surround[oneSpace]
		fieldDecl.regionFor.feature(MiniJavaPackage.Literals.MJ_NAMED_ELEMENT__NAME).surround[oneSpace]
		fieldDecl.regionFor.keyword(';').prepend[oneSpace].append[newLine]
	}
	
	def dispatch void format(MethodDecl methodDecl, extension IFormattableDocument document) {
		methodDecl.prepend[newLine]
		methodDecl.body.format
	}
	
	def dispatch void format(MainMethod mainMethod, extension IFormattableDocument document) {
		mainMethod.regionFor.keyword('public').prepend[setNewLines(1, 1, 2)].prepend[oneSpace].append[oneSpace]
		mainMethod.regionFor.keyword('static').prepend[oneSpace].append[oneSpace]
		mainMethod.regionFor.keyword('void').prepend[oneSpace].append[oneSpace]
		mainMethod.regionFor.keyword('main').prepend[oneSpace].append[oneSpace]
		
		mainMethod.regionFor.keyword('(').surround[noSpace]
		mainMethod.regionFor.keyword('[').surround[noSpace]
		mainMethod.regionFor.keyword(']').append[oneSpace]
		mainMethod.regionFor.keyword(')').prepend[noSpace].append[oneSpace]
		
		mainMethod.body.format
	}
	
	def dispatch void format(Block body, extension IFormattableDocument document) {
		val open = body.regionFor.keyword('{')
		val close = body.regionFor.keyword('}')
		
		open.prepend[newLine].append[setNewLines(1, 1, 2)]
		interior(open, close)[indent]
		close.prepend[setNewLines(1, 1, 2)]
		
		for (statements : body.statements) {
			statements.format
		}
	}

	
	def dispatch void format(Statement statements, extension IFormattableDocument document) {
		/*	VarDecl | Return |	Expression ';' |	IfStatement |	WhileStatement */
		if(statements == VarDecl) {
			VarDecl.format
		}
		else if(statements == Return) {
			Return.format
		}
		else if(statements == IfStatement) {
			IfStatement.format
		}
		else if(statements == WhileStatement) {
			WhileStatement.format
		}
		else  {  //expression+';'
			statements.regionFor.keyword(';').prepend[oneSpace].append[newLine]
			Expression.format
		}

	}
	
	def dispatch void format(VarDecl varDecl, extension IFormattableDocument document) {
		varDecl.regionFor.feature(MiniJavaPackage.Literals.MJ_NAMED_ELEMENT__NAME).surround[oneSpace]
		varDecl.regionFor.keyword('=').surround[oneSpace]
		varDecl.regionFor.keyword(';').prepend[oneSpace].append[newLine]
	}
	
	def dispatch void format(Return returnDecl, extension IFormattableDocument document) {
		returnDecl.regionFor.keyword('return').prepend[setNewLines(1, 1, 2)].append[oneSpace]
		returnDecl.regionFor.feature(MiniJavaPackage.Literals.MJ_NAMED_ELEMENT__NAME).surround[oneSpace]
		
		returnDecl.expression.format
		returnDecl.regionFor.keyword(';').prepend[oneSpace].append[newLine]
	}
	
	
	def dispatch void format(IfStatement ifstatement, extension IFormattableDocument document) {
		ifstatement.regionFor.keyword('if').prepend[setNewLines(1, 1, 2)].append[oneSpace]
		ifstatement.regionFor.keyword('else').prepend[setNewLines(1, 1, 2)].append[oneSpace]
		
		val open = ifstatement.regionFor.keyword('(')
		val close = ifstatement.regionFor.keyword(')')
		open.surround[noSpace]
		close.prepend[noSpace].append[oneSpace]
		
		Expression.format
		ifstatement.thenBlock.format
		ifstatement.elseBlock.format
	}
	
	def dispatch void format(WhileStatement whilestatement, extension IFormattableDocument document) {
		whilestatement.regionFor.keyword('while').prepend[setNewLines(1, 1, 2)].append[oneSpace]
		
		val open = whilestatement.regionFor.keyword('(')
		val close = whilestatement.regionFor.keyword(')')
		open.surround[noSpace]
		close.prepend[noSpace].append[oneSpace]
		
		Expression.format	
		
		whilestatement.whileBlock.format
	}
	
	def dispatch void format(BranchBlock branchblock, extension IFormattableDocument document) {
		val open = branchblock.regionFor.keyword('{')
		val close = branchblock.regionFor.keyword('}')
		
		open.prepend[newLine].append[setNewLines(1, 1, 2)]
		interior(open, close)[indent]
		close.prepend[setNewLines(1, 1, 2)]
		
		branchblock.regionFor.keyword(';').prepend[oneSpace].append[newLine]
		
		for (statements :branchblock.statements) {
			statements.format
		}
	}
	
	def dispatch void format(Expression expression, extension IFormattableDocument document) {
		
		switch(expression) {
			Assignment: {
				expression.regionFor.keyword('=').surround[oneSpace]
				expression.left.format
				expression.right.format
			}
			And: {
				expression.regionFor.keyword('&&').surround[oneSpace]
				expression.left.format
				expression.right.format
			}
			CompExpression: {
				expression.regionFor.keyword('<').surround[oneSpace]
				expression.left.format
				expression.right.format
			}
			PlusOrMinus: {
				if(expression.op.equals('+'))
					expression.regionFor.keyword('+').surround[oneSpace]
				else
					expression.regionFor.keyword('-').surround[oneSpace]
				expression.left.format
				expression.right.format
			}
			MultOrDiv: {
				if(expression.op == '*')
					expression.regionFor.keyword('*').surround[oneSpace]
				else
					expression.regionFor.keyword('/').surround[oneSpace]
				expression.left.format
				expression.right.format
			}
			LogicNegation: {
				expression.regionFor.keyword('!').prepend[oneSpace].append[noSpace]
				expression.right.format
			}
		}
		
	}
	
}
	

