-- DynamicCam > Situacoes > "Conjurando (fora de combate)" > Controles de Situacao > Script de Saida
-- Para o tremor: invalida a sequencia em andamento. O micro-giro que ja
-- estava rodando termina sozinho (dura ~0,05 s) e nao chama o proximo.

this.tremor = (this.tremor or 0) + 1
