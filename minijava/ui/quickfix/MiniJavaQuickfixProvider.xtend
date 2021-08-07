package org.xtext.projects.minijava.ui.quickfix

import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.xtext.projects.minijava.validation.MiniJavaValidator
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.xtext.projects.minijava.miniJava.Statement
import org.xtext.projects.minijava.miniJava.Block

import static extension org.eclipse.xtext.EcoreUtil2.*
import org.xtext.projects.minijava.miniJava.MemberSelection
import org.xtext.projects.minijava.miniJava.MethodDecl
import org.xtext.projects.minijava.miniJava.MiniJavaPackage
import org.xtext.projects.minijava.miniJava.MiniJavaFactory
import org.xtext.projects.minijava.miniJava.MJNamedElement
import org.eclipse.xtext.diagnostics.Diagnostic

class MiniJavaQuickfixProvider extends DefaultQuickfixProvider  {
	static val ep = MiniJavaPackage.eINSTANCE
	static val factory = MiniJavaFactory.eINSTANCE
	
	@Fix(MiniJavaValidator.HIERARCHY_CYCLE)
	def removeSuperClass(Issue issue, IssueResolutionAcceptor acceptor){
		acceptor.accept(
			issue,
			"Remove superclass",
			'''Remove superclass ' '''+issue.data.get(0)+''' ' ''',
			"delete_obj.gif",
			[element, context |
				(element as ClassDecl).superclass = null
			]
		)
	}
	
	@Fix(MiniJavaValidator.UNREACHABLE_CODE)
	def removeRedundantStatement(Issue issue, IssueResolutionAcceptor acceptor){
		acceptor.accept(
			issue,
			"Remove redundant statements",
			'''Remove redundant statements ''',
			"delete_obj.gif",
			[
				element, context |
				val currentBlock = element.getContainerOfType(Block)
				val index = currentBlock.statements.indexOf((element as Statement))
				while(currentBlock.statements.length > index){
					currentBlock.statements.remove(index);
				}
			]
		)
	}
	
	@Fix(MiniJavaValidator.METHOD_INVOCATION_ON_FIELD)  ////////////////////////
	def removeMethodInvocation(Issue issue, IssueResolutionAcceptor acceptor){
		acceptor.accept(
			issue,
			"Remove methodinvocation ",
			'''Remove methodinvocation of this member selction. ''',
			"delete_obj.gif",
			[
				element, context |
				val sel = element as MemberSelection
				sel.methodinvocation = false
				sel.args.clear()
			]
		)
	}
	
	@Fix(MiniJavaValidator.MISSING_FINAL_RETURN) //////////////////////////  
	def addReturnStatement(Issue issue, IssueResolutionAcceptor acceptor){
		acceptor.accept(
			issue,
			"Add a return statement ",
			'''Add a Return statement for this Method Declaration''',
			"delete_obj.gif",
			[
				element, context |
				val currentMethod = 
					element.getContainerOfType(MethodDecl)
				currentMethod.body.statements.add(factory.createReturn()=>[
					expression = factory.createNull()
				])
			]
		)
	}
	
	@Fix(MiniJavaValidator.DUPLICATE_CLASS)
	def renameClassDecl(Issue issue, IssueResolutionAcceptor acceptor){
		acceptor.accept(
			issue,
			"Rename this Class ",
			'''Rename «issue.data» as  «issue.data»_a ''',
			"delete_obj.gif",
			[
				element, context |
				(element as ClassDecl).name = (element as ClassDecl).name + '''_a'''
			]
		)
	}
	
	@Fix(MiniJavaValidator.DUPLICATE_ELEMENT)
	def renameNamedElement(Issue issue, IssueResolutionAcceptor acceptor){
		acceptor.accept(
			issue,
			"Rename this NamedElement ",
			'''Rename «issue.data» as  «issue.data»_1 ''',
			"delete_obj.gif",
			[
				element, context |
				(element as MJNamedElement).name = (element as MJNamedElement).name + '''_1'''
			]
		)
	}
	
}