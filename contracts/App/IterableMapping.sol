// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// 反復可能なmappingを作成する例
library IterableMapping {
  struct Map{
    address[] keys;
    mapping(address => uint) values;
    mapping(address => uint) indexOf;
    mapping(address => bool) inserted;
  }

  function get(Map storage map, address key) public view returns(uint){
    return map.values[key];
  }

  function getKeyAtIndex(Map storage map, uint index) public view returns(address){
    return map.keys[index];
  }

  function size(Map storage map)public view returns(uint){
    return map.keys.length;
  }

  function set(Map storage map, address key, uint val)public {
    if(map.inserted[key]){
      map.values[key] = val;
    }else{
      map.inserted[key] =true;
      map.values[key] = val;
      map.indexOf[key] = map.keys.length;
      map.keys.push(key);
    }
  }

  function remove(Map storage map, address key)public {
    if(!map.inserted[key]){
      return;
    }

    delete map.inserted[key];
    delete map.values[key];
    // 削除するkeyのインデックス
    uint index = map.indexOf[key];
    // keysの一番後ろのkeyを取得する
    address lastKey = map.keys[map.keys.length - 1];
    map.indexOf[lastKey] = index;
    delete map.indexOf[key];
    // popを用いると配列の一番後ろの値を削除することができる
    // 削除したいkeyは keys[index]に入っているためlastKeyに一番後ろの値を入れる
    // map.indexOf[lastKey] = index; keysの一番最後に格納されていたaddressの位置が変更されるため indexOfも変更する
    map.keys[index] = lastKey;
    map.keys.pop();
  }
}

contract TestIterableMap{
  using IterableMapping for IterableMapping.Map;

  IterableMapping.Map private map;

  function testIterableMap() public {
    map.set(address(0), 0);
    map.set(address(1), 100);
    map.set(address(2), 200);
    map.set(address(2), 200);
    map.set(address(3), 300);

    for(uint i=0; i<map.size(); i++){
      address key = map.getKeyAtIndex(i);
      // assert falseを返した場合、contractが停止し状態を実行前に戻す
      // 残りのガスは全て消費する
      // 内部のエラーテストと、不変条件のチェックのときに使用される
      assert(map.get(key) == i * 100);
    }

    map.remove(address(1));

    assert(map.size() == 3);
    assert(map.getKeyAtIndex(0) == address(0));
    assert(map.getKeyAtIndex(1) == address(3));
    assert(map.getKeyAtIndex(2) == address(2));
  }
}