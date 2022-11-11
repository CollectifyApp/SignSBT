// SPDX-License-Identifier: MIT
// Collectify Launchapad Contracts v1.1.0
// Creator: Hging

pragma solidity ^0.8.4;

import './Base64.sol';

library SVG {
  function generateSVG(string memory name, string memory contractDesc, uint256 token_id, string memory sender, string memory receiver, string memory description, string memory timestamp, string memory price) internal view returns (string memory) {
    string[16] memory parts;

    parts[0] = '<?xml version="1.0" encoding="utf-8"?>';

    parts[1] = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 600 800" style="enable-background:new 0 0 600 800;background-color:white" xml:space="preserve">';

    parts[2] = '<style type="text/css">.st1{fill:#D4A354;}.st2{text-anchor:middle;font-family:"GothamRounded-BookItalic";}.st3{text-align:center;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-box-orient:vertical;white-space:normal !important;word-wrap:break-word;}.st4{-webkit-line-clamp:10;}.st5{font-size:16px;}.st6{-webkit-line-clamp:1;}.st7{background:#D4A354;height:0.1875em;margin:1em 0 1em 0;}.st8{font-size:20px;font-weight:bold;}</style>';

    parts[3] = '<g id="Sign-Mode" class="st2"><path class="st1" d="M584,784H16V16h568V784z M21,779h558V21H21V779z"/><path class="st1" d="M572,772H28V28h544V772z M29,771h542V29H29V771z"/><text y="80" x="50%" class="st5">SIGNER</text>';

    parts[4] = string(abi.encodePacked('<text y="108" x="50%" class="st4 st8">', sender, '</text>'));

    parts[5] = '<text y="150" x="50%" class="st5">RECIPIENT</text>';
    parts[6] = string(abi.encodePacked('<text y="178" x="50%" class="st4 st8">', receiver, '</text>'));

    parts[7] = '<foreignObject x="100" y="220" width="400" height="230"><div xmlns="http://www.w3.org/1999/xhtml" class="st3 st4">';

    parts[8] = description;
    parts[9] = '</div></foreignObject><text y="505" x="50%" class="st5">';
    parts[10] = timestamp;
    parts[11] = '</text><text y="525" x="50%" class="st5">mint timestamp</text><text y="570" x="50%" class="st5">';
    parts[12] = price;
    parts[13] = '</text><text y="590" x="50%" class="st5">price</text><text y="640" x="50%" class="st5">';
    parts[14] = toString(address(this));
    parts[15] = '</text><text y="660" x="50%" class="st5">contract</text><text y="740" x="50%" style="font-size:14px;font-style: italic;">Powered by Collectify.app</text></g></svg>';


    string memory output1 = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
    string memory output2 = string(abi.encodePacked(parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15]));
    string memory output = string(abi.encodePacked(output1, output2));
    string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', name, ' #', toString(token_id), '", "description": "', contractDesc, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
    output = string(abi.encodePacked('data:application/json;base64,', json));

    return output;

  }
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toString(address account) public pure returns(string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}