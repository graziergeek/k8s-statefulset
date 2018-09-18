package grails.rest


import grails.rest.*
import grails.converters.*

class BoardController extends RestfulController {
    static responseFormats = ['json', 'xml']
    BoardController() {
        super(Board)
    }
}
