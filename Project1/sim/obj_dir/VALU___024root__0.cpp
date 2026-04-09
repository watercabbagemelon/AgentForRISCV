// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VALU.h for the primary calling header

#include "VALU__pch.h"

void VALU___024root___eval_triggers_vec__ico(VALU___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___eval_triggers_vec__ico\n"); );
    VALU__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered[0U]) 
                                     | (IData)((IData)(vlSelfRef.__VicoFirstIteration)));
}

bool VALU___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void VALU___024root___ico_sequent__TOP__0(VALU___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___ico_sequent__TOP__0\n"); );
    VALU__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<8>/*255:0*/ __Vtemp_6;
    // Body
    __Vtemp_6[0U] = (vlSelfRef.io_a + vlSelfRef.io_b);
    __Vtemp_6[1U] = (vlSelfRef.io_a - vlSelfRef.io_b);
    __Vtemp_6[2U] = (vlSelfRef.io_a & vlSelfRef.io_b);
    __Vtemp_6[3U] = (vlSelfRef.io_a | vlSelfRef.io_b);
    __Vtemp_6[4U] = (vlSelfRef.io_a ^ vlSelfRef.io_b);
    __Vtemp_6[5U] = VL_LTS_III(32, vlSelfRef.io_a, vlSelfRef.io_b);
    __Vtemp_6[6U] = 0U;
    __Vtemp_6[7U] = 0U;
    vlSelfRef.io_result = (((0U == (0x0000001fU & ((IData)(vlSelfRef.io_op) 
                                                   << 5U)))
                             ? 0U : (__Vtemp_6[(((IData)(0x0000001fU) 
                                                 + 
                                                 ((IData)(vlSelfRef.io_op) 
                                                  << 5U)) 
                                                >> 5U)] 
                                     << ((IData)(0x00000020U) 
                                         - (0x0000001fU 
                                            & ((IData)(vlSelfRef.io_op) 
                                               << 5U))))) 
                           | (__Vtemp_6[(0x07ffffffU 
                                         & (IData)(vlSelfRef.io_op))] 
                              >> (0x0000001fU & ((IData)(vlSelfRef.io_op) 
                                                 << 5U))));
    vlSelfRef.io_zero = (0U == vlSelfRef.io_result);
}

void VALU___024root___eval_ico(VALU___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___eval_ico\n"); );
    VALU__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<8>/*255:0*/ __Vinline__ico_sequent__TOP__0___Vtemp_6;
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered[0U])) {
        __Vinline__ico_sequent__TOP__0___Vtemp_6[0U] 
            = (vlSelfRef.io_a + vlSelfRef.io_b);
        __Vinline__ico_sequent__TOP__0___Vtemp_6[1U] 
            = (vlSelfRef.io_a - vlSelfRef.io_b);
        __Vinline__ico_sequent__TOP__0___Vtemp_6[2U] 
            = (vlSelfRef.io_a & vlSelfRef.io_b);
        __Vinline__ico_sequent__TOP__0___Vtemp_6[3U] 
            = (vlSelfRef.io_a | vlSelfRef.io_b);
        __Vinline__ico_sequent__TOP__0___Vtemp_6[4U] 
            = (vlSelfRef.io_a ^ vlSelfRef.io_b);
        __Vinline__ico_sequent__TOP__0___Vtemp_6[5U] 
            = VL_LTS_III(32, vlSelfRef.io_a, vlSelfRef.io_b);
        __Vinline__ico_sequent__TOP__0___Vtemp_6[6U] = 0U;
        __Vinline__ico_sequent__TOP__0___Vtemp_6[7U] = 0U;
        vlSelfRef.io_result = (((0U == (0x0000001fU 
                                        & ((IData)(vlSelfRef.io_op) 
                                           << 5U)))
                                 ? 0U : (__Vinline__ico_sequent__TOP__0___Vtemp_6
                                         [(((IData)(0x0000001fU) 
                                            + ((IData)(vlSelfRef.io_op) 
                                               << 5U)) 
                                           >> 5U)] 
                                         << ((IData)(0x00000020U) 
                                             - (0x0000001fU 
                                                & ((IData)(vlSelfRef.io_op) 
                                                   << 5U))))) 
                               | (__Vinline__ico_sequent__TOP__0___Vtemp_6
                                  [(0x07ffffffU & (IData)(vlSelfRef.io_op))] 
                                  >> (0x0000001fU & 
                                      ((IData)(vlSelfRef.io_op) 
                                       << 5U))));
        vlSelfRef.io_zero = (0U == vlSelfRef.io_result);
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VALU___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool VALU___024root___eval_phase__ico(VALU___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___eval_phase__ico\n"); );
    VALU__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VicoExecute;
    // Body
    VALU___024root___eval_triggers_vec__ico(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VALU___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
    __VicoExecute = VALU___024root___trigger_anySet__ico(vlSelfRef.__VicoTriggered);
    if (__VicoExecute) {
        VALU___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void VALU___024root___eval(VALU___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___eval\n"); );
    VALU__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VicoIterCount;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VicoIterCount)))) {
#ifdef VL_DEBUG
            VALU___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
            VL_FATAL_MT("generated\\top.sv", 2, "", "DIDNOTCONVERGE: Input combinational region did not converge after '--converge-limit' of 100 tries");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        vlSelfRef.__VicoPhaseResult = VALU___024root___eval_phase__ico(vlSelf);
        vlSelfRef.__VicoFirstIteration = 0U;
    } while (vlSelfRef.__VicoPhaseResult);
}

#ifdef VL_DEBUG
void VALU___024root___eval_debug_assertions(VALU___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VALU___024root___eval_debug_assertions\n"); );
    VALU__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clock & 0xfeU)))) {
        Verilated::overWidthError("clock");
    }
    if (VL_UNLIKELY(((vlSelfRef.reset & 0xfeU)))) {
        Verilated::overWidthError("reset");
    }
    if (VL_UNLIKELY(((vlSelfRef.io_op & 0xf8U)))) {
        Verilated::overWidthError("io_op");
    }
}
#endif  // VL_DEBUG
