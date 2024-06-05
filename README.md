### README.md

# kubernetes_boilerplate

Este projeto demonstra como criar um cluster Kubernetes utilizando Terraform para provisionamento de infraestrutura e Ansible para configurar os nós do cluster. O cluster é composto por um nó mestre e múltiplos nós de trabalho (workers).

## Visão Geral

Este repositório contém a infraestrutura necessária para provisionar e configurar um cluster Kubernetes utilizando:

- **Terraform**: Para provisionamento da infraestrutura em um provedor de cloud (AWS).
- **Ansible**: Para configurar e instalar o Kubernetes nos nós provisionados.

## Recursos Interessantes

Com esse projeto podemos ver muitas práticas interessantes como:
- Redes Privadas e Públicas
- Conceito de Bastion Host para acessar os workers
- Utilização do `for_each` do Terraform para criar várias máquinas
- Modularização no Terraform
- Roles reutilizáveis no Ansible

## Estrutura do Projeto

```
kubernetes
├── ansible
│   ├── setup_kubernetes_master.yml
│   ├── setup_kubernets_workers.yml
│   ├── roles
│   │   ├── docker
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   ├── kubernetes
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   └── setup
│   │       ├── tasks
│   │       │   └── main.yml
│   └── inventory
│       └── hosts
├── terraform
│   ├── environments
│   │   ├── dev
│   │   │   ├── main.yml
│   │   │   └── destroy_instances.sh
│   ├── modules
│   │   ├── ec2
│   │   │   ├── main.yml
│   │   │   ├── outputs.yml
│   │   │   └── variables.yml
│   │   ├── vpc
│   │   │   ├── main.yml
│   │   │   ├── outputs.yml
│   │   │   └── variables.yml
│   ├── providers.tf
└── README.md
```

## Diagrama AWS
![Diagrama](https://raw.githubusercontent.com/DanielTezolin/kubernetes_boilerplate/8465a2cde45b6e42aa0fe0887172ae361ddc16f4/terraform/modules/diagrama.svg)

## Pré-requisitos

- **Terraform** v1.0+
- **Ansible** v2.9+
- Credenciais do provedor de Cloud (AWS)
- Chave SSH configurada para acesso às instâncias
- Imagem do sistema operacional Ubuntu

## Passo a Passo

### 1. Provisionando a Infraestrutura com Terraform

1. Configure as variáveis de ambiente AWS:
    ```bash
    export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
    ```

2. Configure o ambiente terraform no arquivo `main.tf` dentro da pasta `environments/dev`.

3. Inicialize e aplique o Terraform:
    ```bash
    cd terraform/environments/dev
    terraform init
    terraform apply -auto-approve
    ```


4. Anote os IPs das instâncias provisionadas exibidos ao final do processo do Terraform.

### 2. Configurando o Cluster com Ansible

1. Atualize o arquivo de inventário `ansible/inventory/hosts` com os IPs das instâncias provisionadas:
    ```ini
    [control_plane]
    <control_public_ip>

    [worker]
    <worker1_private_ip>
    <worker2_private_ip>

    [all:vars]
    ansible_ssh_private_key_file='/ssh/key/path/host.key'
    ansible_user=admin
    
    [workers_k8s:vars]
    ansible_ssh_common_args='-o ProxyCommand="ssh admin@<control_public_ip> -i /ssh/key/path/host.key -W %h:%p"'
    ```

2. Execute o playbook do nó mestre:
    ```bash
    cd ansible
    ansible-playbook -i inventory/hosts setup_kubernetes_master.yml
    ```
    Ao fim, você verá um arquivo `kubeadm_join_command.txt` na raiz junto com o playbook. Não apague, pois o comando para ingressar no cluster está nele.

3. Execute o playbook dos workers:
    ```bash
    ansible-playbook -i inventory/hosts setup_kubernetes_workers.yml
    ```

## Verificação

1. Verifique se os nós estão corretamente adicionados ao cluster:
    ```bash
    kubectl get nodes
    ```

Você deverá ver todos os nós listados com o status `Ready`.

## Limpeza

Para destruir a infraestrutura provisionada, execute:
```bash
cd terraform/environments/dev
terraform destroy
```

Caso esteja testando e precise destruir apenas as instâncias EC2, há um script auxiliar que lista todas as instâncias e dá a opção de destruir apenas uma ou todas.
```bash
cd terraform/environments/dev
./destroy_instances.sh
```

## Contribuição

Sinta-se à vontade para contribuir com este projeto. Crie um fork, adicione suas melhorias e abra um pull request.
