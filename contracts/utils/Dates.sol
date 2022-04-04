//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

library Dates {
    uint256 private constant YEAR_IN_SECONDS = 31536000;
    uint256 private constant MONTH_IN_SECONDS = 2629743;
    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant HOUR_IN_SECONDS = 3600;
    uint256 private constant ORIGIN_YEAR = 1970;
    uint256 private constant LEAP_YEAR_IN_SECONDS = 31622400;

    function isLeapYear(uint256 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint256 year) internal pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getYear(uint256 timestamp) internal pure returns (string memory) {
        uint256 secondsAccountedFor = 0;
        uint256 year;
        uint256 numLeapYears;

        // Year
        year = uint256(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint256(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return Strings.toString(year);
    }

    function parseDate(uint256 dateInSeconds)
        internal
        pure
        returns (string memory)
    {
        if (dateInSeconds <= 0) {
            return "0 seconds";
        }

        // Variable rounded up
        uint256 remainingYears = (dateInSeconds - 1) / YEAR_IN_SECONDS + 1;

        if (remainingYears > 1) {
            return
                string(
                    abi.encodePacked(Strings.toString(remainingYears), " years")
                );
        }

        // Variable rounded up
        uint256 remainingMonths = (dateInSeconds - 1) / MONTH_IN_SECONDS + 1;

        if (remainingMonths > 2) {
            return
                string(
                    abi.encodePacked(
                        Strings.toString(remainingMonths),
                        " months"
                    )
                );
        }

        // Variable rounded up
        uint256 remainingDays = (dateInSeconds - 1) / DAY_IN_SECONDS + 1;

        if (remainingDays > 1) {
            return
                string(
                    abi.encodePacked(Strings.toString(remainingDays), " days")
                );
        }

        // Variable rounded up
        uint256 remainingHours = (dateInSeconds - 1) / HOUR_IN_SECONDS + 1;

        if (remainingHours > 1) {
            return
                string(
                    abi.encodePacked(Strings.toString(remainingHours), " hours")
                );
        }

        return
            string(
                abi.encodePacked(
                    Strings.toString((dateInSeconds - 1)),
                    " second(s)"
                )
            );
    }
}
