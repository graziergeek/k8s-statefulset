package grails.rest

import grails.databinding.BindingFormat

class Board {

  String title
  String description
  String location
  @BindingFormat('dd/MM/yy HH:mm')
  Date eventDate

    static constraints = {
    }
}
