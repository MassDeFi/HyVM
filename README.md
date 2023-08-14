
## Nested fork of HyVM
For more information about the HyVM, see the [orignal HyVM repo](https://github.com/oguimbal/HyVM).   
This fork prevents several state changing operations to be executed to reduce attack surface and mistakes.

## HyVM divergence

It will revert for the following opcodes:
- `sstore`
- `create`
- `create2`
- `delegatecall`  

## HyVM state changing operations
Some state changing operations are still allowed:
- Event emission (log0, log1...)
- Call with non-zero value

Those operations are not reverted because they cannot modify the storage of the contract that delegates the call
and can be useful for logging or calling other contracts.
