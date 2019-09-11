// Several of these steps can be taken from samples with minimal change
// prioritize harvesting from there

//The copy WITH InstanceSupplier = msg.sender

pragma solidity ^0.4.25;

contract AllInOnePO3W
{
    enum StateType { Created, Accepted, OutOfStock, PaymentConf, Packed, Shipped, Received, Agreed, Terminated, Resolve } // Need to add back states as we make them
    address public BCOwner;
    address public BCParticipantSupplier;
    address public BCShipper;
    StateType public State;


    uint public PONumber;
    uint public ReferenceNumber;
    string public ShipAddress;

    uint public ItemNumber;
    uint public ItemPrice;
    uint public ItemQuantity;
    uint public OrderTotal;
    string public ItemDescription;
    string public ShipmentTracker;
    string public ShipmentStatus;
    string public Terms;

    address public InstanceOwner;
    address public InstanceSupplier;
    address public InstanceShipper;
    // realizing we need to determine how to handle multi item, etc. Maybe an order object?
    // unit public ItemQuantity^n;

    // Used to fire up a contract. Would like to add a checksupplier function. We cannot currently query outside information, 
    // so, we have to create a seperate inventory tracking contract to store as an 'oracle'.
    // Would ultimately be great if this contract could update the inventory oracle.
    constructor(uint _ponumber, string memory _shipaddress, string memory _itemdescription, uint _itemnumber, uint _itemquantity, string memory _terms) public
    {
        InstanceOwner = msg.sender;
        PONumber = _ponumber;
        ShipAddress = _shipaddress;
        ItemDescription = _itemdescription;
        ItemNumber = _itemnumber;
        ItemQuantity = _itemquantity;
        Terms = _terms;
        State = StateType.Created;

        // Add a way to check another contract that is static for inventory
        // IF the amounts/item number requested are in the other contract
        // push state to Pack
        // Otherwise, send to holding pattern?
    }

    // Used to move state to Terminate, a deadend state.
    function Terminate() public
    {
        State = StateType.Terminated;
    }
	// Used to move to state of out of stock
	function OutOfStockF () public
	{
		State = StateType.OutOfStock;
		return Terminate();
	}
    // Used after creation, the BCParticipant acknoledges and accepts terms. Would like to automate this step by checking during constructor.
    // Used while in the Created state to move to Accepted.
    function InputPrice(uint _itemprice) public
	{
		InstanceSupplier = msg.sender;
		ItemPrice = _itemprice;
		State = StateType.PaymentConf;
	}
	function Accept(uint _referencenumber) public
    {
        InstanceSupplier = msg.sender;
        ReferenceNumber = _referencenumber;
        State = StateType.Accepted;

        // May not need because this step automates if true, and rejects if not.
        // However, this is the step that 'stamps' the supplier
        // So, if this step is skipped, it needs to be embedded in Pack
        // Or have it in both, here first, and pack checks and then stamps
    }

    // Used while in the Accepted state to move to Packed.
    function Pack(uint _itemnumber, uint _itemquantity) public
    {
        if (_itemnumber != ItemNumber) {
            State = StateType.Accepted;
        }
        if (_itemquantity != ItemQuantity) {
            State = StateType.Accepted;
        }
        else {
            State = StateType.Shipped;
        }

        // Maybe during this step the contents is added? And pack checks that 
        // the amounts are the same as agreed
        // Otherwise it falls into a resolution pattern
    }

    // Used while in the Packed state to move to Shipped.
    function Ship(string memory _shipmenttracker) public
    {
        InstanceShipper = msg.sender;
        ShipmentTracker = _shipmenttracker;
        ShipmentStatus = "Shipped";
        State = StateType.Shipped;
    }

    // Used while in the Shipped state, would almost create a second state?
    // Much like the inventory idea, this might not be feasible to automate within contract
    // Would be up to the shipper to push results onto the chain (have to trust they are accurate)
    function UpdateTracking(string memory _shipmentstatus) public
    {
        ShipmentStatus = _shipmentstatus;
    }

    // Used while in the Shipped state to move to Received.
    function Receive() public
    {
        State = StateType.Received;
    }
	// Used to move to created state when owner does to receive order
    function NoReceive() public
    {
        State = StateType.Created;
    }
    // Used while in the Received state to move to Agree. 
    function Agree() public
    {
        State = StateType.Agreed;
    }
	// Used to move to completed state when supplier agrees to amount 
    function Proceed(uint _itemprice, uint _itemquantity) public
    {
		OrderTotal = _itemprice * _itemquantity;
		State = StateType.Packed;
    }
    // Used to modify price after instantiation.
    // Need to determine who can alter this, how to agree on outcome
    //function Modify(uint itemquantity) public
    //{
     //   ItemQuantity = itemquantity;
      //  HolderState = State;
    //}
}
    // function CheckSupplierAvailibility(ItemNumber, ItemQuantity^n) public
    // {
    //     Determine external call function and vulnerability}
    //     Revert if doesn't check out
    //     Move State forward otherwise
    // }

    // function CheckCreditLimits() public
    // {
    //     Yeah, will take a min to figure out
    // }

    // function AutoAdvance(Takes in output from previous two functions) public
    // {
    //     if arguments = true
    //     {
    //         move contract forward to Accept
    //     }
    //     else
    //     {
    //         notify and move to holding pattern
    //     }
    // }

    // function Modify() public
    // [
    //     Allows one/both? users to modify agreements and resets
    //     contracts back to a stable state
    // ]

    // function Accept() public
    // [
    //     Checks that agreement is made either manually or from auto verify
    //     Moves to Pack Step
    // ]

    // function NotifyLogistics() public
    // [
    //     Signals for pickup
    //     Moves to Ship Step
    // ]

    // function Shipped() public
    // [
    //     Pass to BCShipper
    // ]

    // function UpdateShipped() public
    // [
    //     During transite update progress
    // ]

    // function Received() public
    // [
    //     When BCShipper completes their side, BCParticipantSupplier takes ownership
    //     Moves to Receiving Step
    //     Calls Modify2 if the arugments don't match
    //     Otherwise pass to Agreed Step
    // ]

    // funciton Modify2() public
    // // some variant of Modify, could likely fit into the same function already made
    // // maybe depending on which state they current are in, adds what can be modified
    // [
    //     Edit shipment, change in quantity if not all received
    //     Creating the receiving report step
    // ]

    // function Verify2/Accept2() public
    // [
    //     Something to complete final confimations before the invoice is created
    //     Moves state to Received Invoice step
    // ]



//---------------------------------------------
//Automatic rewriting for application 'AllInOnePO3' performed by Azure Workbench AppEnforcer utility
//---------------------------------------------

