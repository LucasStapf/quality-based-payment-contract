# QualityBasedPaymentContract

Este contrato Solidity implementa um sistema de pagamento baseado na qualidade das condições de entrega, utilizado para contratos de transporte onde condições específicas de temperatura e umidade precisam ser mantidas. Penalidades são aplicadas ao fornecedor caso essas condições não sejam cumpridas.

## Funcionalidades

1. **Registro das Condições de Transporte:** Permite registrar leituras de temperatura e umidade durante o transporte.
2. **Verificação de Qualidade:** Define um intervalo de temperatura (2°C a 8°C) e umidade (60% a 80%) aceitáveis.
3. **Cálculo de Penalidade:** Aplica penalidades ao pagamento do fornecedor caso mais de 20% das leituras estejam fora dos limites aceitáveis.
4. **Liberação de Pagamento:** Após a entrega, o pagamento é liberado ao fornecedor com base no cumprimento das condições de transporte registradas.

## Como Funciona

- **Construtor**: O contrato é criado pelo proprietário (`owner`), que especifica o endereço do fornecedor, o valor do pagamento e o prazo de entrega.
- **Registro de Condições**: O proprietário registra as condições de transporte utilizando `registerDeliveryConditions`, fornecendo leituras de temperatura e umidade, além da data da entrega.
- **Verificação de Condições e Penalidade**: A função `calculatePenalty` verifica o número de leituras fora dos limites e aplica uma penalidade de 10% caso as violações superem 20% das leituras.
- **Liberação de Pagamento**: Após a verificação, o pagamento, ajustado com qualquer penalidade, é liberado ao fornecedor.

## Estrutura do Contrato

### Variáveis Principais

- **`owner`**: Proprietário do contrato.
- **`supplier`**: Endereço do fornecedor.
- **`paymentAmount`**: Valor total do pagamento ao fornecedor.
- **`deliveryDeadline`**: Prazo máximo para entrega.
- **Condições de Transporte**:
  - `minTemperature` e `maxTemperature`: Limites de temperatura aceitáveis.
  - `minHumidity` e `maxHumidity`: Limites de umidade aceitáveis.
  - `penaltyRate`: Percentual de penalidade em caso de desvio.

### Eventos

- **`PaymentReleased`**: Emite um evento quando o pagamento é liberado ao fornecedor.
- **`ConditionsRegistered`**: Emite um evento após o registro das condições de transporte.

### Funções

- **Construtor**: Inicializa o contrato com o fornecedor, valor de pagamento e prazo de entrega.
- **`registerDeliveryConditions`**: Registra as leituras de temperatura e umidade.
- **`getTemperatureReadings` e `getHumidityReadings`**: Permitem consultar as leituras de temperatura e umidade.
- **`releasePayment`**: Calcula a penalidade (caso aplicável) e transfere o pagamento final ao fornecedor.
- **`calculatePenalty`**: Calcula a penalidade com base nas leituras fora dos limites aceitáveis.
- **`onlyOwner`**: Modificador que permite o acesso a funções somente pelo proprietário do contrato.

## Exemplo de Uso

1. O contrato é criado pelo proprietário, com detalhes do fornecedor, valor de pagamento e prazo de entrega.
2. O proprietário registra as condições de transporte.
3. Após a verificação das condições, o pagamento é liberado com ou sem penalidade, dependendo da qualidade da entrega.

## Licença

Este código está disponível sob a [The Unlicense License](https://unlicense.org/).
