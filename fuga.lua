-- title:  Fuga das Sombras
-- author: Jeferson Silva
-- desc:   Rpg de acao 2d
-- script: lua
Estados = {
	PARADO = "PARADO",
	PERSEGUINDO = "PERSEGUINDO"
}

Constantes = {
	
	VISAO_DO_INIMIGO = 48,
	TEMPO_PARA_MUDAR_A_TELA = 45,

	Direcao = {
		CIMA = 1,
		BAIXO = 2,
		ESQUERDA = 3,
		DIREITA = 4
	},

	LARGURA_DA_TELA = 240,
	ALTURA_DA_TELA = 138,
	VELOCIDADE_ANIMACAO_JOGADOR = 0.1,
	SPRITE_CHAVE = 364,
	SPRITE_PORTA = 366,
	SPRITE_INIMIGO = 292,
	SPRITE_ESPADA = 328,
	SPRITE_SAIDA = 32,
	
	SPRITE_TITULO = 352,
	SPRITE_ALURA = 416,
	
	SPRITE_TITULO_LARGURA = 12,
	SPRITE_TITULO_ALTURA = 4,
	SPRITE_ALURA_LARGURA = 7,
	SPRITE_ALURA_ALTURA = 3,
	
	ID_SFX_CHAVE = 0,
	ID_SFX_PORTA = 1,
	ID_SFX_INICIO = 2,
	ID_SFX_ESPADA = 3,
	ID_SFX_FINAL = 4,
	INIMIGO = "INIMIGO",
	JOGADOR = "JOGADOR",
	ESPADA = "ESPADA"
}

objetos = {}

function temColisaoComMapa(ponto)
		local blocoX = ponto.x/8
		local blocoY = ponto.y/8
		local blocoId = mget(blocoX, blocoY)
		
		if blocoId >= 128 then
			return true
		end
		return false
end

function tentaMoverPara(personagem, delta, direcao)

			local novaPosicao = {
					x = personagem.x + delta.deltaX,
					y = personagem.y + delta.deltaY
			}

		 if verificaColisaoComObjetos(personagem,novaPosicao) then
				return
			end
			
			local	superiorEsquerdo = {
				x = personagem.x - 8 + delta.deltaX,
				y = personagem.y - 8 + delta.deltaY
			}
			local	superiorDireito = {
				x = personagem.x + 7 + delta.deltaX,
				y = personagem.y - 8 + delta.deltaY
			}
			local inferiorDireito = {
			 x = personagem.x + 7 + delta.deltaX,
				y = personagem.y + 7 + delta.deltaY
			}
			local inferiorEsquerdo = {
			 x = personagem.x - 8 + delta.deltaX,
				y = personagem.y + 7 + delta.deltaY
			}
			
			if not(temColisaoComMapa(superiorEsquerdo) or
			   temColisaoComMapa(superiorDireito) or
						temColisaoComMapa(inferiorEsquerdo) or
						temColisaoComMapa(inferiorDireito)) then 
				personagem.quadroDeAnimacao = personagem.quadroDeAnimacao + Constantes.VELOCIDADE_ANIMACAO_JOGADOR
				if personagem.quadroDeAnimacao >= 3 then
					personagem.quadroDeAnimacao = 1
				end
				personagem.x = personagem.x + delta.deltaX
			 personagem.y = personagem.y + delta.deltaY
				personagem.direcao = direcao
			end		
end

function distancia(inimigo, jogador)
	local distanciaX = inimigo.x - jogador.x
	local distanciaY = inimigo.y - jogador.y
	local distancia = distanciaX * distanciaX + distanciaY * distanciaY
	return math.sqrt(distancia)
end

function atualizaInimigo(inimigo)
			
	if distancia(inimigo, jogador) < Constantes.VISAO_DO_INIMIGO then
			inimigo.estado = Estados.PERSEGUINDO
	else
			inimigo.estado = Estados.PARADO
	end
	
	if inimigo.estado == Estados.PERSEGUINDO then

	
		local delta = {
			deltaY = 0,
			deltaX = 0
		}
		if jogador.y > inimigo.y then
			delta.deltaY = 1
			inimigo.direcao = Constantes.Direcao.BAIXO
		elseif jogador.y < inimigo.y then
		 	delta.deltaY = -1
			inimigo.direcao = Constantes.Direcao.CIMA
		end
		tentaMoverPara(inimigo, delta, inimigo.direcao)
	
		delta = {
			deltaY = 0,
			deltaX = 0
		}
			
		if jogador.x > inimigo.x then
			delta.deltaX = 1
			inimigo.direcao = Constantes.Direcao.DIREITA
		elseif jogador.x < inimigo.x then
			delta.deltaX = -1
			inimigo.direcao = Constantes.Direcao.ESQUERDA
		end
		
		tentaMoverPara(inimigo, delta, inimigo.direcao)
		
		local AnimacaoInimigo = {
			{288, 290},
			{292, 294},
			{296, 298},
			{300, 302}
		}
		
		local quadros = AnimacaoInimigo[inimigo.direcao]
		local quadro = math.floor(inimigo.quadroDeAnimacao) 
		inimigo.sprite = quadros[quadro]
	end
	
end

function atualizaEspada()
	
	local DadosDaEspada = {
		{x = 0, y = -16, sprite = 324},
		{x = 0, y = 16, sprite = 332},
		{x = -16, y = 0, sprite = 320},
		{x = 16, y = 0, sprite = 328}
	}
	
	if jogador.direcao then
		local direcao = DadosDaEspada[jogador.direcao]
		jogador.espada.x = jogador.x + direcao.x
		jogador.espada.y = jogador.y + direcao.y
		jogador.espada.sprite = direcao.sprite	
	end
	
	if btn(4) and jogador.direcao then
			local direcao = DadosDaEspada[jogador.direcao]
			jogador.espada.visivel = true
			jogador.espada.sprite = direcao.sprite
			jogador.espada.tempoParaDesaparecer = 15	
			
			sfx(
				Constantes.ID_SFX_ESPADA,
				86,
				15,
				0,
				8,
				2)
	end
	
	if jogador.espada.visivel == true then
		verificaColisaoComObjetos(jogador.espada, jogador.espada)
		jogador.espada.tempoParaDesaparecer = jogador.espada.tempoParaDesaparecer -1
		if jogador.espada.tempoParaDesaparecer <= 0 then
			jogador.espada.visivel = false
		end
	end
end

function atualizaOJogo()

		local DirecaoDoJogador = {
		 {deltaX = 0, deltaY = -1},
			{deltaX = 0, deltaY = 1},
			{deltaX = -1, deltaY = 0},
			{deltaX = 1, deltaY = 0}
		}
		

		local AnimacaoJogador = {
				{256, 258}, 
				{260, 262}, 
				{264, 266}, 
				{268, 270}
		}
		
		for tecla = 0,3 do
			if btn(tecla) then
				local direcao = tecla + 1
				local quadros = AnimacaoJogador[direcao]
				local quadro = math.floor(jogador.quadroDeAnimacao) 
				jogador.sprite = quadros[quadro]
				
				tentaMoverPara(jogador, DirecaoDoJogador[direcao], direcao)
			end
		end
		
		atualizaEspada()
		
		verificaColisaoComObjetos(jogador, {x = jogador.x, y = jogador.y})
		
		for indice,objeto in pairs(objetos) do
			if objeto.tipo == Constantes.INIMIGO then
				atualizaInimigo(objeto)
			end
		end
		
		camera.x = (jogador.x // 240) * 240
		camera.y = (jogador.y // 136) * 136
		
end

function desenhaMapa()
	
	local blocoX = camera.x / 8
	local blocoY = camera.y / 8
	map(blocoX, -- posicao x no mapa
					blocoY, -- posicao y no mapa
					Constantes.LARGURA_DA_TELA, -- quanto desenhar x
					Constantes.ALTURA_DA_TELA, -- quanto desenhar y
					0, -- em qual ponto colocar o x
					0) -- em qual ponto colocar o y 		
end

function desenhaJogador()
		spr(jogador.sprite, 
						jogador.x-8 - camera.x, 
						jogador.y-8 - camera.y, 
						jogador.corDeFundo,
						1, -- escala 
						0, -- espelhar
						0, -- rotacionar
						2, -- quantos blocos para direita
						2) -- quantos blocos para baixo
		
end

function desenhaObjetos()
	for indice,objeto in pairs(objetos) do
		if objeto.visivel then
			spr(objeto.sprite,
							objeto.x - 8 - camera.x,
							objeto.y - 8 - camera.y,
							objeto.corDeFundo,
							1,
							0,
							0,
							2,
							2)
		end
	end
end

function desenhaOJogo()
	cls()
	desenhaMapa()
	desenhaObjetos()
	desenhaJogador()
end

function fazColisaoDoJogadorComAChave(indice)
	table.remove(objetos, indice)
	jogador.chaves = jogador.chaves +1
	
	sfx(Constantes.ID_SFX_CHAVE,
					60,
					32,
					0,
					8,
					1) 
	
	return false
end

function temColisao(objetoA, objetoB)

 local esquerdaDeB = objetoB.x - 8
 local direitaDeB = objetoB.x + 7
 local baixoDeB = objetoB.y + 7
 local cimaDeB = objetoB.y - 8

 local direitaDeA = objetoA.x + 7
 local esquerdaDeA = objetoA.x - 8
 local baixoDeA = objetoA.y +7
 local cimaDeA = objetoA.y - 8

 if esquerdaDeB > direitaDeA or
  direitaDeB < esquerdaDeA or
  baixoDeA < cimaDeB or
  cimaDeA > baixoDeB then
  return false
 end
 return true
end

function fazColisaoDoJogadorComAPorta(indice)
	if jogador.chaves > 0 then
		jogador.chaves = jogador.chaves - 1
		table.remove(objetos, indice)
		sfx(Constantes.ID_SFX_PORTA,
						36,
						32,
						0,
						8,
						1)
		return false	
	end
	return true
end

function fazColisaoDoJogadorComOInimigo(indice)
	inicializaAsVariaveis()
	tela = Tela.INICIO
	return true
end

function verificaColisaoComObjetos(personagem, novaPosicao)
 
	for indice, objeto in pairs(objetos) do
  if temColisao(novaPosicao, objeto) then
			local funcaoDeColisao = objeto.colisoes[personagem.tipo]
			return funcaoDeColisao(indice)
  end
 end
	return false
end

function desenhaATelaDeTitulo()
	cls()
		spr(Constantes.SPRITE_TITULO,
						80,
						12,
						0,
						1,
						0,
						0,
						Constantes.SPRITE_TITULO_LARGURA,
						Constantes.SPRITE_TITULO_ALTURA)
						
		spr(Constantes.SPRITE_ALURA,
						94,
						92,
						0,
						1,
						0,
						0,
						Constantes.SPRITE_ALURA_LARGURA,
						Constantes.SPRITE_ALURA_ALTURA)
		
		print("www.alura.com.br", 78, 122, 15)	
end

function atualizaATelaDeTitulo()
	if btn(4) then
		sfx(Constantes.ID_SFX_INICIO,
						72,
						32,
						0,
						8,
						0
		)
	 mudaParaTela(Tela.JOGO)
	end
end

function TIC()
		if proximaTela then
			if tempoParaMudarATela > 0 then
				tempoParaMudarATela = tempoParaMudarATela - 1
			end
			if tempoParaMudarATela == 0 then
				tela = proximaTela
				proximaTela = nil
			end
		else 
			tela.atualiza()	
		end
		
		tela.desenha()
end

function deixaPassar(indice)
	return false
end

function criaChave(coluna, linha)
	local chave = {
		sprite = Constantes.SPRITE_CHAVE,
		x = coluna * 8 + 8,
		y = linha * 8 + 8,
		corDeFundo = 6,
		visivel = true,
		colisoes = {
			INIMIGO = deixaPassar,
			JOGADOR = fazColisaoDoJogadorComAChave,
			ESPADA = deixaPassar
		}
	}
	return chave
end

function fazColisaoDoInimigoComAPorta(indice)
	return true
end

function criaPorta(coluna, linha)
	local porta = {
		sprite = Constantes.SPRITE_PORTA,
		x = coluna * 8 +8,
		y = linha * 8 + 8,
		corDeFundo = 6,
		visivel = true,
		colisoes = {
			INIMIGO = fazColisaoDoInimigoComAPorta, 
			JOGADOR = fazColisaoDoJogadorComAPorta,
			ESPADA = deixaPassar
		}
	}
	return porta
end

function fazColisaoDaEspadaComOInimigo(indice)
 table.remove(objetos, indice)
 return false
end

function criaInimigo(coluna, linha)
	local inimigo = {
		tipo = Constantes.INIMIGO,
		estado = Estados.PARADO,
		sprite = Constantes.SPRITE_INIMIGO,
		x = coluna * 8 + 8,
		y = linha * 8 + 8,
		corDeFundo = 14,
		quadroDeAnimacao = 1,
		visivel = true,
		colisoes = {
			INIMIGO = deixaPassar, 
			JOGADOR = fazColisaoDoJogadorComOInimigo,
			ESPADA = fazColisaoDaEspadaComOInimigo
		}
	}
	
	return inimigo
end

function mudaParaTela(novaTela)
	tempoParaMudarATela = Constantes.TEMPO_PARA_MUDAR_A_TELA
	proximaTela = novaTela
end

function atualizaFinal()
	if btn(4) then
		inicializaAsVariaveis()
		mudaParaTela(Tela.INICIO)
	end
end
function desenhaOFinal()
	cls()
	
	print("Voce conseguiu escapar", 56, 40)
	print("Pressione Z para reiniciar", 48, 86)
end

Tela = {
	INICIO = {
		atualiza = atualizaATelaDeTitulo,
		desenha = desenhaATelaDeTitulo
	},
	JOGO = {
		atualiza = atualizaOJogo,
		desenha = desenhaOJogo
	},
	FINAL = {
		atualiza = atualizaFinal,
		desenha = desenhaOFinal
	}
}

function chegaNoFinal()
	sfx(Constantes.ID_SFX_FINAL,
					36,
					32,
					0,
					8,
					0)
	
	mudaParaTela(Tela.FINAL)	
end

function inicializaAsVariaveis()

	objetos = {}
	
	local	chave = criaChave(3,3)
	table.insert(objetos, chave)
	
	local chave2 = criaChave(23,25)
	table.insert(objetos, chave2)
	
	local porta = criaPorta(17,7)
	table.insert(objetos, porta)
	
	local porta2 = criaPorta(48,13)
	table.insert(objetos, porta2)
	
	table.insert(objetos, criaInimigo(20,13))
	table.insert(objetos, criaInimigo(44,8))
	table.insert(objetos, criaInimigo(11,21))
	table.insert(objetos, criaInimigo(5,2))
	table.insert(objetos, criaInimigo(2,13))
	table.insert(objetos, criaInimigo(26,7))
	
	local espada = {
		
		tipo = Constantes.ESPADA,
		x = 0 + 8,
		y = 0 + 8,
		corDeFundo = 0, 
		visivel = false,
		tempoParaDesaparecer = 0,
		colisoes = {
			INIMIGO = deixaPassar,
			JOGADOR = deixaPassar,
			ESPADA = deixaPassar,
		}
	}
	table.insert(objetos, espada)

	jogador = {
		tipo = Constantes.JOGADOR,
		sprite = 260, -- sprite do jogador
		x = 13 * 8 + 8, -- posicao x
		y = 1 * 8 + 8, -- posicao y
		corDeFundo = 6,
		quadroDeAnimacao = 1,
		chaves = 0,
		espada = espada
	} 
	
	local posicaoDaSaida = {
		sprite = Constantes.SPRITE_SAIDA,
		x = 55 * 8 + 8, 
		y = 7 * 8 + 8,
		corDeFundo = 1,
		visivel = true,
		colisoes = {
		 INIMIGO = deixaPassar,
			JOGADOR = chegaNoFinal,
			ESPADA = deixaPassar
		}
	}
	table.insert(objetos, posicaoDaSaida)
	
	camera = {
		x = 0,
		y = 0
	}

	
end

tela = Tela.INICIO
inicializaAsVariaveis()