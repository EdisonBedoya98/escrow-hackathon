// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Marketh {

    enum PurchaseState {Pending,PickUp,Delivered,Rejected}

    struct Purchase {
        string id; //purchase identifier
        address payable buyer; //Dirrecion de quien crea o representa el proyecto
        address payable farmer; //Dirrecion de quien crea o representa el proyecto  
        uint priceProduct;    
    }

    Purchase[] public purchases;
    address owner; //Marketh organization wallet

    mapping(string =>PurchaseState) private purchaseStates; 

    constructor () public {  // este es el método constructor donde  inicializo el contrato con un mensaje
       owner = msg.sender;
    }


   function createPurchase(string calldata id, address payable farmer,uint priceProduct) public payable  {
      Purchase memory purchase = Purchase(id,payable(msg.sender),payable(farmer),priceProduct);   

      purchases.push(purchase);
      purchaseStates[purchase.id] = PurchaseState.Pending;
      
      emit PurchaseCreated(id,purchases.length-1);
    }

    modifier isNotRejected(string calldata id){
        require(
           purchaseStates[id] != PurchaseState.Rejected,
            "The project is rejected"
        );
        _;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getCurrentState(string calldata id) public view returns(PurchaseState) {       
        return purchaseStates[id];        
    }

    //Changes of state
    function setStatePickUp(string calldata id,uint indexPurchase) public isNotRejected(id) {       
        purchaseStates[id]=PurchaseState.PickUp;  
        // purchases[indexPurchase].farmer.call{value: 50000, gas: 5000}("");  
        uint productPrice = (purchases[indexPurchase].priceProduct)/2;
        purchases[indexPurchase].farmer.call{value: productPrice, gas: 5000}("");      
        // purchases[indexPurchase].farmer.transfer(address(this).balance); 
        emit StateChanged("State changed to PickUP");   
    }
    function setStateDelivered(string calldata id,uint indexPurchase) public isNotRejected(id) {       
         purchaseStates[id] = PurchaseState.Delivered;
         uint productPrice = (purchases[indexPurchase].priceProduct)/2; 
         purchases[indexPurchase].farmer.call{value: productPrice, gas: 5000}(""); 
         emit StateChanged("State changed to Delivered");     
    }
    function setStateRejected(string calldata id) public {       
         purchaseStates[id] = PurchaseState.Rejected;  
         emit StateChanged("State changed to Rejected");    
    }

    event PurchaseCreated(
        string id,
        uint indexPurchase
    );
    event StateChanged(
        string stateMessage
    );   

}
