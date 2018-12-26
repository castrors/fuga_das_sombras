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
	
	SPRITE_TITULO = 352,
	SPRITE_ALURA = 416,
	
	SPRITE_TITULO_LARGURA = 12,
	SPRITE_TITULO_ALTURA = 4,
	SPRITE_ALURA_LARGURA = 7,
	SPRITE_ALURA_ALTURA = 3,
	
	ID_SFX_CHAVE = 0,
	ID_SFX_PORTA = 1,
	ID_SFX_INICIO = 2,
	INIMIGO = "INIMIGO",
	JOGADOR = "JOGADOR"
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
			delta.deltaY = 0.5
			inimigo.direcao = Constantes.Direcao.BAIXO
		elseif jogador.y < inimigo.y then
		 	delta.deltaY = -0.5
			inimigo.direcao = Constantes.Direcao.CIMA
		end
		tentaMoverPara(inimigo, delta)
	
		delta = {
			deltaY = 0,
			deltaX = 0
		}
			
		if jogador.x > inimigo.x then
			delta.deltaX = 0.5
			inimigo.direcao = Constantes.Direcao.DIREITA
		elseif jogador.x < inimigo.x then
			delta.deltaX = -0.5
			inimigo.direcao = Constantes.Direcao.ESQUERDA
		end
		
		tentaMoverPara(inimigo, delta)
		
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
	if jogador.direcao == Constantes.Direcao.DIREITA then
		jogador.espada.visivel = true
		jogador.espada.x = jogador.x + 16
		jogador.espada.y = jogador.y
		jogador.espada.tempoParaDesaparecer = 15
	end
end

function atualizaOJogo()

		local Direcao = {
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
				
				tentaMoverPara(jogador, Direcao[direcao], direcao)
			end
		end
		
		if btn(4) then
			atualizaEspada()			
		end
		jogador.espada.tempoParaDesaparecer = jogador.espada.tempoParaDesaparecer -1
		if jogador.espada.tempoParaDesaparecer <= 0 then
			jogador.espada.visivel = false
		end
		
		
		
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
	print(jogador.x, 0 , 16) 		
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
	desenhaJogador()
	desenhaObjetos()
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
	inicializa()
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
		tela = Tela.JOGO
	end
end

function TIC()
		tela.atualiza()
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
			JOGADOR = fazColisaoDoJogadorComAChave
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
			JOGADOR = fazColisaoDoJogadorComAPorta
		}
	}
	return porta
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
			JOGADOR = fazColisaoDoJogadorComOInimigo
		}
	}
	
	return inimigo
end

Tela = {
	INICIO = {
		atualiza = atualizaATelaDeTitulo,
		desenha = desenhaATelaDeTitulo
	},
	JOGO = {
		atualiza = atualizaOJogo,
		desenha = desenhaOJogo
	}
}

function inicializa()

	objetos = {}
	
	local	chave = criaChave(3,3)
	table.insert(objetos, chave)
	
	local chave2 = criaChave(23,25)
	table.insert(objetos, chave2)
	
	local porta = criaPorta(18,8)
	table.insert(objetos, porta)
	
	local porta2 = criaPorta(54,8)
	table.insert(objetos, porta2)
	
	local inimigo = criaInimigo(21,13)
	table.insert(objetos, inimigo)
	
	local inimigo2 = criaInimigo(44,8)
	table.insert(objetos, inimigo2)
	
	local espada = {
		sprite = Constantes.SPRITE_ESPADA,
		x = 0 + 8,
		y = 0 + 8,
		corDeFundo = 0, 
		visivel = false,
		colisoes = {
			INIMIGO = deixaPassar,
			JOGADOR = deixaPassar
		}
	}
	table.insert(objetos, espada)

	jogador = {
		tipo = Constantes.JOGADOR,
		sprite = 260, -- sprite do jogador
		x = 120, -- posicao x
		y = 68, -- posicao y
		corDeFundo = 6,
		quadroDeAnimacao = 1,
		chaves = 0,
		espada = espada
	} 
	
	tela = Tela.INICIO
	
	camera = {
		x = 0,
		y = 0
	}

	
end

inicializa()