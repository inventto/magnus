# Bem vindo

Magnus Controle de Presenças é um aplicativo [Rails][rails] para personal trainers controlarem suas as presenças dos alunos conforme a política da Academia [Magnus Personal Trainers][magnussite]. O sistema também permite o registro de pontos dos funcionários.


Tanto o funcionário registrando o ponto quanto o aluno confirmando sua presença alimentam o mesmo sistema de presenças. A diferença é que as pessoas do tipo Funcionário não participam das políticas dos alunos. Veja mais detalhes [aqui](app/models/pessoa.rb).


## Quais são as regras?

### ![comdireito] Quando posso repor minha aula?

* Não ser feriado
* No mínimo 3 horas

### ![semdireito] O que caracteriza uma falta sem direito a reposição?

* No mínimo 3 horas de antecedência
* Feriados

### ![aulaextra] Aulas extras

Aulas extras tratam-se de alunos que dedicam-se a outras aulas fora de seu tempo contratado.

### ![semjustificativa] Faltas não justificadas

Não permitem ser reposta.

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

### Login

### Relatório de presenças

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

