package org.xtext.projects.minijava

import org.xtext.projects.minijava.miniJava.Block
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.xtext.projects.minijava.miniJava.FieldDecl
import org.xtext.projects.minijava.miniJava.MethodDecl
import org.xtext.projects.minijava.miniJava.Return
import com.google.inject.Inject
import org.xtext.projects.minijava.miniJava.MemberDecl
import org.xtext.projects.minijava.miniJava.CommonType

class MiniJavaModelUtil {

	@Inject extension MiniJavaLib

	def fields(ClassDecl c) {
		c.members.filter(FieldDecl)
	}

	def methods(ClassDecl c) {
		c.members.filter(MethodDecl)
	}

	def returnStatement(MethodDecl m) {
		m.body.returnStatement
	}

	def returnStatement(Block block) {
		block.statements.filter(Return).head
	}
	
	def classHierarchy(ClassDecl c) {
		val visited = newLinkedHashSet()

		var current = c.superclass
		while (current !== null && !visited.contains(current)) {
			visited.add(current)
			current = current.superclass
		}

		val object = c.getMiniJavaObjectClass
		if (object !== null)
			visited.add(object)

		visited
	}

	def classHierarchyMethods(ClassDecl c) {
		// reverse the list so that methods in subclasses
		// will be added later to the map, thus overriding
		// the one already present in the superclasses
		// if the methods have the same name
		c.classHierarchy.toList.reverseView.
			map[methods].flatten.toMap[name]
	}

	def classHierarchyMembers(ClassDecl c) {
		c.classHierarchy.map[members].flatten
	}

	def memberAsString(MemberDecl m) {
		m.name +
		if (m instanceof MethodDecl)
			"(" + m.params.map[(type as CommonType).typename].join(", ") + ")"
		else ""
	}

	def memberAsStringWithType(MemberDecl m) {
		m.memberAsString + " : " + (m.type as CommonType).typename
	}
}
