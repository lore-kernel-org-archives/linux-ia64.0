From: Bob Montgomery <bob.montgomery@hp.com>
Date: Fri, 11 Mar 2005 18:40:04 +0000
Subject: [RFC] Enhanced show_stack output to add backing store regs
Message-Id: <1110566404.498.79.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I have a patch for arch/ia64/kernel/process.c that changes
ia64_do_show_stack to show the contents of the register backing store
for each level.  I think this will help our post-mortem debugging
of hard-to-reproduce problems, especially when customers do not have
a working kernel core dump facility, by allowing us to see function
argument registers and some of the locals for each function leading
to the oops.  Note: this doesn't capture function arguments per se,
since the argument register(s) could have been modified prior to the
call to the next stack level.  You still have to read disassembly to
debug this way :-)

Is this generally interesting?  I'm wondering if it isn't currently
done because of some issue with oops message size, or excessive
printk's causing problems elsewhere?

The current vs. proposed is shown below.  Thanks for any comments
and advice.

Bob Montgomery, HP


Current Call Trace from the buncho test module's RegNat test case.
The register dump part of the oops output isn't shown here, but
contains registers in the r1-r31 range at the time of the oops-causing
exception only.

Call Trace:
 [<a000000100012940>] show_stack+0x80/0xa0
                                sp=E0000001200df960 bsp=E0000001200d8fb8
 [<a0000001000131c0>] show_regs+0x800/0x820
                                sp=E0000001200dfb30 bsp=E0000001200d8f60
 [<a000000100036b50>] die+0x150/0x280
                                sp=E0000001200dfb40 bsp=E0000001200d8f20
 [<a000000100036cc0>] die_if_kernel+0x40/0x60
                                sp=E0000001200dfb40 bsp=E0000001200d8ef0
 [<a0000001000378d0>] ia64_fault+0x150/0xac0
                                sp=E0000001200dfb40 bsp=E0000001200d8ea8
 [<a00000010000ad20>] ia64_leave_kernel+0x0/0x260
                                sp=E0000001200dfc40 bsp=E0000001200d8ea8
 [<a0000002000689d0>] buncho_going_to_regnat+0x50/0xa0 [buncho]
                                sp=E0000001200dfe10 bsp=E0000001200d8e80
 [<a000000200068e10>] buncho_ioctl+0x390/0x420 [buncho]
                                sp=E0000001200dfe20 bsp=E0000001200d8e48
 [<a000000100156e60>] sys_ioctl+0x240/0x6c0
                                sp=E0000001200dfe20 bsp=E0000001200d8db8
 [<a00000010000aba0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000001200dfe30 bsp=E0000001200d8db8
=20
-------------------------------------------------------------------------

New Call Trace from the buncho test module's RegNat test case with
register backing store output.  '*" by a register name indicates
that the register has been identified as containing a NaT (e.g. r36
in buncho_going_to_regnat below).  This version hides the actual NaT
bits word stored in the backing store.

Call Trace:
 [<a000000100012940>] show_stack+0x80/0xa0
                                sp=E0000001200df960 bsp=E0000001200d8fb8
 [<a0000001000131c0>] show_regs+0x800/0x820
                                sp=E0000001200dfb30 bsp=E0000001200d8f60
    r32 : e0000001200dfc50 r33 : 0000000000000000 r34 : e0000001200dfd08
    r35 : e0000001200dfcc8 r36 : e0000001200dfce0 r37 : e0000001200dfca0
    r38 : e0000001200dfc90 r39 : 00000fffffffbfff r40 : a000000100036b50
    r41 : 000000000000040e r42 : e0000001a00dfbce
 [<a000000100036b50>] die+0x150/0x280
                                sp=E0000001200dfb40 bsp=E0000001200d8f20
    r32 : e0000001200dfbd0 r33 : e0000001200dfc50 r34 : 0000020200000010
    r35 : a00000010066a1b8 r36 : a00000010066a1bc r37 : a000000100036cc0
    r38 : 0000000000000309 r39 : a00000010056ebe8
 [<a000000100036cc0>] die_if_kernel+0x40/0x60
                                sp=E0000001200dfb40 bsp=E0000001200d8ef0
    r32 : e0000001200dfbd0 r33 : e0000001200dfc50 r34 : 0000020200000010
    r35 : a0000001000378d0 r36 : 000000000000048e r37 : a00000010067a1d0
 [<a0000001000378d0>] ia64_fault+0x150/0xac0
                                sp=E0000001200dfb40 bsp=E0000001200d8ea8
    r32 : 000000000000001a r33 : 0000020200000010 r34 : c0000000fee01000
    r35 : 0000000000030002 r36 : e0000001200dfc50 r37 : e0000001200dfbd0
    r38 : a00000010000ad20 r39 : 0000000000000005 r40 : e0000001200dfde0
 [<a00000010000ad20>] ia64_leave_kernel+0x0/0x260
                                sp=E0000001200dfc40 bsp=E0000001200d8ea8
 [<a0000002000689d0>] buncho_going_to_regnat+0x50/0xa0 [buncho]
                                sp=E0000001200dfe10 bsp=E0000001200d8e80
    r32 : a000000200068e10 r33 : 0000000000000389 r34 : a000000200268000
    r35 : e0000001200dfe20 r36 :*0000000000000000
 [<a000000200068e10>] buncho_ioctl+0x390/0x420 [buncho]
                                sp=E0000001200dfe20 bsp=E0000001200d8e48
    r32 : e0000001fc908460 r33 : e0000040fe75e700 r34 : 000000000000006e
    r35 : 0000000000000000 r36 : a000000100156e60 r37 : 0000000000000895
    r38 : a000000200268000
 [<a000000100156e60>] sys_ioctl+0x240/0x6c0
                                sp=E0000001200dfe20 bsp=E0000001200d8db8
    r32 : 0000000000000003 r33 : 000000000000006e r34 : 0000000000000000
    r35 : 0000000000000002 r36 : 60000fffffffb9d8 r37 : 4000000000002670
    r38 : 4000000000002660 r39 : 200000000003a558 r40 : 000000000000006e
    r41 : a000000200068a80 r42 : ffffffffffffffe7 r43 : e0000040fe75e700
    r44 : a00000020006b000 r45 : a00000010000aba0 r46 : 0000000000000008
    r47 : a000000100963810 r48 : 0000000000168359
 [<a00000010000aba0>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000001200dfe30 bsp=E0000001200d8db8
=20

--=20
Bob Montgomery <bob.montgomery@hp.com>

