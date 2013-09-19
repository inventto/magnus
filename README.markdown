# Bem vindo

Magnus Controle de Presenças é um aplicativo [Rails](https://github.com/rails/rails) para personal trainers controlarem as presenças dos alunos conforme a política da Academia [Magnus Personal Trainers](http://magnus.invent.to/). O sistema também permite o registro de pontos dos funcionários.

Tanto o funcionário registrando o ponto quanto o aluno confirmando sua presença alimentam o mesmo sistema de presenças. A diferença é que as pessoas do tipo Funcionário não participam das políticas dos alunos. Veja mais detalhes [aqui](app/models/pessoa.rb).


## Quais são as regras?

### ![comdireito] Quando posso repor minha aula?

* Não ser feriado
* Avisar falta com no mínimo 3 horas de antecedência

### ![semdireito] O que caracteriza uma falta sem direito a reposição?

* Não avisar que faltou, ou avisar em um prazo menor de 3 horas de antecedência
* Quando dia da aula for feriado

### ![aulaextra] Aulas extras

Essas tratam-se de alunos que dedicam-se a aulas fora de seu tempo contratado.

### ![semjustificativa] Faltas não justificadas

Não permitem reposição da mesma.

## Como instalar?

Para criar o banco de dados inicial digite:

```shell
rake db:setup
```

Para subir o servidor use:

```shell
rails server
```

## Imagens do sistema rodando

![agendadodia]
### Login

O login é feito apartir de um email cadastrado sendo que sempre terá um que será o administrador, onde somente este terá acesso à página de Registros de Ponto.

### Relatório de presenças

Esse é apresentado na página inicial chamada de Agenda do Dia, onde listará todos os alunos que possuem horário de aula no dia, exibindo o horário da aula, o nome do aluno e um ícone representando se o mesmo compareceu à aula.
Também esse relatório é agrupado por horário, como se pode visualizar nas Imagens do sistema rodando.

### Gráficos

![grafico1]
![grafico2]

## Muito obrigado

Estamos muito gratos a [todos os outros projetos](/Gemfile) open source que nos ajudaram a fazer este programa :+1:


[grafico1]:         https://raw.github.com/inventto/magnus/master/printscreens/grafico1.png
[grafico2]:         https://raw.github.com/inventto/magnus/master/printscreens/grafico2.png
[comdireito]:       https://raw.github.com/inventto/magnus/master/app/assets/images/falta_justif_com_direito_a_reposicao.png
[semdireito]:       https://raw.github.com/inventto/magnus/master/app/assets/images/falta_justif_sem_direito_a_reposicao.png
[semjustificativa]: https://raw.github.com/inventto/magnus/master/app/assets/images/falta_justif_sem_direito_a_reposicao.png
[aulaextra]:        https://raw.github.com/inventto/magnus/master/app/assets/images/aula_extra.png
[agendadodia]:      https://raw.github.com/inventto/magnus/master/printscreens/agendadodia.png

