package org.xtext.projects.minijava.validation

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.xtext.projects.minijava.miniJava.MJAccessLevel
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.xtext.projects.minijava.miniJava.MemberDecl
import org.xtext.projects.minijava.MiniJavaTypeConformance

import static extension org.eclipse.xtext.EcoreUtil2.*

class MiniJavaAccessibility {

	@Inject extension MiniJavaTypeConformance

	def isAccessibleFrom(MemberDecl member, EObject context) {
		val contextClass = context.getContainerOfType(ClassDecl)
		val memberClass = member.getContainerOfType(ClassDecl)
		switch (contextClass) {
			case contextClass === memberClass:
				true
			case contextClass.isSubclassOf(memberClass):
				member.access != MJAccessLevel.PRIVATE
			default:
				member.access == MJAccessLevel.PUBLIC
		}
	}
}
