// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Project.sol";
import "./RoleManager.sol";

contract ProjectManager {

    RoleManager public roleManager; 
    mapping(address => bool) public registeredProjects;

    event ProjectRegistered(address indexed projectAddress, string name, string description, address creator);
    event ProjectStateUpdated(address indexed projectAddress, Project.ProjectState newState);


    modifier onlyApprover() {
        require(roleManager.isStaffOrAdmin(msg.sender), "No tenes permiso");
        _;
    }
    constructor(address _roleManagerAddress) {
        roleManager = RoleManager(_roleManagerAddress);
    }


    // El creator registra el proyecto
    function registerProject(
        string memory _name,
        string memory _description,
        address _carbonCreditTokenAddress,
        uint256 _totalTokens
    ) public returns (address) {
        Project newProject = new Project(
            _name,
            _description,
            _carbonCreditTokenAddress,
            _totalTokens,
            msg.sender 
        );
        address projectAddress = address(newProject);
        registeredProjects[projectAddress] = true;
        emit ProjectRegistered(projectAddress, _name, _description, msg.sender);
        return projectAddress;
    }

    function updateProjectStatus(address _projectAddress, Project.ProjectState _newState) public onlyApprover {
        require(registeredProjects[_projectAddress], "Project is not registered.");
        Project project = Project(_projectAddress);
        project.updateState(_newState);
        emit ProjectStateUpdated(_projectAddress, _newState);
    }

    function isProjectRegistered(address _projectAddress) public view returns (bool) {
        return registeredProjects[_projectAddress];
    }
}