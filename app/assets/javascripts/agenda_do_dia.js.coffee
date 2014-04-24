pi = Math.PI
TAU = 2 * pi
cos = Math.cos
sin = Math.sin
$(document).ready ->
  console.log "professores ::: ", $(".professor-cor").length
  for tag_professor in $(".professor-cor")
    size = 10
    professor = $(tag_professor)
    cor = "##{professor.attr("cor")}"
    canvas = document.createElement "canvas"
    canvas.width = size
    canvas.height = size
    canvas.title = professor.attr("title")
    context = canvas.getContext("2d")
    context.fillStyle = cor
    context.beginPath()
    context.arc(size / 2, size / 2, size / 2, 0, TAU, true)
    context.closePath()
    context.fillText(primeiraLetra, 0,10)
  
    nome = $(professor).attr("title")
    primeiraLetra = nome.substring(0,1)

    image = document.createElement 'img'
    image.src = canvas.toDataURL()
    image.alt = nome
    image.title= nome
    professor.html(canvas)
    
  
