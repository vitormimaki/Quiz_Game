programa
{
	inclua biblioteca Calendario --> tm
	inclua biblioteca Tipos --> tp
	inclua biblioteca Texto --> txt
	inclua biblioteca Util --> u
	inclua biblioteca Arquivos --> doc

	//Opções Menu
	const inteiro INICIAR = 1, PLACAR = 2, SAIR = 3
	inteiro opcao_menu
	
	//Entradas de Placar:
	cadeia nome_player = "", matriz_placar[3][4]
	inteiro acertos = 0, erros = 0, pontuacao = 0

	//Variáveis Globais para Acesso da Matriz, Temas varridos e Apuração de Respostas:

	cadeia tabela[100][7], temas[10], perguntas[100], alternativas[4], feitas_perguntas[100], palpites[100]
	inteiro resp[100], tema_selec, qtdePerguntas = 0, qtdeTemas = 0, qtdePalpites = 0
	
	funcao inicio() {
		gravar_doc()
		importar_temas()
		menu()
	}
	
	funcao gravar_doc() { //Grava o Documento em uma Matriz

		//Caminho pro Arquivo e Variáveis de Matriz
		inteiro refQuiz, linha = 0, coluna = 0, pos = 0
		
		//Variável para Caminho do Arquivo
		refQuiz = doc.abrir_arquivo("./QUIZ.txt", doc.MODO_LEITURA) //Carregar Arquivo da Memória

		//Variável que verifica se Documento Terminou
		logico terminou = doc.fim_arquivo(refQuiz)
		//Variável que armazena linha do documento
		cadeia lerLinha = doc.ler_linha(refQuiz)

		//Tamanho da Linha, Posição do Pipe e Extração de Categoria, respectivamente:
		inteiro tamanho = txt.numero_caracteres(lerLinha)
		inteiro posPipe = txt.posicao_texto(" | ", lerLinha, pos)
		cadeia tblColuna = txt.extrair_subtexto(lerLinha, pos, posPipe)
		
		/*
		 * Colocando o Arquivo em uma Matriz:
		 */
		
		enquanto(nao terminou) { //Checa se atingiu a quantidade de Linhas no Arquivo
			
			para(coluna = 0; coluna <= 6; coluna++) { //Quantidade de Colunas na Matriz
				se(posPipe == -1) { //Se não encontrar o Caractere
					tblColuna = txt.extrair_subtexto(lerLinha, pos, tamanho) //Extrai o resto da linha
					tabela[linha][coluna] = tblColuna //Importa pra Tabela
				} senao {
					tblColuna = txt.extrair_subtexto(lerLinha, pos, posPipe) //Extrai até o Pipe	
					tabela[linha][coluna] = tblColuna //Importa pra Tabela
					pos = posPipe + 3 //Exclue o Pipe da extração e Atualiza a posição de varredura
					posPipe = txt.posicao_texto(" | ", lerLinha, pos) //Procura o próximo Pipe
				}
			}
			linha++ //Quantidade de Linhas na Matriz
			//Atualização de Variáveis e Checagem de fim de Laço:
			lerLinha = doc.ler_linha(refQuiz)
			terminou = doc.fim_arquivo(refQuiz)
			tamanho = txt.numero_caracteres(lerLinha)
			pos = 0
			posPipe = txt.posicao_texto(" | ", lerLinha, pos)
		}
		doc.fechar_arquivo(refQuiz)
	}

	funcao importar_temas() { //Grava um Vetor com todos os Temas
		/*
		 * Criação de vetor com todos os temas:
		 */
		
		logico temaNovo = verdadeiro, terminou = falso
		inteiro linhas = u.numero_linhas(tabela) - 1
		inteiro pos = 0, linha = 0
		cadeia lerLinha
		
		enquanto(nao terminou) {
			se(temaNovo) {
				temas[linha] = tabela[pos][1] //Importa da Matriz
				qtdeTemas++ //Conta qtde de Temas
				temaNovo = falso
			}
			enquanto(nao temaNovo) { //Procura o Próximo Tema Novo
				se(pos < u.numero_linhas(tabela) - 1) {
					pos++
				}
				terminou = tabela[pos][1] == "" ou pos == u.numero_linhas(tabela) - 1 //Confere se a Matriz acabou
				se(nao terminou) {
					lerLinha = tabela[pos][1] //Lê próxima linha da tabela
					temaNovo = temas[linha] != tabela[pos][1] //Confere se o Tema é novo
				} senao {
					temaNovo = verdadeiro
				}
			}
			linha++
		}
	}

	funcao menu() { //Desenha o Menu e Escolhe Opções
		cadeia jogar
		criadores()
		cabecalho("\tMENU", 20, '=')
		escreva(INICIAR, " --> Iniciar\n")
		escreva(PLACAR, " --> Placar\n")
		escreva(SAIR, " --> Sair\n")
		escreva("\nEscolha uma Opção: ")
		faca { //Leia opção válida
			leia(opcao_menu)
			se(opcao_menu < 1 ou opcao_menu > 3) {
				escreva("OPÇÃO ", opcao_menu, " INVÁLIDA!\n")
				escreva("Escolha uma Opção: ")
			}
		} enquanto (opcao_menu < 1 ou opcao_menu > 3)
		escolha(opcao_menu) {
			caso INICIAR: //Jogo
				limpa()
				criadores()
				escreva("Insira seu Nome: ")
				leia(nome_player)
				nome_player = txt.caixa_alta(nome_player)
				limpa()
				criadores()
				jogo()
				pare
			caso PLACAR: //Placar
				limpa()
				criadores()
				placar()
				faca {
					escreva("\nDeseja Retornar?(S/N): ")
					leia(jogar)
				} enquanto (jogar != "S" e jogar != "s")
				limpa()
				menu()
				pare
			caso contrario: //Sair
				limpa()
				criadores()
				escreva("Obrigado por Jogar!\n")
		}
	}

	funcao jogo() { //Jogo Completo
		importa_tema_pergunta()
		sorteia_pergunta()
	}

	funcao importa_tema_pergunta() { //JOGO --> Importa Tema e Perguntas e Selecione-as

		//Variável que verifica se terminou de Ler Temas
		logico terminou = falso
		//Índice do tema
		inteiro indice = 0

		escreva("JOGADOR: --> ",  nome_player, "\n")
		cabecalho("\tTEMAS", 20, '=')
		enquanto(nao terminou) {
			se(nao terminou) { //Escreva A Quantidade de Temas no Arquivo
				escreva("\n", indice+1, " -----> ", temas[indice])
				indice++
			}
			terminou = indice == qtdeTemas //Terminou é verdadeiro se o índice for igual a quantidade de Temas
		}
		escreva("\n\nSelecione um Tema: ")
		inteiro registro = 0
		faca {
			faca {
				leia(tema_selec) //Seleciona Tema válido
				se (tema_selec < 1 ou tema_selec > qtdeTemas) {
					escreva("\nTema Inválido, Selecione novamente: ")
				}
			} enquanto (tema_selec < 1 ou tema_selec > qtdeTemas)
	
			/* Importando Perguntas do Respectivo Tema e Suas Respostas:
			 */
			terminou = falso
			inteiro pos = 0
			registro = 0
			
			enquanto(nao terminou) {
				se(pos < u.numero_linhas(tabela)) { //Se a posição de varredura de linhas é menor que o número de linhas da matriz (100)
					se(temas[tema_selec - 1] == tabela[pos][1]) { //Se o tema Selecionado for respectivo às Perguntas
						perguntas[registro] = tabela[pos][0] //Importa as Perguntas da Matriz para o Vetor
						terminou = perguntas[registro] == "" //Terminou é Verdadeiro se não existe próxima pergunta
						resp[registro] = tp.cadeia_para_inteiro(tabela[pos][2], 10) //Importa respectiva Resposta
						registro++ //Próximo Registro
					}
				} senao { //Se A posição de varredura for maior ou igual à quantidade de linhas da matriz (>= 100)
					terminou = verdadeiro
				}
				se(nao terminou) { //Se não terminou, varra a próxima linha
					pos++
				}
			}
			se(registro < 5) {
				escreva("Tema com perguntas insuficientes, escolha outro tema: ")
			}
		} enquanto (registro < 5)
		
		escreva("\nSelecione a Quantidade de Perguntas: ")

		faca {
			leia(qtdePerguntas)
			se(qtdePerguntas < 5) {
				escreva("\nQuantidade Inválida: Escolha no mínimo 5 perguntas: ")
			} senao {
				se(qtdePerguntas > registro) {
					escreva("\nQuantidade Inválida: Escolha no máximo ", registro, " perguntas: ")
				}
			}
		} enquanto (qtdePerguntas < 5 ou qtdePerguntas > registro)
		
		terminou = falso //Reseta Estado Da Variável Terminou para Eventuais Novas leituras

		limpa()
	}
	
	funcao sorteia_pergunta(){ //JOGO --> Sorteia, Escreve, Seleciona e Confere Perguntas do Respectivo tema Escolhido

		//Variáveis de índice, contagem e número de elementos:
		inteiro pos = 0, registro = 0, conta = 0, elementos = u.numero_elementos(perguntas) - 1
		//Variável para Testar se Existem Elementos Restantes
		logico temElementos = pos < elementos

		//Variável que Conta índice, Resposta e Número de Perguntas Existentes:
		inteiro indice = 0, resposta = 0, conta_perguntas = 0
		//Inicialização da Pergunta Sorteada
		cadeia sorteioPergunta = ""
		//Variáveis Lógicas de fim de Laço
		logico terminou = falso, repetida = falso, acabou = falso

		/* Sorteio Perguntas e Seleção de alternativas
		 * enquanto ainda existem perguntas para serem feitas:
		 */
		 
		faca { //Enquanto Ainda existem Perguntas a serem Feitas
			limpa()
			criadores()
			faca { //Enquanto For Repetida
				se(nao(qtdePerguntas == conta_perguntas)) { //Se a qtde de Perguntas não for igual a Perguntas Sorteadas
					faca {
						indice = u.sorteia(0, elementos - 1)
					} enquanto (indice >= qtdePerguntas) //Sorteia apenas índices válidos de perguntas registradas
	
					sorteioPergunta = perguntas[indice] //Guarda Pergunta Sorteada
	
					para(conta = 0; conta <= conta_perguntas; conta++) {
						repetida = feitas_perguntas[conta] == sorteioPergunta //Testa se a Pergunta Já foi Realizada no Jogo
						feitas_perguntas[conta_perguntas] = sorteioPergunta //Armazena a pergunta No vetor de Perguntas Feitas
						se (repetida) {
							repetida = verdadeiro
							pare
						} senao { //Se não repetiu
							se (conta == conta_perguntas - 1) { //E a contagem chegou ao final das perguntas existentes
								repetida = falso
								pare
							}
						}
					}
				}
			} enquanto (repetida)

			/* Enquanto repetida, sorteia uma pergunta que não esteja vazia
			 * Ela é repetida se já foi gravada em todas as posições de feitas_perguntas
			 * Se não for repetida, grava o sorteio em feitas_perguntas
			 */
			 
			conta_perguntas++ //Próxima Pergunta ao Repetir o Laço
			terminou = falso //Reinicialização da Variável para Repetição do Laço
			pos = 0 //Reinicialização da Variável posição

			//Registra alternativas da respectiva pergunta:
			
			enquanto(nao terminou) {
				registro = 0
				se(sorteioPergunta == tabela[pos][0]) { //Se a Pergunta Sorteada for a Mesma Pergunta Varrida
					para(inteiro alt = 3; alt <= 6; alt++) { //Armazena as Alternativas
						alternativas[registro] = tabela[pos][alt]
						registro++ //Próximo Registro
					}
					resposta = tp.cadeia_para_inteiro(tabela[pos][2], 10) //Converte a Resposta da Respectiva Pergunta para Inteiro
					terminou = verdadeiro
				}
				se(nao terminou) {
					pos++ //Próxima Varredura
				}
			}
			
			//escreve no console:

			escreva("JOGADOR: --> ",  nome_player)
			escreva("\n\nTEMA:\n\n", temas[tema_selec - 1],"\n\nPERGUNTA: ", conta_perguntas,"\n\n",sorteioPergunta,"\n\n")
			escreva("ALTERNATIVAS:\n\n")
			para(pos = 1; pos <= 4; pos++) {
				escreva("Alternativa ", pos, " --> ", alternativas[pos-1], "\n")
			}

			//Lê e determina acerto:
			
			faca { //Testa se a Alternativa é Valida
				escreva("\nInsira a sua Alternativa: ")
				leia(palpites[qtdePalpites]) //Leia o N° Palpite
				se(tp.cadeia_para_inteiro(palpites[qtdePalpites], 10) < 1 ou tp.cadeia_para_inteiro(palpites[qtdePalpites], 10) > 4) {
					escreva("\nAlternativa Inválida!")
				}
			} enquanto (tp.cadeia_para_inteiro(palpites[qtdePalpites], 10) < 1 ou tp.cadeia_para_inteiro(palpites[qtdePalpites], 10) > 4)
			qtdePalpites++
			//Se o Palpite for Igual a respectiva Resposta
			se(tp.cadeia_para_inteiro(palpites[qtdePalpites - 1], 10) == resposta) {
				acertos++ //Soma 1 acerto
				pontuacao = pontuacao + 10 //Adiciona 10 pontos
			} senao {
				erros++ //Soma 1 erro
			}
		} enquanto (conta_perguntas < qtdePerguntas)

		conta = 0
		
		limpa()
		criadores()
		escreva("TEMA: ", temas[tema_selec-1])

		/* Exibe cada pergunta, Alternativa Correta e Selecionada:
		 */

		para(pos = 0; pos < qtdePerguntas; pos++) {
			terminou = falso
			escreva("\nPergunta ", pos + 1, ": ")
			sorteioPergunta = feitas_perguntas[pos]
			escreva(sorteioPergunta)
			escreva("\nAlternativas:\n")
			//Registra alternativas da respectiva pergunta:
			enquanto(nao terminou) {
				registro = 0
				se(sorteioPergunta == tabela[conta][0]) {
					para(inteiro alt = 3; alt <= 6; alt++) {
						alternativas[registro] = tabela[conta][alt]
						registro++
					}
					resposta = tp.cadeia_para_inteiro(tabela[conta][2], 10)
					terminou = verdadeiro
				}
				se(nao terminou) {
					conta++
				}
			}
			para(conta = 0; conta < 4; conta++) { //Escreve Alternativas
				escreva("\n", conta + 1, " --> ", alternativas[conta])
			}
			escreva("\n\nAlternativa Selecionada: ", palpites[pos], "\nAlternativa Correta: ", resposta, "\n")
			conta = 0
		}
	
		escreva("\nAcertos: ", acertos, "\nErros: ", erros, "\nPontuação: ", pontuacao)

		//Registra no Placar:
		cadeia qtde = tp.inteiro_para_cadeia(qtdePerguntas, 10)
		cadeia pontos = tp.inteiro_para_cadeia(pontuacao, 10)
		carregar_placar(nome_player, temas[tema_selec-1], qtde, pontos)

		jogar_novamente()
	}

	funcao reseta_variaveis() { //Reinicia Variáveis Globais para Novo Jogo
		
		acertos = 0
		erros = 0
		pontuacao = 0	
		tema_selec = 0
		qtdePerguntas = 0
		qtdePalpites = 0
		
	}

	funcao jogar_novamente() { //Inicia Novo Jogo
		
		caracter jogar
		
		escreva("\n\nDeseja Jogar Novamente?(S/N): ")
		faca{
			leia(jogar)
		} enquanto (jogar != 'S' e jogar != 's' e jogar != 'N' e jogar != 'n')
		
		escolha(jogar) {
			caso 'S':
			caso 's': //Novo Jogo
				limpa()
				reseta_variaveis()
				jogo()
				pare
			caso contrario: //Menu
				limpa()
				nome_player = ""
				reseta_variaveis()
				menu()
		}
	}

	funcao cabecalho(cadeia principal, inteiro qtd, caracter carac) { //Cria um Cabeçalho
		para(inteiro pos = 0; pos < qtd - 1; pos++) {
			escreva(carac)
		}
		escreva("\n",principal,"\n")
		para(inteiro pos = 0; pos < qtd - 1; pos++) {
			escreva(carac)
		}
		escreva("\n")
	}

	funcao criadores() { //Créditos dos Alunos
		cabecalho("Criadores: Álvaro, Jeferson e Vitor Mimaki", 50, '=')
		data_hora()
	}

	funcao data_hora() { //Extrai Data e Hora do Computador
		inteiro dia = tm.dia_mes_atual()
		inteiro mes = tm.mes_atual()
		inteiro ano = tm.ano_atual()
		inteiro hora = tm.hora_atual(falso)
		inteiro minuto = tm.minuto_atual()
		inteiro segundo = tm.segundo_atual()
		
		escreva("Data de Acesso: ",dia,"/",mes,"/",ano)
		escreva("\nHora de Acesso: ",hora,"h:",minuto,"min:", segundo, "seg\n\n")
	}

	funcao carregar_placar(cadeia nome, cadeia tema, cadeia qtde, cadeia pontos) {

		/* Armazena as Informações durante a Execução do programa
		 * em um Placar
		 */
		inteiro linha = 0, descePlacar = 1
		inteiro tamanho = u.numero_linhas(matriz_placar)
		logico maior = falso
		inteiro pontoFeito = tp.cadeia_para_inteiro(pontos, 10), pontoRegistrado = 0

		para(linha = 0; linha < tamanho; linha++) {
			se(linha > 0) { //Verifica Ordem de Pontuação Caso Já hajam registros anteriores
				pontoRegistrado = tp.cadeia_para_inteiro(matriz_placar[linha-1][3], 10)
				maior = pontoFeito > pontoRegistrado
			}
			se(maior) { //Se a Pontuação é Maior, Registra na Ordem de Pontuação
				faca {
					matriz_placar[linha][0] = matriz_placar[tamanho-descePlacar][0]
					matriz_placar[linha][1] = matriz_placar[tamanho-descePlacar][1]
					matriz_placar[linha][2] = matriz_placar[tamanho-descePlacar][2]
					matriz_placar[linha][3] = matriz_placar[tamanho-descePlacar][3]
					descePlacar++
					//Passa o Registro Anterior para baixo
				} enquanto (descePlacar < tamanho ou matriz_placar[linha][0] == "")
				//Sobrescreve Registros Antigos na Ordem de Pontuação
				matriz_placar[linha-1][0] = nome
				matriz_placar[linha-1][1] = tema
				matriz_placar[linha-1][2] = qtde
				matriz_placar[linha-1][3] = pontos
				pare
			} senao { //Registra Sequencialmente
				se(matriz_placar[linha][0] == "") { //Se estiver vazia
					matriz_placar[linha][0] = nome
					matriz_placar[linha][1] = tema
					matriz_placar[linha][2] = qtde
					matriz_placar[linha][3] = pontos
					pare
				}
			}
		}
	}

	funcao placar() { //Exibe o Placar
		inteiro tamanho = u.numero_linhas(matriz_placar)
		inteiro extensao = u.numero_colunas(matriz_placar)

		escreva("OBS: O Placar se Perderá ao Interromper a Execução do Programa!\n\n")
		
		cabecalho("|\tJogador\t|\tTema\t|  Perguntas  |  Pontuação  |", 62, '=')
		
		para(inteiro linha = 0; linha < tamanho; linha++) {
			para(inteiro coluna = 0; coluna < extensao; coluna++) {
				se(matriz_placar[linha][coluna] == "") {
					pare
				} senao {
					escreva("|\t",matriz_placar[linha][coluna],"\t")
				}
			}
			escreva("\n")
		}
	}
}
/* $$$ Portugol Studio $$$ 
 * 
 * Esta seção do arquivo guarda informações do Portugol Studio.
 * Você pode apagá-la se estiver utilizando outro editor.
 * 
 * @POSICAO-CURSOR = 10503; 
 * @DOBRAMENTO-CODIGO = [21, 27, 73, 105, 149, 154, 370, 381, 405, 416, 421, 433, 475];
 * @PONTOS-DE-PARADA = ;
 * @SIMBOLOS-INSPECIONADOS = {matriz_placar, 14, 26, 13}-{qtdePalpites, 20, 66, 12};
 * @FILTRO-ARVORE-TIPOS-DE-DADO = inteiro, real, logico, cadeia, caracter, vazio;
 * @FILTRO-ARVORE-TIPOS-DE-SIMBOLO = variavel, vetor, matriz, funcao;
 */