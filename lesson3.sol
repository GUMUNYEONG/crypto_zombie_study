pragma solidity ^0.4.19;

import "./zombiefactory.sol";
import "./zombiefeeding.sol";


contract KittyInterface {
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
  // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d; 얘 지움
  KittyInterface kittyContract; // = KittyInterface(ckAddress); 얘도 선언으로 바꿔줌 

  function setKittyContractAddress(address _address) external onlyOwner{ //setKittyContractAddress 함수생성
    //소유주만 해당 함수를 호출할수있게 onlyOwner 제어자 추가
    kittyContract = KittyInterface(_address); //kittyContract에 KittyInterface(_address)를 대입
  }
  function _triggerCooldown(Zombie storage _zombie) internal { //좀비 재사용 대기시간 생성
    _zombie.readyTime = uint32(now + cooldownTime); 
  }
  function _isReady(Zombie storage _zombie) internal view returns (bool) { //재사용 대기시간 끝나야 먹이 먹을수있음
      return (_zombie.readyTime <= now);
  }
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal { // 사용자들이 맘대로 이 함수 실행 못하게
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie)); // 좀비 대사용 대기시간 끝난 다음에만 feedAndMultiply 함수 호출가능
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(_species) == keccak256("kitty")) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);// 좀비가 먹이 먹으면 재사용대기시간 생기게
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}

////////////////////////////////////
contract ZombieHelper is ZombieFeeding { //ZombieFeeding 상속하기
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level); // zombies[_zombieId].level이 _level 이상인지 확인
    _;
  }

  function changeName(uint _zombieId, string _newName) external aboveLebel(2, _zombieId){
      // aboveLebel 제어자 가짐. 레벨이 2넘으면 밑의 조건 실행 가능
    require(msg.sender == zombieToOwner[_zombieId]); // 호출자가 좀비 소유자와 같은지 확인
    zombies[_zombieId].name = _newName;
}

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
    //레벨 20 넘으면 dna 설정할수있음
  }
  }
    function getZombiesByOwner(address _owner) external view returns(uint[]) {
    // view 함수는 가스를 거의 소모하지 않음
    uint[] memory result = new uint[](ownerZombieCount[_owner]); //메모리에 배열 선언 배열길이:ownerZombieCount[_owner]
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) { //i 번째 좀비 소유주가 함수에서 찾는 소유주가 맞는지 확인 주소값 비교
        result[counter] = i; //result배열에 좀비 id 추가
        counter++; // counter +1씩 증가
      }
    }
    return result;
  }
}