// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity  ^0.8.13;

import {IERC20} from "./IERC20.sol";

contract SchoolSystem {
     IERC20 token;
    address owner;


    uint studentCounter;
    uint staffCounter;


    struct Student{
        address studentAddress;
        uint id;
        string name;
        uint age;
        uint level;
        bool hasPaid;
        uint paidAt;

    }

    struct Staff{
        address staffAddress;
        uint id;
        string name;
        string role;
        uint salary;
        uint lastPaid;
        bool onSuspension;
        bool exists;
    }

    mapping(address => Student) students;
    mapping (address => Staff) staffs;
    mapping(uint => uint) levelFees;// level to fee


    Student[] allStudents;
    Staff[] allStaffs;


    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner na");
        _;
    }

    modifier validLevel(uint _level) {
        require(
            _level == 100 || _level == 200 || _level == 300 || _level == 400, "invalid level"
        );
        _;
    }

    modifier validAddress(address _address){
        require(_address != address(0), "Address zero detected");
        _;
    }

    modifier notStudent(address _address){
        require(students[_address].studentAddress == address(0), "This Address belong to a student");
        _;

    }

    modifier notStaff(address _address){
        require(staffs[_address].staffAddress == address(0), "This address blongs to a staff");
        _;
    }


    constructor(address _token) validAddress(_token) {
        require(_token != msg.sender, "token cant be  the owner");

        token = IERC20(_token);
        owner = msg.sender;

        studentCounter = 1;
        staffCounter = 1;
    }

    event StudentEnrolled(address indexed student, string name, uint level, uint feesPaid, uint timestamp);
    event StaffEmployed(address indexed staff, string name, string role, uint salary);
    event StaffPaid(address indexed student, uint amount, uint timestamp);
    event StaffSuspended(address indexed staff, bool indexed suspended);
    event StudentRemoved(address indexed staff, uint indexed removedAt);


    function setLevelFee() external onlyOwner() {
        levelFees[100] = 100 * 10**18;
        levelFees[200] = 200 * 10**18;
        levelFees[300] = 300 * 10**18;
        levelFees[400] = 400 * 10**18;
    }

    function registerStudents(string memory _name, uint _age, uint _level, address _studentAddress) external validAddress(_studentAddress) validLevel(_level) notStaff(_studentAddress)  onlyOwner() {
        require(students[_studentAddress].level ==0, "Student already registered");
        require(_studentAddress != owner, "you are the school owner");

        uint fee = levelFees[_level];
        require(fee > 0, "insufficient fee");
        require(token.transferFrom(_studentAddress, address(this), fee), "fee transfer didnt go through");

        uint studentId = studentCounter;

        students[_studentAddress] = Student({
            studentAddress: _studentAddress,
            id: studentId,
            name: _name,
            age: _age,
            level: _level,
            hasPaid: true,
            paidAt: block.timestamp
        });

        allStudents.push(students[_studentAddress]);

        studentCounter++;

        emit StudentEnrolled(_studentAddress, _name, _level, fee, block.timestamp);

    }

       function removeStudent(address _student) external  validAddress(_student) onlyOwner() {
        Student storage st = students[_student];

        require(st.studentAddress != address(0), "Student not found");

        uint256 length = allStudents.length;
        for (uint256 i = 0; i < length; i++) {
            if (allStudents[i].studentAddress == _student) {
                allStudents[i] = allStudents[length - 1];
                allStudents.pop();
                break;
            }
        }

        delete students[_student];

        emit StudentRemoved(_student, block.timestamp);
    }


    function getAllStudentsWithDetails() external view returns (Student[] memory) {
        return allStudents;
    }


    function registerStaff(address _staffAddress, string memory _name, string memory _role, uint256 _salary) external  validAddress(_staffAddress) onlyOwner() notStudent(_staffAddress) {
        require(!staffs[_staffAddress].exists, "Staff is employed");
        require(_salary > 0, "salary should be greater then 0");
        require(_staffAddress != owner, "u are the school owner");

        uint256 staffId = staffCounter;
        staffs[_staffAddress] = Staff({
            staffAddress: _staffAddress,
            id: staffId,
            name: _name,
            salary: _salary,
            role: _role,
            lastPaid: 0,
            exists: true,
            onSuspension: false
        });

        allStaffs.push(staffs[_staffAddress]);

        staffCounter++;

        emit StaffEmployed(_staffAddress, _name, _role, _salary);
    }

    function payStaff(address _staffAddress) external validAddress(_staffAddress) onlyOwner() notStudent(_staffAddress) {
        require(_staffAddress != owner, "u are the school owner");


        Staff storage st = staffs[_staffAddress];

        require(st.exists, "Staff not found");
        require(st.salary > 0, "invalid salary");
        require(!st.onSuspension, "staff");
         st.lastPaid = block.timestamp;

        require(token.transfer(_staffAddress, st.salary), "Payment failed");

       

        emit StaffPaid(_staffAddress, st.salary, block.timestamp);
    }

    function suspendStaff(address _staffAddress, bool _suspend) external onlyOwner() validAddress(_staffAddress) notStudent(_staffAddress) {
        require(staffs[_staffAddress].exists, "Staff not found");

        
        uint256 length = allStaffs.length;
        for (uint256 i = 0; i < length; i++) {
            if (allStaffs[i].staffAddress == _staffAddress) {
                allStaffs[i] = allStaffs[length - 1];
                allStaffs.pop();
                break;
            }
        }
        
        staffs[_staffAddress].onSuspension = _suspend;
        
        emit StaffSuspended(_staffAddress, _suspend);
    }

    function getAllStaff() external view returns(Staff[] memory) {
        return allStaffs;
    }

    function contractTokenBalance() external view returns(uint256) {
        return token.balanceOf(address(this));
    }

}