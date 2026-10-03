
MacroToolkitDB = {
["char"] = {
["Gurthmorg - Azralon"] = {
["macros"] = {
[122] = {
["icon"] = "607853",
["name"] = " ",
["body"] = "#showtooltip\n/castsequence reset=45 Espiral da Morte, Arremesso de Machado\n",
},
[126] = {
["icon"] = "607853",
["name"] = " ",
["body"] = "#INTERROMPER COM [ Evocar Caçador Vil ]\n#showtooltip\n/stopcasting\n/cast Bloquear Feitiço(Habilidade de Comandar Demônio)\n/cast Devorar Magia(Habilidade Especial)\n",
},
[123] = {
["icon"] = "135230",
["name"] = " ",
["body"] = "#showtooltip\n# DIFERENCIA O ICONE DA PEDRA DE VIDA\n/cast Criar Pedra de Vida\n",
},
[127] = {
["icon"] = "7153694",
["name"] = " ",
["body"] = "#showtooltip\n/castsequence reset=8 Bravura Calcinante, null\n/run C_Timer.After(0.5,function() SpellStopCasting() CastSpellByName(\"Protodraco Renovado\") end)\n",
},
[124] = {
["icon"] = "535592",
["name"] = " ",
["body"] = "#showtooltip\n/stopcasting\n/cast Mão de Gul'dan\n",
},
[128] = {
["icon"] = "237559",
["name"] = " ",
["body"] = "#showtooltip\n/cast [mod:shift] Círculo Demoníaco\n/castsequence [nomod] reset=900 Círculo Demoníaco, Círculo Demoníaco: Teleporte, Círculo Demoníaco: Teleporte, Círculo Demoníaco: Teleporte, Círculo Demoníaco: Teleporte\n",
},
[121] = {
["icon"] = "136138",
["name"] = " ",
["body"] = "#showtooltip\n/castsequence reset=target Maldição da Fraqueza, Seta Sombria, Seta Sombria, Seta Sombria, Seta Sombria, Seta Sombria, Seta Sombria\n",
},
[125] = {
["icon"] = "1378282",
["name"] = " ",
["body"] = "#showtooltip\n/stopcasting\n/cast Evocar Espreitadores do Medo\n",
},
[129] = {
["icon"] = "2032588",
["name"] = "+",
["body"] = "#showtooltip\n/stopcasting\n/cast Seta Demoníaca\n",
},
},
["classFile"] = "WARLOCK",
["backups"] = {
{
["m"] = {
{
["icon"] = 1378282,
["index"] = 121,
["name"] = " ",
["body"] = "#showtooltip\n/stopcasting\n/cast Evocar Espreitadores do Medo\n",
},
{
["icon"] = 607853,
["index"] = 122,
["name"] = " ",
["body"] = "#INTERROMPER COM [ Evocar Caçador Vil ]\n#showtooltip\n/stopcasting\n/cast Bloquear Feitiço(Habilidade de Comandar Demônio)\n/cast Devorar Magia(Habilidade Especial)\n",
},
{
["icon"] = 136197,
["index"] = 123,
["name"] = " ",
["body"] = "#showtooltip\n/petattack\n/cast Seta Sombria\n",
},
{
["icon"] = 607853,
["index"] = 124,
["name"] = " ",
["body"] = "#INTERROMPER COM [ Espiral da Morte ]\n#showtooltip\n/stopcasting\n/cast [@mouseover,harm,nodead][] Espiral da Morte\n/cast Seta Sombria\n",
},
{
["icon"] = 607853,
["index"] = 125,
["name"] = " ",
["body"] = "#INTERROMPER COM PET [ Evocar Guarda Vil ]\n#showtooltip Arremesso de Machado(Habilidade Especial)\n/stopcasting\n/cast [@mouseover,harm,nodead][] Arremesso de Machado(Habilidade Especial)\n",
},
{
["icon"] = 135230,
["index"] = 126,
["name"] = " ",
["body"] = "#showtooltip\n# DIFERENCIA O ICONE DA PEDRA DE VIDA\n/cast Criar Pedra de Vida\n",
},
{
["icon"] = 535592,
["index"] = 127,
["name"] = " ",
["body"] = "#showtooltip\n/stopcasting\n/cast Mão de Gul'dan\n",
},
{
["icon"] = 2032588,
["index"] = 128,
["name"] = "+",
["body"] = "#showtooltip\n/stopcasting\n/cast Seta Demoníaca\n",
},
},
["d"] = "27/09/26 21:38:39",
["n"] = "WOW RETAIL 1",
},
},
["lastbackup"] = "27/09/26 21:38:39",
},
["Guillgalad - Azralon"] = {
["classFile"] = "PALADIN",
},
["Deane - Azralon"] = {
["macros"] = {
[121] = {
["icon"] = "135844",
["name"] = " ",
["body"] = "#showtooltip Lança de Gelo\n/stopcasting\n/cast Lança de Gelo\n",
},
},
["classFile"] = "MAGE",
},
["Kurufinwe - Azralon"] = {
["macros"] = {
[121] = {
["name"] = "Disparo Marcado",
["icon"] = "2058007",
["body"] = "#showtooltip Disparo Farpado\n/castsequence reset=target Marca do Caçador, null\n/cast Disparo Farpado\n",
},
[122] = {
["name"] = "Escapar",
["icon"] = "132294",
["body"] = "#showtooltip Desvencilhar\n/cast Cortar Asas\n/cast Desvencilhar\n",
},
},
["classFile"] = "HUNTER",
},
},
["global"] = {
["backups"] = {
},
["ebackups"] = {
},
},
["profiles"] = {
["profile"] = {
["y"] = 363.1112976074219,
["x"] = 75.6665267944336,
["viscustom"] = false,
["visconditions"] = false,
["width"] = 638.0001220703125,
},
},
}
