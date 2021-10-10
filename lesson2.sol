pragma solidity ^0.4.19;

contract ZombieFactory {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string _name, uint _dna) private {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender; //id에 msg.sender 저장
        ownerZombieCount[msg.sender]++; // +1 씩 증가시키기
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0); //함수 한번만 실행되도록 조건 걸음
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
contract ZombieFeeding is ZombieFactory{// 컨트랙트 상속하기
    
}



import "./zombiefactory.sol"; // 상속 된 컨트랙트 가져오기

contract KittyInterface { //KittyInterface 생성
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface kittyContract = KittyInterface(ckAddress);
    //kittyContract라는 KittyInterface를 생성, ckAddress를 이용하여 초기화.
  // 여기에 있는 함수 정의를 변경:
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
    require(msg.sender == zombieToOwner[_zombieId]); //주인만 좀비한테 먹이줄수 있게함
    Zombie storage myZombie = zombies[_zombieId]; 
    //Zombie형 변수 선언.  myZombie-> zombies[_zombieId]를 가리킴. zombies 배열의 _zombieId 인덱스가 가진 값에 부여
    _targetDna = _targetDna % dnaModulus; // _targetDna 16자리를 넘지 않도록 하기위해 16자리수로 나눈 나머지랑 같게함
    uint newDna = (myZombie.dna + _targetDna) / 2; // myZombie dna랑 _targetDna 랑 평균값
    if (keccak256(_species) == keccak256("kitty")) { 
        //_species랑 "kitty" 스트링 각각의 keccak256 해시값을 비교
      newDna = newDna - newDna % 100 + 99; // dna 끝자리를 99로 만들려고
    }
    _createZombie("NoName", newDna); //_createZombie 함수 호출. 
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId); 
   //kittyContract.getKitty 함수를 호출하고 genes을 kittyDna에 저장.
   //(여러개중에 맨마지막거인 genes만 있으면 되므로)
    feedAndMultiply(_zombieId, kittyDna, "kitty"); //feedAndMultiply 함수 호출 (인자값에 kitty 추가함)
  }

}
