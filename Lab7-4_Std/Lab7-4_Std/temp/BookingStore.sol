// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract MarketSpaceBooking {  

  mapping (bytes32 => bool) private bookedSpaces;

  //---events---
  event SpaceBooked(
    address from,   
    string shopName,
    bytes32 hash
  );
  
  event BookingError(
    address from,
    string shopName,
    string reason
  );

  // บันทึกการจองพื้นที่
  function recordBooking(bytes32 bookingHash) private {
    bookedSpaces[bookingHash] = true;
  }
  
  // จองพื้นที่ขายสินค้า
  function bookSpace(string memory shopName) public payable {
    
    // ตรวจสอบว่าชื่อร้านค้านี้เคยถูกจองมาก่อนหรือไม่
    if (bookedSpaces[hashShopName(shopName)]) {
        // แจ้งข้อผิดพลาด
        emit BookingError(msg.sender, shopName, 
            "This shop name has already been booked.");

        // คืนเงินให้ผู้ส่ง
        payable(msg.sender).transfer(msg.value);
        
        // ออกจากฟังก์ชัน
        return;
    }
    
    // ตรวจสอบว่าผู้ใช้ส่งค่า Ether เท่ากับ 0.01 ether หรือไม่
    if (msg.value != 0.00001 ether) {
        // แจ้งข้อผิดพลาด
        emit BookingError(msg.sender, shopName, 
            "Incorrect amount of Ether. 0.01 ether is required for booking.");
        
        // คืนเงินให้ผู้ส่ง
        payable(msg.sender).transfer(msg.value);
        
        // ออกจากฟังก์ชัน
        return;
    }
 
    recordBooking(hashShopName(shopName));
    
    // แจ้งการจองสำเร็จ
    emit SpaceBooked(msg.sender, shopName, 
        hashShopName(shopName));
  }
  
  // ฟังก์ชันสร้างค่าแฮชสำหรับชื่อร้านค้า
  function hashShopName(string memory shopName) private 
  pure returns (bytes32) {
    return sha256(bytes(shopName));
  }
  
  // ตรวจสอบว่าชื่อร้านค้านี้ถูกจองไว้หรือไม่
  function checkBooking(string memory shopName) public 
  view returns (bool) {
    return bookedSpaces[hashShopName(shopName)];
  }
}
