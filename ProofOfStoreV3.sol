// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract MarketSpaceBooking {

    struct Booking {
        bool isBooked;
        address owner;
        string zoneName; // To explicitly store the zone name
    }

    mapping (bytes32 => Booking) private bookings;

    //--- events ---
    event SpaceBooked(
        address indexed from,
        string shopName,
        string zoneName,
        bytes32 hash
    );
    
    event BookingError(
        address indexed from,
        string shopName,
        string zoneName,
        string reason
    );

    event BookingCancelled(
        address indexed from,
        string shopName,
        string zoneName,
        bytes32 hash
    );

    // บันทึกการจองพื้นที่
    function recordBooking(bytes32 bookingHash, address owner, string memory zoneName) private {
        bookings[bookingHash] = Booking(true, owner, zoneName);
    }

    // จองพื้นที่ขายสินค้า
    function bookSpace(string memory shopName, string memory zoneName) public payable {
        bytes32 bookingHash = hashShopAndZone(shopName, zoneName);

        // ตรวจสอบว่าชื่อร้านค้านี้ในโซนนี้เคยถูกจองมาก่อนหรือไม่
        if (bookings[bookingHash].isBooked) {
            // แจ้งข้อผิดพลาด
            emit BookingError(msg.sender, shopName, zoneName, 
                "This shop name in the specified zone has already been booked.");

            // คืนเงินให้ผู้ส่ง
            payable(msg.sender).transfer(msg.value);
            
            // ออกจากฟังก์ชัน
            return;
        }
        
        // ตรวจสอบว่าผู้ใช้ส่งค่า Ether เท่ากับ 0.01 ether หรือไม่
        if (msg.value != 0.00001 ether) {
            // แจ้งข้อผิดพลาด
            emit BookingError(msg.sender, shopName, zoneName, 
                "Incorrect amount of Ether. 0.00001 ether is required for booking.");
            
            // คืนเงินให้ผู้ส่ง
            payable(msg.sender).transfer(msg.value);
            
            // ออกจากฟังก์ชัน
            return;
        }

        recordBooking(bookingHash, msg.sender, zoneName);
        
        // แจ้งการจองสำเร็จ
        emit SpaceBooked(msg.sender, shopName, zoneName, bookingHash);
    }

    // ฟังก์ชันสำหรับยกเลิกการจอง
    function cancelBooking(string memory shopName, string memory zoneName) public {
        bytes32 bookingHash = hashShopAndZone(shopName, zoneName);
        
        // ตรวจสอบว่าเป็นเจ้าของการจองหรือไม่
        if (bookings[bookingHash].owner != msg.sender) {
            emit BookingError(msg.sender, shopName, zoneName, "Only the owner can cancel the booking.");
            return;
        }
        
        // ลบการจอง
        delete bookings[bookingHash];
        
        // แจ้งการยกเลิกการจอง
        emit BookingCancelled(msg.sender, shopName, zoneName, bookingHash);
    }

    // ฟังก์ชันสร้างค่าแฮชสำหรับชื่อร้านค้าและโซน
    function hashShopAndZone(string memory shopName, string memory zoneName) private 
    pure returns (bytes32) {
        return sha256(abi.encodePacked(shopName, zoneName));
    }

    // ตรวจสอบว่าชื่อร้านค้านี้ในโซนนี้ถูกจองไว้หรือไม่
    function checkBooking(string memory shopName, string memory zoneName) public 
    view returns (bool) {
        bytes32 bookingHash = hashShopAndZone(shopName, zoneName);
        return bookings[bookingHash].isBooked;
    }

    
}
