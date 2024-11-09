// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract QualityBasedPaymentContract {
    address public owner;
    address public supplier;
    uint public paymentAmount;
    bool public paymentReleased = false;
    bool public savedDeliveryConditions = false;
    uint public deliveryDeadline; // Prazo máximo para entrega

    // Condições de transporte
    uint public minTemperature = 2; // Temperatura mínima permitida (em °C)
    uint public maxTemperature = 8; // Temperatura máxima permitida (em °C)
    uint public minHumidity = 60;   // Umidade mínima permitida (%)
    uint public maxHumidity = 80;   // Umidade máxima permitida (%)
    uint public penaltyRate = 10;   // Taxa de penalidade (10% do valor total) em caso de desvio

    // Estrutura para armazenar leituras de condições durante o transporte
    struct DeliveryConditions {
        uint[] temperatureReadings;
        uint[] humidityReadings;
    }

    DeliveryConditions private deliveryConditions;

    event PaymentReleased(uint amount, address to);
    event ConditionsRegistered(uint[] temperatures, uint[] humidities);

    constructor(address _supplier, uint _paymentAmount, uint _deliveryDeadline) payable {
        owner = msg.sender;
        supplier = _supplier;
        paymentAmount = _paymentAmount * 1e18;
        deliveryDeadline = _deliveryDeadline;
    }

    // Função para registrar múltiplas leituras de condições de transporte
    function registerDeliveryConditions(uint[] memory _temperatures, uint[] memory _humidities, uint delivery) public onlyOwner {
        require(!paymentReleased, "O pagamento ja foi liberado.");
        require(!savedDeliveryConditions, "As condicoes ja foram registradas.");
        require(delivery <= deliveryDeadline, "Entrega atrasada. Pagamento bloqueado.");

        // Armazenar as leituras de temperatura e umidade
        deliveryConditions.temperatureReadings = _temperatures;
        deliveryConditions.humidityReadings = _humidities;

        // Salva as condições de entrega
        savedDeliveryConditions= true;
        
        emit ConditionsRegistered(_temperatures, _humidities);
    }

    // Função para obter as leituras de temperatura
    function getTemperatureReadings() public view returns (uint[] memory) {
        return deliveryConditions.temperatureReadings;
    }

    // Função para obter as leituras de umidade
    function getHumidityReadings() public view returns (uint[] memory) {
        return deliveryConditions.humidityReadings;
    }

    // Função para verificar e liberar o pagamento ao fornecedor
    function releasePayment() public onlyOwner payable {
        require(savedDeliveryConditions, "Condicoes de entrega nao foram registradas.");
        require(!paymentReleased, "Pagamento ja liberado.");
        //require(block.timestamp <= deliveryDeadline, "Entrega atrasada. Pagamento bloqueado.");
        
        uint penaltyAmount = calculatePenalty();
        uint finalPayment = paymentAmount > penaltyAmount ? paymentAmount - penaltyAmount : 0;

        paymentReleased = true;
        payable(supplier).transfer(paymentAmount);
        
        emit PaymentReleased(finalPayment, supplier);
    }

    // Função para calcular a penalidade com base nas leituras fora dos limites
    function calculatePenalty() internal view returns (uint) {
        uint penaltyAmount = 0;
        uint violations = 0;

        for (uint i = 0; i < deliveryConditions.temperatureReadings.length; i++) {
            if (deliveryConditions.temperatureReadings[i] > maxTemperature ||
                deliveryConditions.temperatureReadings[i] < minTemperature ||
                deliveryConditions.humidityReadings[i] > maxHumidity ||
                deliveryConditions.humidityReadings[i] < minHumidity) {
                violations++;
            }
        }
        
        // Se houver mais de 20% de leituras fora do limite, aplicar penalidade
        if (violations > (deliveryConditions.temperatureReadings.length * 20) / 100) {
            penaltyAmount = (paymentAmount * penaltyRate) / 100;
        }
        
        return penaltyAmount;
    }

    // Função para permitir que o contrato receba pagamentos
    receive() external payable {}

    // Modificador para permitir apenas que o dono do contrato chame certas funções
    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o dono do contrato pode executar esta funcao.");
        _;
    }
}
