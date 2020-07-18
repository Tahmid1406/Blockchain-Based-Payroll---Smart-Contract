pragma solidity >=0.4.22 <0.7.0;


contract Payroll{
    
    address owner;
    mapping(address => EmpEarlyRetired) public empEarly;
    mapping(address => PensionState) public pensionState;
    mapping(address => Department) public department;
    mapping(address => EmployeeState) public employeeState;
    mapping(address => Employee) public employee;
    mapping (address => EmployeeAgreement) public empAgreement;
    enum EmployeeState {Active, Retired, EarlyRetired, Dismissed}
    enum PensionState {Requested, Processing, Accepted, Finished}
    mapping(address => EmpRetired) public empRetired;
    
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
    
    struct Department{
        uint dept_id;
        string dept_name;
        uint total_balance;
        uint remaining_balance;
    }
    
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
    
    struct EmpRetired{
        uint total_balance;
        uint remaining_balance;
        uint monthly_pension_amount;
        bool loan_taken;
        uint pension_start_date;
    }
    
    struct EmpEarlyRetired{
        uint total_balance;
        uint remaining_balance;
        uint monthly_pension_amount;
        bool loan_taken;
        string pension_start_date;
    }
    
    
    
    
                                               //   Only Owner

    function addDepartment(address ad, uint _dept_id, string memory _dept_name, uint _total_balance, uint _remaining_balance)
    public onlyOwner{
        department[ad] = Department(_dept_id, _dept_name, _total_balance, _remaining_balance);
        
    }
    
    function addEmployee(address _ad,  uint _employee_id, uint _dept_id, string memory _name,
                         string memory _birth_date, string memory _joining_date)
                         public onlyOwner{
                    
        employee[_ad] = Employee(_employee_id, _dept_id, 
                                 _name, _birth_date, 
                                 _joining_date); 
                                    
        employeeState[_ad] = EmployeeState.Active;
    }
    
    function addRetiredEmpployee(address _ad,
                                 uint _total_balance, 
                                 uint _remaining_balance,
                                 uint _monthly_pension_amount, 
                                 bool _loan_taken)
                                 public onlyOwner{
                                 
        uint _start_date = block.timestamp;
        empRetired[_ad] = EmpRetired(_total_balance, 
                             _remaining_balance,
                             _monthly_pension_amount,
                             _loan_taken,
                             _start_date);
            
        employeeState[_ad] = EmployeeState.Retired;
    }
    
    function employeeAgreement(address _ad, uint _work_hour, uint _salllary, uint _paid_leave, 
        uint _work_day, string memory _designation, uint _service_year_mature,
        uint _service_year_earlyRetirement) public onlyOwner{
         
        uint join_date = block.timestamp;
        empAgreement[_ad] = EmployeeAgreement(_work_hour, _salllary, _paid_leave, _work_day,
                                              _designation,join_date, _service_year_mature, 
                                              _service_year_earlyRetirement); 
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
    
    function paySallary(address _dept, address _emp, uint amount) payable external onlyOwner{

        if(department[_dept].total_balance > amount && employeeState[_emp] == EmployeeState.Active){
            department[_dept].total_balance -= amount;
            emit paySal(_emp, amount);
        }else{
            pensionState[_emp] = PensionState.Finished;
            revert("Low balance");
        }
        
        
    }
    
    function payPension(address _dept, address _emp, uint amount) payable external onlyOwner{
        if ((employeeState[_emp] == EmployeeState.Retired || employeeState[_emp] == EmployeeState.EarlyRetired)
            && (empEarly[_emp].remaining_balance > 0 || empRetired[_emp].remaining_balance > 0)){
            
            department[_dept].total_balance -= amount;
            emit payPen(_emp, amount);
        }else{
            revert("Something went wrong..... check status");
        }
        
    }
    
    function putToRetirement(address _ad) private onlyOwner{
        if(empAgreement[_ad].joining_date + now >= empAgreement[_ad].service_year_mature){
            employeeState[_ad] = EmployeeState.Retired;
            pensionState[_ad] = PensionState.Requested;
        }else if(empAgreement[_ad].joining_date + now >= empAgreement[_ad].service_year_earlyRetirement){
            employeeState[_ad] = EmployeeState.EarlyRetired;
            pensionState[_ad] = PensionState.Requested;
        }
    }
    
    function calculatePensionAmount(address ad, uint loan_internal, uint loan_external) view private returns(uint){
        uint total = empRetired[ad].remaining_balance;
        uint ret = total - (loan_internal + loan_external);
        return ret;
    }
    
    function applyForPension()  public{
        if(pensionState[msg.sender] == PensionState.Requested && 
            ( employeeState[msg.sender] == EmployeeState.Retired 
            || employeeState[msg.sender] == EmployeeState.EarlyRetired)){
            pensionState[msg.sender] = PensionState.Processing;
        }
    }
    
    function getRemainingPension(address _ad) view public returns(uint){
        if(employeeState[_ad] == EmployeeState.Retired){
            return empRetired[_ad].remaining_balance;
        }else if(employeeState[_ad] == EmployeeState.EarlyRetired){
            return empEarly[_ad].remaining_balance;
        }
    }
    function getPensionStatus(address _ad) view public returns(PensionState){
        return pensionState[_ad];
    }
    
}







    


