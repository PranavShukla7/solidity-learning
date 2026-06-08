//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TodoList{
    struct Todo {
        uint256 id;
        string task;
        bool completed;
    }
    address public owner;
    error NotOwner();
    modifier onlyOwner(){
        if(msg.sender != owner){
            revert NotOwner();
        }
        _;
    }
    Todo[] private todos;

    event TodoCreated(uint256 id, string task);
    event TodoCompleted(uint256 id);
    event TodoDeleted(uint256 id);
    event TodoUpdated(uint256 id, string task);

    function createTodo(string memory _task) public onlyOwner() {
        uint256 id = todos.length;

        todos.push(
            Todo({
                id: id,
                task: _task,
                completed: false
            })
        );
        emit TodoCreated(id, _task);
    }
    function completeTodo(uint256 _id) public onlyOwner() {
        todos[_id].completed = true;
        emit TodoCompleted(_id);
    }

    function getTodo(uint256 _id) public view returns (uint256, string memory, bool) {
        Todo memory todo = todos[_id];
        return (todo.id, todo.task, todo.completed);
    }


    function getTodoCount() public view returns (uint256) {
        return todos.length;
    }


    function deleteTodo(uint256 _id) public onlyOwner() {
        delete todos[_id];
        emit TodoDeleted(_id);
    }

    function updateTodo(uint256 _id, string memory _task) public onlyOwner(){
        todos[_id].task = _task;
        emit TodoUpdated(_id, _task);
    }      
}