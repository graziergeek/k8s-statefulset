package grails.rest

import grails.testing.gorm.DomainUnitTest
import spock.lang.Specification

class BoardSpec extends Specification implements DomainUnitTest<Board> {

    def setup() {
    }

    def cleanup() {
    }

    void "test build"() {
        // TODO: fake test until I can figure out 
        // how to run docker compose as part of the test run.
        expect:"fix me"
            true == true
    }
}
