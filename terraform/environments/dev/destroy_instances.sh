#!/bin/bash

instances=$(terraform state list | grep aws_instance)

if [ -z "$instances" ]; then
  echo "Nenhuma instância EC2 gerenciada pelo Terraform encontrada."
  exit 0
fi

echo "Instâncias EC2 gerenciadas pelo Terraform:"
select instance in $instances "Destruir todas"; do
  case $instance in
    "Destruir todas")
      echo "Destruindo todas as instâncias EC2 ..."
      for instance in $instances; do
        echo "Destruindo $instance ..."
        terraform destroy -target=$instance -auto-approve
      done
      break
      ;;
    *)
      if [ -n "$instance" ]; then
        echo "Destruindo $instance ..."
        terraform destroy -target=$instance -auto-approve
      else
        echo "Opção inválida."
      fi
      break
      ;;
  esac
done

echo "Processo de destruição concluído."