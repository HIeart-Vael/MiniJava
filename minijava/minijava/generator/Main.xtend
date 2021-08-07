/*
 * generated by Xtext 2.10.0
 */
package org.xtext.projects.minijava.generator

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.xtext.generator.GeneratorDelegate
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.xtext.projects.minijava.MiniJavaLib
import org.xtext.projects.minijava.MiniJavaStandaloneSetup

class Main {

	def static main(String[] args) {
		if (args.empty) {
			System::err.println('Aborting: no path to EMF resource provided!')
			return
		}
		val injector = new MiniJavaStandaloneSetup().createInjectorAndDoEMFRegistration
		val main = injector.getInstance(Main)
		main.runGenerator(args)
	}

	@Inject Provider<ResourceSet> resourceSetProvider

	@Inject IResourceValidator validator

	@Inject GeneratorDelegate generator

	@Inject JavaIoFileSystemAccess fileAccess

	@Inject MiniJavaLib miniJavaLib

	def protected runGenerator(String[] strings) {
		val set = resourceSetProvider.get
		// Configure the generator
		fileAccess.outputPath = 'src-gen/'
		val context = new GeneratorContext => [
			cancelIndicator = CancelIndicator.NullImpl
		]
		// load the library
		miniJavaLib.loadLib(set)
		// load the input files
		strings.forEach[s|set.getResource(URI.createFileURI(s), true)]
		// validate the resources
		var ok = true
		for (resource : set.resources) {
			println("Compiling " + resource.URI + "...")
			val issues = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl)
			if (!issues.isEmpty()) {
				for (issue : issues) {
					System.err.println(issue)
				}
				ok = false
			} else {
				generator.generate(resource, fileAccess, context)
			}
		}
		if (ok)
			System.out.println('Programs well-typed.')
	}
}
