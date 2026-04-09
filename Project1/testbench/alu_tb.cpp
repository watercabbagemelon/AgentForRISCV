#include "VALU.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>

double sc_time_stamp() { return 0; }

#define OP_ADD 0
#define OP_SUB 1
#define OP_AND 2
#define OP_OR  3
#define OP_XOR 4
#define OP_SLT 5

static int pass_count = 0, fail_count = 0;

static void check(VALU* dut, const char* name, uint32_t a, uint32_t b, uint8_t op,
                  uint32_t exp_result, uint8_t exp_zero) {
    dut->io_a  = a;
    dut->io_b  = b;
    dut->io_op = op;
    dut->eval();

    bool ok = (dut->io_result == exp_result) && (dut->io_zero == exp_zero);
    printf("[%s] a=0x%08X b=0x%08X op=%d | result=0x%08X(exp=0x%08X) zero=%d(exp=%d) -> %s\n",
           name, a, b, op, dut->io_result, exp_result, dut->io_zero, exp_zero,
           ok ? "PASS" : "FAIL");
    if (ok) pass_count++; else fail_count++;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VALU* dut = new VALU;

    // ADD
    check(dut, "ADD", 5, 3, OP_ADD, 8, 0);
    check(dut, "ADD_ZERO", 0, 0, OP_ADD, 0, 1);
    check(dut, "ADD_OVERFLOW", 0xFFFFFFFF, 1, OP_ADD, 0, 1);

    // SUB
    check(dut, "SUB", 10, 3, OP_SUB, 7, 0);
    check(dut, "SUB_ZERO", 5, 5, OP_SUB, 0, 1);
    check(dut, "SUB_NEG", 3, 10, OP_SUB, (uint32_t)-7, 0);

    // AND
    check(dut, "AND", 0xFF00FF00, 0x0F0F0F0F, OP_AND, 0x0F000F00, 0);
    check(dut, "AND_ZERO", 0xAAAAAAAA, 0x55555555, OP_AND, 0, 1);

    // OR
    check(dut, "OR", 0xFF000000, 0x00FF0000, OP_OR, 0xFFFF0000, 0);
    check(dut, "OR_ZERO", 0, 0, OP_OR, 0, 1);

    // XOR
    check(dut, "XOR", 0xFFFFFFFF, 0xFFFFFFFF, OP_XOR, 0, 1);
    check(dut, "XOR_BASIC", 0xA5A5A5A5, 0x5A5A5A5A, OP_XOR, 0xFFFFFFFF, 0);

    // SLT (signed)
    check(dut, "SLT_TRUE", (uint32_t)-1, 0, OP_SLT, 1, 0);   // -1 < 0
    check(dut, "SLT_FALSE", 5, 3, OP_SLT, 0, 1);              // 5 >= 3
    check(dut, "SLT_EQUAL", 7, 7, OP_SLT, 0, 1);              // 7 == 7

    printf("\n=== Total: %d, PASS: %d, FAIL: %d ===\n",
           pass_count + fail_count, pass_count, fail_count);

    delete dut;
    return fail_count ? 1 : 0;
}
