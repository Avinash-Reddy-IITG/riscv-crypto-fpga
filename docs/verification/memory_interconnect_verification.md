# Memory Interconnect Verification

## 1. Verification Objective

The objective was to verify that `memory_interconnect` correctly routes CPU memory transactions to the appropriate memory-mapped device and returns the correct read data.

Verification was performed at two levels:

1. Standalone interconnect verification.
2. CPU integration verification.

## 2. Standalone Testbench

The standalone testbench is:

```text
tb/core/memory_interconnect_tb.v
```

It drives the CPU-side interface and observes the RAM and SHA-256 interfaces. Device read-data inputs are supplied directly by the testbench so that the interconnect can be verified independently of peripheral implementations.

## 3. Verification Areas

The regression checks:

- RAM address decoding
- RAM read routing
- RAM write routing
- SHA-256 address decoding
- SHA-256 read routing
- SHA-256 write routing
- address propagation
- write-data propagation
- `funct3` propagation
- RAM read-data return
- SHA read-data return
- device isolation
- unsupported-address behavior
- address-boundary behavior
- prevention of unintended device activation

## 4. RAM Verification

Addresses in:

```text
0x0000_0000 – 0x0000_0FFF
```

must select RAM.

For a RAM read:

```text
ram_read  = 1
ram_write = 0
sha_read  = 0
sha_write = 0
```

For a RAM write:

```text
ram_write = 1
ram_read  = 0
sha_write = 0
sha_read  = 0
```

The testbench also checks RAM address, write data, and `funct3` propagation.

## 5. SHA-256 Verification

Addresses in:

```text
0x1000_0000 – 0x1000_00FF
```

must select the SHA-256 interface.

The testbench checks read and write routing as well as address, write-data, and `funct3` propagation.

The supplied SHA read data must be returned to the CPU.

## 6. Device Isolation

When a RAM address is supplied, the SHA interface must remain inactive.

When a SHA address is supplied, the RAM interface must remain inactive.

This prevents accidental transactions to unrelated devices.

## 7. Unsupported Addresses

For an address such as:

```text
0x3000_0000
```

no device must be selected:

```text
ram_read  = 0
ram_write = 0
sha_read  = 0
sha_write = 0
```

The CPU read-data output must be:

```text
0x0000_0000
```

## 8. Boundary Verification

The upper boundary of the RAM region was checked:

```text
0x0000_0FFF
```

The upper boundary of the SHA-256 region was checked:

```text
0x1000_00FF
```

Both must select their respective devices.

## 9. Standalone Result

The standalone interconnect regression completed with:

```text
Tests  : 26
Errors : 0
```

Result:

```text
MEMORY INTERCONNECT VERIFICATION PASS
```

## 10. CPU Integration Verification

After standalone verification, the interconnect was inserted between the RV32I CPU and the existing data RAM:

```text
RV32I CPU
    |
    v
Memory Interconnect
    |
    v
Data RAM
```

The existing CPU regression was then run again.

Result:

```text
Tests  : 52
Errors : 0
```

Therefore, inserting the interconnect did not alter the previously verified RV32I behavior.

## 11. Troubleshooting

During the earlier memory-interface refactoring, the CPU testbench still referenced the old hierarchy:

```text
dut.u_rv32i_datapath.u_data_memory.memory[address]
```

After moving data memory outside the datapath, the correct hierarchy became:

```text
dut.u_data_memory.memory[address]
```

The testbench was updated accordingly.

This was a testbench hierarchy issue rather than an RTL functional error.

## 12. Final Verification Summary

| Verification Level | Tests | Errors | Result |
|---|---:|---:|---|
| Memory Interconnect standalone | 26 | 0 | PASS |
| RV32I CPU after integration | 52 | 0 | PASS |

The memory interconnect is therefore verified and ready for SHA-256 integration.

## 13. Next Verification Target

The next major verification target is the SHA-256 accelerator.

Planned architecture:

```text
RV32I CPU
    |
    v
Memory Interconnect
    |
    +----> Data RAM
    |
    +----> SHA-256
```

The SHA-256 accelerator will be verified independently before being connected to the memory-mapped interface.
