From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Mon, 06 Jan 2003 19:48:01 +0000
Subject: [Linux-ia64] ia-64 opcodes
Message-Id: <marc-linux-ia64-105590709805638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello all,
Does anyone have macros for emitting Itanium instructions like the
following:
-----------------------
IA-32 instructions:
typedef enum {
    X86_EAX = 0,
    X86_ECX = 1,
    X86_EDX = 2,
    X86_EBX = 3,
    X86_ESP = 4,
    X86_EBP = 5,
    X86_ESI = 6,
    X86_EDI = 7,
    X86_NREG
} X86_Reg_No;

typedef enum {
    X86_ADD = 0,
    X86_OR  = 1,
    X86_ADC = 2,
    X86_SBB = 3,
    X86_AND = 4,
    X86_SUB = 5,
    X86_XOR = 6,
    X86_CMP = 7,
    X86_NALU
} X86_ALU_Opcode;

#define x86_imm_emit32(inst,imm)     \
    do {    \
            x86_imm_buf imb; imb.val = (int) (imm); \
            *(inst)++ = imb.b [0];  \
            *(inst)++ = imb.b [1];  \
            *(inst)++ = imb.b [2];  \
            *(inst)++ = imb.b [3];  \
    } while (0)
-----------------
Thanks in advance.
Gowri Kumar


