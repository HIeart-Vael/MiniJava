package org.xtext.projects.minijava.validation

import org.xtext.projects.minijava.MiniJavaModelUtil
import com.google.inject.Inject
import org.xtext.projects.minijava.miniJava.ClassDecl
import org.eclipse.xtext.validation.Check
import org.xtext.projects.minijava.miniJava.MiniJavaPackage
import org.xtext.projects.minijava.miniJava.MemberSelection
import org.xtext.projects.minijava.miniJava.FieldDecl
import org.xtext.projects.minijava.miniJava.MethodDecl
import org.xtext.projects.minijava.MiniJavaTypeComputer
import org.xtext.projects.minijava.MiniJavaTypeComformance
import static extension org.eclipse.xtext.EcoreUtil2.*
import org.xtext.projects.minijava.miniJava.Return
import org.xtext.projects.minijava.miniJava.Block
import org.xtext.projects.minijava.miniJava.Expression
import org.xtext.projects.minijava.miniJava.CommonType
import org.xtext.projects.minijava.miniJava.Type
import org.xtext.projects.minijava.miniJava.Goal
import org.xtext.projects.minijava.validation.MiniJavaAccessibility
import org.xtext.projects.minijava.miniJava.Super
import org.xtext.projects.minijava.miniJava.SquareBrackets
import org.xtext.projects.minijava.miniJava.VarDecl
import com.google.common.collect.HashMultimap
import org.xtext.projects.minijava.miniJava.MJNamedElement
import org.eclipse.emf.ecore.EObject
import org.xtext.projects.minijava.miniJava.MemberDecl
import org.eclipse.xtext.validation.CheckType
import org.xtext.projects.minijava.scoping.MiniJavaIndex
import org.eclipse.xtext.naming.IQualifiedNameProvider

class MiniJavaValidator extends AbstractMiniJavaValidator {
	protected static val ISSUE_CODE_PREFIX = "org.example.minijava."
	public static val HIERARCHY_CYCLE = 
										ISSUE_CODE_PREFIX + "HierarchyCycle"
	public static val FIELD_SELECTION_ON_METHOD =
										ISSUE_CODE_PREFIX + "FieldSelectionOnMethod"
	public static val METHOD_INVOCATION_ON_FIELD =
										ISSUE_CODE_PREFIX + "MethodInvocationOnField"
	public static val UNREACHABLE_CODE = 
										ISSUE_CODE_PREFIX + "UnreachableCode"				
	public static val INCOMPATIBLE_TYPES = 
										ISSUE_CODE_PREFIX + "IncompatibleTypes" 	
	public static val MISSING_FINAL_RETURN = 
										ISSUE_CODE_PREFIX + "MissingReturn"	
	public static val WRONG_SUPER_USAGE = 
										ISSUE_CODE_PREFIX + "WrongSuperUsage"		
	public static val WRONG_ARRAY_REF = 
										ISSUE_CODE_PREFIX + "WrongArrayRef"
	public static val INVALID_ARGS = 
										ISSUE_CODE_PREFIX + "InvalidArgs"
	public static val DUPLICATE_ELEMENT = 
										ISSUE_CODE_PREFIX + "DuplicateElement"		
	public static val MEMBER_NOT_ACCESSIBLE = 
					                    ISSUE_CODE_PREFIX + "MemberNotAccessible"
	public static val WRONG_METHOD_OVERRIDE =
										ISSUE_CODE_PREFIX + "WrongMethodOverride"			
	public static val REDUCED_ACCESSIBILITY = 
										ISSUE_CODE_PREFIX + "ReducedAccessibility"	            
	public static val DUPLICATE_CLASS = 
										ISSUE_CODE_PREFIX + "DuplicateClass"
	
	@Inject extension MiniJavaModelUtil
	@Inject extension MiniJavaTypeComputer
	@Inject extension MiniJavaTypeComformance
	@Inject extension MiniJavaAccessibility
	@Inject extension MiniJavaIndex
	@Inject extension IQualifiedNameProvider
	
	/*  
	 * HierarchyCheck
	 * Check Hierarchy Cycle  
	 *
	 * */
	@Check def checkClassHierarchy(ClassDecl c) {
		if (c.classHierarchy.contains(c)) {
			error("exists cycle in hierarchy of class '" + c.name + "'",
				MiniJavaPackage.eINSTANCE.getClassDecl_Superclass,
				HIERARCHY_CYCLE, 
				c.superclass.name)
		}
	}
	
	
	/*
	 *  Member Selection Check
	 *  Method invocation on a field or Field selection on a method.
	 *  RS010103
	 */
	@Check def void checkMemberSelection(MemberSelection sel){
		val member = sel.member
		
		if(member instanceof FieldDecl && sel.methodinvocation){
			error(
				'''Method invocation on a field''',
				MiniJavaPackage.eINSTANCE.
					getMemberSelection_Methodinvocation,
				METHOD_INVOCATION_ON_FIELD
			)
		}
		else if (member instanceof MethodDecl && !sel.methodinvocation){
			error(
				'''Field selection on a method''',
				MiniJavaPackage.eINSTANCE.
					getMemberSelection_Member,
				FIELD_SELECTION_ON_METHOD
			)
		}
	}
	/*
	 * Extra unreachable code after Return in a Block
	 * RS020105
	 */
	@Check def void checkUnreachableCode(Block block) {
		val statements = block.statements
		for (var i = 0; i < statements.length-1; i++) {
			if (statements.get(i) instanceof Return) {
				// put the error on the statement after the return
				error("Unreachable code",
					statements.get(i+1),
					null,  
					UNREACHABLE_CODE,
					(i+1).toString)
				return
			}
		}
	}
	/*
	 * Check CommonType Conformance for all expressions 
	 * ExpectedType: double -> acutalType:int/double
	 * ExpectedType: null <-> acutalType:null
	 * ExpectedType: classname -> classname/ superclassname
	 * 
	 */
	@Check def void checkConformance(Expression expr){
		val actualType = expr.typeFor
		val expectedType = expr.expectedType
		if(expectedType === null || actualType === null)
			return;
		if( !actualType.isConformant(expectedType)){
			error("Incompatible types. Expected '" + expectedType.getTypeName + "' but was '" + actualType.getTypeName + "' ",
				null, 
				INCOMPATIBLE_TYPES
			)
		}	
	}
	 /*
	  * 
	  */
	 @Check def void checkMethodInvocationArguments(MemberSelection sel) {
		val method = sel.member
		if (method instanceof MethodDecl) {
			if (method.params.size != sel.args.size) {
				error("Invalid number of arguments: expected " + method.params.size + " but was " + sel.args.size,
					MiniJavaPackage.eINSTANCE.getMemberSelection_Member, INVALID_ARGS)
			}
		}
	}
	/*
	 * check if method ends with a Return statement
	 * 
	 */
	@Check def void checkMethodEndsWithReturn(MethodDecl method) {
		if (method.returnStatement === null) {
			error("Method must end with a return statement",
				MiniJavaPackage.eINSTANCE.getMethodDecl_Body,
				MISSING_FINAL_RETURN
			)
		}
	}
	/*
	 * Check Duplicate Elements
	 * 
	 */
	@Check def void checkNoDuplicateClasses(Goal p) {
		checkNoDuplicateElements(p.classes, "class")
	}

	@Check def void checkNoDuplicateMembers(ClassDecl c) {
		checkNoDuplicateElements(c.fields, "field")
		checkNoDuplicateElements(c.methods, "method")
	}

	@Check def void checkNoDuplicateSymbols(MethodDecl m) {
		checkNoDuplicateElements(m.params, "parameter")
		checkNoDuplicateElements(m.body.getAllContentsOfType(VarDecl), "variable")
	}
	/*
	 * Check Member Accessibility
	 * 
	 */
	@Check def void checkAccessibility(MemberSelection sel) {
		val member = sel.member
		if (member.name !== null && !member.isAccessibleFrom(sel))
			error(
				('''The '''+ member.access + ''' member ''' +member.name + ''' is not accessible here'''),
				MiniJavaPackage.eINSTANCE.getMemberSelection_Member,
				MEMBER_NOT_ACCESSIBLE
			)
	}
	
	/*
	 * check wrong array element access 
	 * 
	 */
	@Check def checkSquareBracketsExpression(Expression e) {
		 if(e instanceof SquareBrackets){
		 	val leftType = e.left.typeFor
		 	if(leftType instanceof CommonType){
		 		if(leftType.arrays.length == 0){
			 		error('''Can not use '[]' on an unarray type variable''',
						MiniJavaPackage.eINSTANCE.getSquareBrackets_Left,
						WRONG_ARRAY_REF
					)
		 		}
		 	}
		 }
	}
	/*
	 *  Super can be used only as MemberSelection  
	 */
	 @Check
	def void checkSuper(Super s) {
		if (s.eContainingFeature != MiniJavaPackage.eINSTANCE.getMemberSelection_Receiver)
			error("'super' can be used only as member selection receiver", null, WRONG_SUPER_USAGE)
	}
	/*
	 * Check Wrong Method Override
	 * 
	 */
	 def private paramElementsEquals(MethodDecl m1, MethodDecl m2){
	 	val pl1 = m1.params
	 	val pl2 = m2.params
	 	if(pl1.length !== pl2.length)
	 		return false
	 	for(i:0..<pl1.length){
	 		if( !pl1.get(i).type.conformEquals(pl2.get(i).type) )
	 			return false
	 	}
	 	return true
	 }
	 /*
	 * Check Wrong Method Override
	 * 
	 */
	 @Check def void checkMethodOverride(ClassDecl c) {
		val hierarchyMethods = c.classHierarchyMethods

		for (m : c.methods) {
			val overridden = hierarchyMethods.get(m.name)
			if (overridden !== null && 
			// Return Type not Equal and Parameter List Must be Same
				( !m.type.isConformant(overridden.type) || 
				  !m.paramElementsEquals(overridden) 
				)) {
				error("The method '" + m.name + "' must override a superclass method",
					m, MiniJavaPackage.eINSTANCE.getMJNamedElement_Name,
					WRONG_METHOD_OVERRIDE)
			} 
			// overridden method's accessibility must > this method's   
			else if (m.access < overridden.access) {
				error("Cannot reduce access from " + overridden.access +
					" to " + m.access,
					m, MiniJavaPackage.eINSTANCE.getMemberDecl_Access,
					REDUCED_ACCESSIBILITY)
			}
		}
	}
	/*
	 * 
	 * 
	 */
	@Check(CheckType.NORMAL)
	def checkDuplicateClassesInFiles(Goal p) {
		val externalClasses = p.getVisibleExternalClassesDescriptions
		for (c : p.classes) {
			val className = c.fullyQualifiedName
			if (externalClasses.containsKey(className)) {
				error("The type " + c.name + " is already defined",
					c,
					MiniJavaPackage.eINSTANCE.getMJNamedElement_Name,
					DUPLICATE_CLASS,
					c.name)
			}
		}
	}
	 
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
	
	def private void checkNoDuplicateElements(Iterable<? extends MJNamedElement> elements, String desc) {
		val multiMap = HashMultimap.create()

		for (e : elements)
			multiMap.put(e.name, e)

		for (entry : multiMap.asMap.entrySet) {
			val duplicates = entry.value
			if (duplicates.size > 1) {
				for (d : duplicates)
					error(
						"Duplicate " + desc + " '" + d.name + "'",
						d,
						MiniJavaPackage.eINSTANCE.MJNamedElement_Name, 
						DUPLICATE_ELEMENT,
						d.name)
			}
		}
	}
}