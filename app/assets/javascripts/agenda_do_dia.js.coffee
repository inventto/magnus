pi = Math.PI
TAU = 2 * pi
cos = Math.cos
sin = Math.sin
$(document).ready ->
  for tag_professor in $(".professor-cor")
    size = 20
    professor = $(tag_professor)
    cor = "##{professor.attr("cor")}"
    canvas = document.createElement "canvas"
    canvas.width = size
    canvas.height = size
    radius = Math.min(size, size) * 0.5
    canvas.style.float = "left"
    canvas.style.margin = "2px"
    canvas.title = professor.attr("title")
    context = canvas.getContext("2d")
    context.font = "bold 12pt Courier"
    context.beginPath()
    context.arc(size / 2, size / 2, size / 2, 0, TAU, true)
    context.fillStyle = cor
    context.fill()
    context.closePath()
    context.beginPath()
    context.fillStyle = "#fff"
    nome = $(professor).attr("title")
    primeiraLetra = nome.substring(0,1)
    context.fill()
    context.fillText(primeiraLetra, 5,14)
    context.closePath()

    professor.replaceWith(canvas)
