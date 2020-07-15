pragma solidity ^0.4.25;


contract Payroll{
    
    address owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    
    //modifiers will control the access and control flow
    
    modifier onlyOwner(){
        require (msg.sender == owner, 'must be a owner');
        _;
    }
    
    
    event paySal(address _emp, uint value);
    event payPen(address _emp, uint value);
    
    
    
    
    
    
    
                                               //   Department
    
    
    mapping(address => Department) public department;
    enum PensionState {Requested, Processing, Accepted, Rejected, Finished}
    
    struct Department{
        uint dept_id;
        string dept_name;
        uint total_balance;
        uint remaining_balance;
    }
    
    function addDepartment(address ad, uint _dept_id, string memory _dept_name, uint _total_balance, uint _remaining_balance)
    public onlyOwner{
        department[ad] = Department(_dept_id, _dept_name, _total_balance, _remaining_balance);
        
    }
    
    function paySallary(address _dept, address _emp, uint amount) payable external onlyOwner{

        if(department[_dept].total_balance > amount && employeeState[_emp] == EmployeeState.Active){
            department[_dept].total_balance -= amount;
            emit paySal(_emp, amount);
        }else{
            revert("Low balance");
        }
    }
    
    
    function calculatePensionAmount(address ad, uint loan_internal, uint loan_external)view public returns(uint){
        uint total = emp[ad].remaining_balance;
        uint ret = total - (loan_internal + loan_external);
        return ret;
    }
    
    
    function payPension(address _dept, address _emp, uint amount) payable external onlyOwner{
        if ((employeeState[_emp] == EmployeeState.Retired || employeeState[_emp] == EmployeeState.EarlyRetired)
            && (empEarly[_emp].remaining_balance > 0 || emp[_emp].remaining_balance > 0)){
            
            department[_dept].total_balance -= amount;
            emit payPen(_emp, amount);
        }else{
            revert("Something went wrong..... check status");
        }
        
    }
    
    
    
    
    
    
    
    
                                                //employee 
                                                
                                                
    enum EmployeeState {Active, Retired, EarlyRetired, Dismissed}
    
    mapping(address => EmployeeState) public employeeState;
    mapping(address => Employee) public employee;
    mapping (address => EmployeeAgreement) public empAgreement;
    
    struct Employee{
        uint employee_id;
        uint dept_id;
        string name;
        string birth_date;
        string joining_date;
    }
    
    struct EmployeeAgreement{
        uint working_hour;
        uint monthly_sallery;
        uint yearly_paid_leave;
        uint weekly_workday;
        string designation;
        uint joining_date;
        uint service_year_mature;
        uint service_year_earlyRetirement;
    }
    
    function addEmployee(address _ad,  uint _employee_id, uint _dept_id, string memory _name,
                         string memory _birth_date, string memory _joining_date)
                         public onlyOwner{
                    
        employee[_ad] = Employee(_employee_id, _dept_id, 
                                 _name, _birth_date, 
                                 _joining_date); 
                                    
        employeeState[_ad] = EmployeeState.Active;
    }
    
    
    function employeeAgreement(address _ad, uint _work_hour, uint _salllary, uint _paid_leave, 
        uint _work_day, string memory _designation, uint _service_year_mature,
        uint _service_year_earlyRetirement) public onlyOwner{
         
        uint join_date = block.timestamp;
        empAgreement[_ad] = EmployeeAgreement(_work_hour, _salllary, _paid_leave, _work_day,
                                              _designation,join_date, _service_year_mature, 
                                              _service_year_earlyRetirement); 
    }
    
    
    
                                              // Retired Employee
    
    
    mapping(address => EmpRetired) public emp;
    
    struct EmpRetired{
        uint total_balance;
        uint remaining_balance;
        uint monthly_pension_amount;
        bool loan_taken;
        uint pension_start_date;
    }
    
    function addRetiredEmpployee(address _ad,
                                 uint _total_balance, 
                                 uint _remaining_balance,
                                 uint _monthly_pension_amount, 
                                 bool _loan_taken)
                                 public onlyOwner{
                                 
        uint _start_date = block.timestamp;
        emp[_ad] = EmpRetired(_total_balance, 
                             _remaining_balance,
                             _monthly_pension_amount,
                             _loan_taken,
                             _start_date);
            
        employeeState[_ad] = EmployeeState.Retired;
    }
    
    
    
                                            // Early Retired Employee
    
    
     mapping(address => EmpEarlyRetired) public empEarly;
    
    struct EmpEarlyRetired{
        uint total_balance;
        uint remaining_balance;
        uint monthly_pension_amount;
        bool loan_taken;
        string pension_start_date;
    }
    
    function addRetiredEmpployee(address _ad,
                                 uint _total_balance, 
                                 uint _remaining_balance,
                                 uint _monthly_pension_amount, 
                                 bool _loan_taken,
                                 string memory _pension_start_date) 
                    
                    public onlyOwner{
                
        empEarly[_ad] = EmpEarlyRetired(_total_balance, 
                             _remaining_balance,
                             _monthly_pension_amount,
                             _loan_taken,
                             _pension_start_date);
            
        employeeState[_ad] = EmployeeState.EarlyRetired;
    }
    
    
    
}







    


