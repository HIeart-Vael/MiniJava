package org.xtext.projects.minijava.ui.interpret

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider
import com.google.inject.Inject
import org.xtext.projects.minijava.MiniJavaTypeComputer
import org.xtext.projects.minijava.ExpressionsInterpreter
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.Diagnostician
import org.xtext.projects.minijava.miniJava.Expression
import org.xtext.projects.minijava.miniJava.Type
import org.xtext.projects.minijava.miniJava.CommonType
import org.eclipse.xtext.ui.editor.hover.IEObjectHoverProvider

class ExpressionsEObjectHoverProvider extends DefaultEObjectHoverProvider {
	@Inject extension MiniJavaTypeComputer
	@Inject extension ExpressionsInterpreter
	override getHoverInfoAsHtml(EObject o){
		if(o instanceof Expression && o.programHasNoError){
			val exp = o as Expression
			return '''
			<p>
			type : <b></b>«exp.typeFor.getTypeName»<br>
			value : <b>«exp.interpret.toString»</b>
			</p>	
			'''
		}else
			return super.getHoverInfoAsHtml(o)
	}
	def programHasNoError(EObject o){
		Diagnostician.INSTANCE.validate(o.rootContainer).
			children.empty
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
	
}