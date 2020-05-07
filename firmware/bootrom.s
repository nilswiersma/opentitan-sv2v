# key    2b7e1516 28aed2a6 abf71588 09cf4f3c
# input  6bc1bee2 2e409f96 e93d7e11 7393172a
# output b3ae6cbf dd60d75c ea0dbca2 540eb0ed
#
# from submod.aes.aes import AES, matrix2bytes
# k = bytes.fromhex("2b7e1516 28aed2a6 abf71588 09cf4f3c")
# i = bytes.fromhex("6bc1bee2 2e409f96 e93d7e11 7393172a")
# ctx = AES(k[::-1])
# c   = ctx.encrypt_block(i[::-1])[::-1]
# iks = [b''.join(map(lambda x: bytes(x), ik)) for ik in ctx._key_matrices]
# print(f'k: {k.hex()}') # k: 2b7e151628aed2a6abf7158809cf4f3c
# print(f'i: {i.hex()}') # i: 6bc1bee22e409f96e93d7e117393172a
# print(f'c: {c.hex()}') # c: b3ae6cbfdd60d75cea0dbca2540eb0ed

.global _reset
.type _reset, %function
_reset:
addi x1, x1, 1
la x2, 0x40110000
li x3, 0xdeadbeef
lw x4, 0(x2)

# https://docs.opentitan.org/hw/ip/aes/doc/
# setup control register
# manual = 1
# mode = ecb
# keylen = 128
# operation = encrypt
# hex(0b10010010)
li x3, 0x00000092
sw x3, 64(x2)

lw x4, 72(x2)

# setup key
li x3, 0x09cf4f3c
sw x3, 0(x2)
li x3, 0xabf71588
sw x3, 4(x2)
li x3, 0x28aed2a6
sw x3, 8(x2)
li x3, 0x2b7e1516
sw x3, 12(x2)
# li x3, 0x40110010
# sw x3, 16(x2)
# li x3, 0x40110014
# sw x3, 20(x2)
# li x3, 0x40110018
# sw x3, 24(x2)
# li x3, 0x4011001c
# sw x3, 28(x2)

# read status
lw x4, 72(x2)

# setup input
li x3, 0x7393172a
sw x3, 32(x2)
li x3, 0xe93d7e11
sw x3, 36(x2)
li x3, 0x2e409f96
sw x3, 40(x2)
li x3, 0x6bc1bee2
sw x3, 44(x2)

# read status
lw x4, 72(x2)

# write start to trigger
li x3, 0x00000001
sw x3, 68(x2)

# read status
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)
lw x4, 72(x2)

# read output
lw x4, 48(x2)
lw x4, 52(x2)
lw x4, 56(x2)
lw x4, 60(x2)

jal x0, _reset

# reset vector
.org 0x800
jal x0, _reset
