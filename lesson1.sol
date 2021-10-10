pragma solidity ^0.4.19;

import "./ownable.sol"; // 임포트해오기

contract ZombieFactory is Ownable{ //좀비팩토리 컨트랙트 만듦 // 레슨3에서 Ownable을 상속하도록 함
    event NewZombie(uint zombieId, string name, uint dna); //이벤트 선언 이벤트명(인자)
    uint dnaDigits = 16; // 숫자형 변수 선언
    uint dnaModulus = 10 ** dnaDigits; //16제곱 변수 선언
    uint cooldownTime = 1 days; // 레슨3에서 쿨다운타임 선언해줌

    struct Zombie { //구조체 선언
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    Zombie[] public zombies; //좀비 구조체를 zombies 배열에 넣음


    function _createZombie(string _name, uint _dna) internal { 
    //_createZombie 함수 선언 - 인자는  _name, _dna 이고 private으로 선언함 -> 나중에 internal로 바꿔줌 (상속한곳에서도 쓰려고)
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1; 
        // id 라는 변수에 인덱스를 만들어서 넣어줌 - zombies.push가 새로 만들어진 좀비 배열수를 반환해주므로 -1
        // 레슨 3에서 1, uint32(now + cooldownTime) 얘네 인자 추가해줌. Zombie 구조체 생성할 때 함수의 인수 개수가 정확히 맞도록하기위해
        NewZombie(id, _name, _dna); // 이벤트 호출
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str)); // keccak256으로 랜덤한 수를 만듦 (16진수)
        return rand % dnaModulus; // 그 수를 dnaModulus로 나눈 나머지를 반환
    }

    function createRandomZombie(string _name) public { //createRandomZombie 함수 만듦 퍼블릭으로
        uint randDna = _generateRandomDna(_name); //_generateRandomDna함수를 호출해서 변수에 담음
        _createZombie(_name, randDna); //_createZombie 호출 (인자값으로 randDna를 넣음)
    }

}
