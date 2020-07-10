pragma solidity ^0.4.25;


contract Department{
    address owner;
    //using mapping map or hashmap (key val pair) to track person
    
    mapping(address => Dept_Struct) public department;
    
    struct Dept_Struct{
        uint dept_id;
        string dept_name;
        uint total_balance;
        uint remaining_balance;
    }
    
   
    
    constructor() public{
        owner = msg.sender;
    }
 
    
    
    function addDepartment(address ad, uint _dept_id, string memory _dept_name, uint _total_balance, uint _remaining_balance) public{
        require(msg.sender == owner);
        
        department[ad] = Dept_Struct(_dept_id, _dept_name, _total_balance, _remaining_balance);
        
    }
    
    function paySallary(address _dept, address _emp, uint amount) payable external{
        require(msg.sender == owner);
        department[_dept].total_balance -= amount;
    }
    
}


contract ActiveEmployee{
    address owner;
    
    mapping(address => ActiveEmp) public activeEmp;
    mapping (address => EmployeeAgreement) public empCont;
    
    struct ActiveEmp{
        address ad;
        uint employee_id;
        uint dept_id;
        string name;
        string birth_date;
        uint basic_salary;
        string joining_date;
        string estimated_retire_date;
    }
    
    struct EmployeeAgreement{
        uint working_hour;
        uint monthly_sallery;
        uint yearly_paid_leave;
        uint weekly_workday;
        string designation;
        uint joining_date;
    }
    
    
 

    constructor() public{
        owner = msg.sender;
    }
    
    
    function addActiveEmp(address _ad, uint _employee_id, uint _dept_id,
            string memory _name, string memory _birth_date, 
            uint _basic_salary, string memory _joining_date, 
            string memory _estimated_retire_date
            ) public{
                    
            activeEmp[_ad] = ActiveEmp(_ad, _employee_id, _dept_id, _name, _birth_date, 
                                               _basic_salary,_joining_date, _estimated_retire_date); 
    }
    
    
     function employeeAgreement(address ad, uint _work_hour, uint _salllary, uint _paid_leave, 
        uint _work_day, string memory _designation) public{
         
        require(msg.sender == owner);
        uint join_date = block.timestamp;
        empCont[ad] = EmployeeAgreement(_work_hour, _salllary, _paid_leave, _work_day, _designation,join_date); 
    }
    
    function getEmployeeId(address ad) public returns(uint){
        return activeEmp[ad].employee_id;
    }
    
    function paySallary(address dept_ad, address emp_ad) public{
        
    }
    
   
}





contract RetiredEmploye{
    
    address owner;
    
    mapping(address => EmpRetired) public emp;
    mapping(address => bool) public PensionStatus;

    struct EmpRetired{
        address ad;
        uint employee_id;
        uint dept_id;
        uint total_balance;
        uint remaining_balance;
        bool isforced_retired;
        bool prior_conviction;
        bool loan_organization;
        bool loan_sister_organistion;   
    }
    
    
    constructor() public{
        owner = msg.sender;
    }
    
    function addEmp(address _ad, uint _employee_id, uint _dept_id, uint _total_balance, uint _remaining_balance,
            bool _isforced_retired, bool _prior_conviction, bool _loan_organization, bool _loan_sister_organistion
            ) public{
            emp[ _ad] = EmpRetired(_ad, _employee_id, _dept_id, _total_balance, _remaining_balance, _isforced_retired,
            _prior_conviction, _loan_organization, _loan_sister_organistion);
            
            PensionStatus[_ad] = false;
    }
    
    function getPrioConvictionStatus(address ad) public returns(bool){
        require(msg.sender == owner);
        return emp[ad].prior_conviction;
    }
    
    function getPriorInternalLoanStatus(address ad) public returns(bool){
        require(msg.sender == owner);
        return emp[ad].loan_organization;
    }
    
    function getPriorExternalLoanStatus(address ad) public returns(bool){
        require(msg.sender == owner);
        return emp[ad].loan_sister_organistion;
    }
    
    function getAllStatusClear(address ad) public returns(bool){
        require(msg.sender == owner);
        if(emp[ad].isforced_retired == false && emp[ad].prior_conviction == false){
            return emp[ad].loan_sister_organistion;
        }
    }
    
    function getRetirementType(address ad) public returns(string){
        require(msg.sender == owner);
        if(emp[ad].isforced_retired == true){
            return "Early Retirement";
        }else{
            return "Maature Retirement";
        }
    }
    
    function calculatePensionAmount(address ad, uint loan_internal, uint loan_external) public returns(uint){
        uint total = emp[ad].remaining_balance;
        uint ret = total - (loan_internal + loan_external);
        return ret;
    }
    
    function initiatePension(address ad) public{
        PensionStatus[ad] = true;
    }
    
    
}







    


