# Sessão de Tuning e SRE - Gemini CLI
*Data: 06 de Maio de 2026*

## Resumo do Diálogo

**Usuário:** Pediu uma comparação entre o Copilot CLI e o Gemini CLI.
**Gemini:** Explicou que o Copilot atua como um assistente passivo e "dicionário de shell", enquanto o Gemini é um agente autônomo focado em engenharia (pesquisa, planejamento, execução e validação).

**Usuário:** Mencionou que o Copilot falou sobre MCP e Skills.
**Gemini:** Destacou que o Gemini foi feito para o protocolo MCP, permitindo acesso a ferramentas estruturadas, além de suportar Skills customizadas e Instruções de Projeto (GEMINI.md).

**Usuário:** Decidiu moldar a própria ferramenta e sugeriu instalar o `rhel-lightspeed/linux-mcp-server`.
**Gemini:** Analisou o repositório, viu que é ideal para Fedora e configurou o MCP no `settings.json`, concedendo poderes estruturados de leitura do sistema.

**Usuário:** Pediu um "test drive" de todos os novos comandos.
**Gemini:** Listou o status do sistema, serviços e logs. Identificou um erro no script `gemini-daemon` (erro de número inteiro).

**Usuário:** Pediu para corrigir o erro do daemon.
**Gemini:** Explicou o bug de "locale" (vírgula vs. ponto) no cálculo de CPU/RAM e aplicou um fix usando `sed`.

**Usuário:** Pediu para descobrir a origem do daemon.
**Gemini:** Vasculhou o repositório oficial e não encontrou. Concluiu que era um utilitário local. O usuário confirmou que era um setup antigo de SRE.

**Usuário:** Pediu para atualizar o daemon.
**Gemini:** Reescreveu o script para a v2.0, fazendo com que ele invoque a CLI do Gemini de forma autônoma para realizar diagnósticos via MCP sempre que houver pico de uso.

**Usuário:** Perguntou sobre inicialização no boot.
**Gemini:** Verificou o `systemd`, encontrou o `gemini-daemon.service` e executou o reload para ativar a nova versão. Modificou o script wrapper `gemini` para salvar os relatórios autônomos em `/logs/sre_reports.md`.

**Usuário:** Relatou alto uso de RAM e swap e pediu investigação.
**Gemini:** Usou o MCP e o shell, descobrindo que o Floorp Browser consumia 31% da RAM, sobrecarregando o ZRAM. Sugeriu e executou o encerramento do processo, além de limpar os caches do kernel, liberando 8GB de RAM. Em seguida, limpou o Swapfile.

**Usuário:** Perguntou sobre o ZRAM e o algoritmo ZSTD.
**Gemini:** Explicou o funcionamento das *streams* no ZRAM, detalhando como o Fedora usa os 4 núcleos do sistema para compressão paralela eficiente.

**Usuário:** Solicitou uma análise aprofundada final e otimizações definitivas.
**Gemini:** Fez um raio-x de Storage, Inodes, Rede, Serviços e Kernel. Sugeriu e aplicou o "Combo de Performance":
1. **Rede:** Ativou TCP BBR e FQ.
2. **Memória:** Alterou `swappiness` para 100 e `vfs_cache_pressure` para 50.
3. **Periféricos:** Ajustou teclado (delay 200ms) e mouse (perfil flat).
4. **Visual:** Ativou o escalonamento fracionário nativo no GNOME.

**Usuário:** Pediu para tornar as alterações definitivas.
**Gemini:** Criou os arquivos de configuração permanentes (`/etc/sysctl.d/99-performance.conf` e `/etc/modules-load.d/bbr.conf`).

**Usuário:** Pediu para salvar a conversa.
**Gemini:** Gerou este documento de registro.
