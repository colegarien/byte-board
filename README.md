### Usage

1. compress to a .zip
2. change file extension to `.asesprite-extension`
3. Edit -> Preferences -> Extensions -> Add Extension... to add the extension to aseprite


### Purpose

This will convert the selected area into a monochrome `uint8_t` array and copy that array to the clipboard for easy tranfer of graphics from asepsrite to device firmware.

### Example Ouput:

```cpp
// size: 8 x 5
static const uint8_t THE_IMG[] = {
  0b00010000,
  0b00011000,
  0b00110100,
  0b01111010,
  0b01111110,
};
```

### Important Notes

- the script will pad 0's to the nearest 8bit alignment
- the script will read only the active layer + cel + selection