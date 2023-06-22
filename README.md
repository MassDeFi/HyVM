
## Nested fork of HyVM
For more information about the HyVM, see the [orignal HyVM repo](https://github.com/oguimbal/HyVM).   
This fork prevents state changing operation to be executed.  

## HyVM divergence

It will revert for the following opcodes:
- `sstore`
- `create`
- `create2`
- `delegatecall`  

This will prevent state changing operations reducing attack surface and mistakes when using this fork.

