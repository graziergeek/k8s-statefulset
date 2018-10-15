package grails.rest

import grails.boot.GrailsApp
import grails.boot.config.GrailsAutoConfiguration
import grails.util.*

class Application extends GrailsAutoConfiguration {
    static void main(String[] args) {
        GrailsApp.run(Application, args)
//        new StartupGrailsApp(Application).run(Application, args)
    }
}

//@InheritConstructors
//class StartupGrailsApp extends GrailsApp {
//    @Override

//    protected void logStartupInfo(boolean isRoot) {
//        // Show default info.
//        super.logStartupInfo(isRoot)
//
//        // And add some extra logging information.
//        // We use the same logger if we get the
//        // applicationLog property.
//        if (applicationLog.debugEnabled) {
//            final metaInfo = Metadata.getCurrent()
//            final String grailsVersion = GrailsUtil.grailsVersion
//            applicationLog.debug "Running with Grails v${grailsVersion}"
//
//            final sysprops = System.properties
//            applicationLog.debug "Running on ${sysprops.'os.name'} v${sysprops.'os.version'}"
//        }
//    }
//}
