From: Cary Coutant <cary@cup.hp.com>
Date: Wed, 06 Feb 2002 18:45:28 +0000
Subject: Re: [Re: [Linux-ia64] IA64 Link Relocation operators ]
Message-Id: <marc-linux-ia64-105590698806009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806002@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806002@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Yes that is about the only documentation that i have been able to find about
>link relocations.  I needed some more details like how they are 
>implemented etc.

This might help -- it's the original text of the proposal I submitted to 
the psABI group. This proposal didn't include the assembler pseudo-ops; 
they came about later.

-cary


Subject:     Link-time optimization of indirect addressing (Issue #66?)
Date:        5/21/99 8:24 PM
To:          IA-64 ABI Group, ia64-abi@unix-os.sc.intel.com

One useful and simple optimization that can be done at link time is the 
in situ conversion of an indirect load or store sequence into a direct 
load or store sequence, when the linker can determine that a particular 
variable is "protected" and within addl addressing range of gp. While 
this doesn't remove any instructions (I don't want to get into the 
business of rewriting IA-64 code in the linker), it does replace a load 
with an effective no-op.

What we want to change is the sequence on the left to that on the right, 
without regard to any intervening instructions:

    addl    t1=@ltoff(var),gp    =>    addl    t1=@gprel(var),gp
    
    ld8     t2=[t1]              =>    mov     t2=[t1]
    
    ld8     loc0=[t2]            =>    ld8     loc0=[t2]

Notice that we don't have to worry about whether the temporaries t1 and 
t2 are live beyond their original ranges.

This transformation can be particularly easy with two new relocations:

LTOFF22X     0x86
LDXMOV       0x87

The LTOFF22X relocation is used on the addl instruction in place of the 
normal LTOFF22 relocation. It has exactly the same semantics as LTOFF22 
unless the linker determines that the symbol can be addressed directly. 
If the symbol can be addressed directly, the linker transforms this into 
a GPREL22 relocation.

The LDXMOV relocation is used on the first ld8 instruction, where no 
relocation would ordinarily be seen. Its symbol and addend fields must 
match exactly those of the corresponding LTOFF22X relocation. If the 
linker determines that the symbol can be addressed directly, it rewrites 
the ld8 as a mov. This can be done easily by masking out all but the qp, 
r1, and r3 fields of the instruction, then or'ing in the bit pattern 
0x8000000000.

Of course, any implementation may treat LTOFF22X as a synonym of LTOFF22, 
and ignore LDXMOV completely.

