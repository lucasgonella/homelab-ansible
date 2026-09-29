# Estratégia de Backup e DR do HomeLab

## Estado-alvo

O HomeLab passa a adotar papéis explícitos:

- `pve02` (`192.168.1.18`): hypervisor Proxmox VE principal;
- `pve01` (`192.168.1.11`): rollback temporário após a migração;
- após o fim da janela de rollback, `pve01` será reprovisionado como `pbs01`, servidor físico dedicado de Proxmox Backup Server.

A separação física evita armazenar o backup definitivo no mesmo hypervisor que executa os workloads.

## Workloads protegidos

O job principal deve proteger todos os guests do `pve02`:

- VM 100 — app01
- VM 101 — runner01
- CT 102 — pihole
- CT 103 — myspeed
- CT 104 — monitor01
- CT 105 — ntfy

## Política

A fonte de verdade está em:

`inventory/group_vars/all/backup.yml`

Política inicial:

- backend: Proxmox Backup Server;
- datastore: `homelab`;
- storage ID no PVE: `pbs-homelab`;
- modo: snapshot;
- execução: diariamente às 02:00;
- retenção:
  - últimos 3 snapshots;
  - 7 diários;
  - 4 semanais;
  - 3 mensais;
- novos backups verificados automaticamente;
- verificação completa semanal: domingo às 04:00;
- garbage collection: domingo às 06:00;
- backup da configuração do host: 03:30.

## Segredos

Tokens, senhas, chaves de criptografia e demais segredos do PBS não devem ser versionados.

Quando a integração PBS for automatizada, os segredos devem ficar em Ansible Vault.

## Fases de implantação

### Fase 1 — atual

- `pve02` é o único hypervisor ativo gerenciado pelo grupo `proxmox`;
- `pve01` permanece desligado/intacto como rollback;
- não apagar os guests antigos durante a janela de estabilização;
- backup legado baseado em mount permanece desabilitado.

### Fase 2 — PBS

Após encerrar a janela de rollback:

1. confirmar que todos os guests estão estáveis no `pve02`;
2. destruir somente após aprovação as cópias antigas dos guests em `pve01`;
3. reprovisionar o `pve01` como Proxmox Backup Server;
4. usar o disco de aproximadamente 1 TB como datastore `homelab`;
5. criar usuário/token dedicado de backup;
6. adicionar o PBS ao `pve02` como storage `pbs-homelab`;
7. criar o job diário para todos os guests;
8. executar um backup manual inicial;
9. testar restauração de pelo menos um guest em VMID temporário;
10. habilitar pruning, verificação e garbage collection.

## Critério de conclusão

A estratégia somente será considerada concluída após:

- pelo menos um backup completo de todos os guests;
- verificação sem erros;
- restore de teste validado;
- credenciais fora do Git;
- documentação do procedimento de recuperação.
