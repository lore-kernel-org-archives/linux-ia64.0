From: Joubert Berger <joubert@issl.atl.hp.com>
Date: Tue, 02 Apr 2002 21:05:45 +0000
Subject: [Linux-ia64] patching syscall into module
Message-Id: <marc-linux-ia64-105590701905365@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I am having some difficulty hooking a syscall from a module.  I used
the work that Chas Williams did for openafs.  But, I can't get my test=20
program to work.

Below is my test program and below that the stack trace.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D< cut here >=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/version.h>

#include <linux/types.h>
#include <sys/syscall.h>
#include <linux/init.h>
#include <linux/slab.h>

extern void *sys_call_table[];

struct fptr {
    unsigned long ip;
    unsigned long gp;
};

unsigned char *chmod_stub;
asmlinkage long (*sys_chmodp) (const char *, int, mode_t);

long  my_chmod(const char *filename, int mode, mode_t dev)
{

    printk("Original syscall\n");
//   return (*sys_chmodp)(filename, mode, dev);

    return 0;

}

unsigned char ia64_syscall_stub[] {
   0x00, 0x50, 0x45, 0x16, 0x80, 0x05,   //  [MII]  alloc r42=3Dar.pfs,8,3,=
6,0
   0x90, 0x02, 0x00, 0x62, 0x00, 0x60,   //         mov r41=B0
   0x05, 0x00, 0x01, 0x84,               //         mov r43=3Dr32
   0x00, 0x60, 0x01, 0x42, 0x00, 0x21,   //  [MII]  mov r44=3Dr33
   0xd0, 0x02, 0x88, 0x00, 0x42, 0xc0,   //         mov r45=3Dr34
   0x05, 0x18, 0x01, 0x84,               //         mov r46=3Dr35
   0x0d, 0x78, 0x01, 0x48, 0x00, 0x21,   //  [MFI]  mov r47=3Dr36
   0x00, 0x00, 0x00, 0x02, 0x00, 0x00,   //         nop.f 0x0
   0x06, 0x08, 0x00, 0x84,               //         mov r48=3Dgp;;
   0x05, 0x00, 0x00, 0x00, 0x01, 0x00,   //  [MLX]  nop.m 0x0
   0x00, 0x00, 0x00, 0x00, 0x00, 0xe0,   //         movl r15=3D0x0;;
   0x01, 0x00, 0x00, 0x60,               //
   0x0a, 0x80, 0x20, 0x1e, 0x18, 0x14,   //  [MMI]  ld8 r16=3D[r15],8;;
   0x10, 0x00, 0x3c, 0x30, 0x20, 0xc0,   //         ld8 gp=3D[r15]
   0x00, 0x09, 0x00, 0x07,               //         mov b6=3Dr16
   0x1d, 0x00, 0x00, 0x00, 0x01, 0x00,   //  [MFB]  nop.m 0x0
   0x00, 0x00, 0x00, 0x02, 0x00, 0x00,   //         nop.f 0x0
   0x68, 0x00, 0x00, 0x10,               //         br.call.sptk.many=20
b0=B6;;
   0x00, 0x00, 0x00, 0x00, 0x01, 0x00,   //  [MII]  nop.m 0x0
   0x00, 0x50, 0x01, 0x55, 0x00, 0x00,   //         mov.i ar.pfs=3Dr42
   0x90, 0x0a, 0x00, 0x07,               //         mov b0=3Dr41
   0x1d, 0x08, 0x00, 0x60, 0x00, 0x21,   //  [MFB]  mov gp=3Dr48
   0x00, 0x00, 0x00, 0x02, 0x00, 0x80,   //         nop.f 0x0
   0x08, 0x00, 0x84, 0x00                //         br.ret.sptk.many b0;;
};

void ia64_imm64_fixup(unsigned long v, void *code)
{
         unsigned long *bundle =3D (unsigned long *) code;

         unsigned long insn;
         unsigned long slot1;

         insn =3D ((v & 0x8000000000000000) >> 27) | ((v &=20
0x0000000000200000)) |
            ((v & 0x00000000001f0000) <<  6) | ((v & 0x000000000000ff80)=20
<< 20) |           ((v & 0x000000000000007f) << 13);

         slot1 =3D (v & 0x7fffffffffc00000) >> 22;

         *bundle |=3D slot1 << 46;
         *(bundle+1) |=3D insn << 23;
         *(bundle+1) |=3D slot1 >> 18;
}

int __init
init_module(void)
{
    unsigned long kernel_gp;
    static struct fptr sys_chmod;

    kernel_gp =3D ((struct fptr *) printk)->gp;

   /*  Setup the original call */

    sys_chmodp =3D (void *) &sys_chmod;
    ((struct fptr *) sys_chmodp)->ip =3D (void *)=20
sys_call_table[__NR_chmod-1024];
    ((struct fptr *) sys_chmodp)->gp =3D kernel_gp;

    /* Hook the syscall with our call */

    chmod_stub =3D (void *) kmalloc(sizeof(ia64_syscall_stub), GFP_KERNEL);
    memcpy(chmod_stub, ia64_syscall_stub, sizeof(ia64_syscall_stub));
    ia64_imm64_fixup((unsigned long) my_chmod, chmod_stub+0x30);
    sys_call_table[__NR_chmod-1024] =3D (void *) chmod_stub;

    printk("Installing module\n");

    return 0;
}


void __exit
cleanup_module(void)
{
    printk("Removing module\n");
    sys_call_table[__NR_chmod - 1024] =3D (void *) ((struct fptr *)=20
sys_chmodp)->ip;

}

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D< cut here >=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
But, here is the stack trace:

Apr  2 10:20:17 kong kernel: Installing module
Apr  2 10:20:31 kong kernel: Original syscall
Apr  2 10:20:31 kong kernel: chmod[865]: General Exception: IA-64=20
Reserved Register/Field fault (data access) 17179869232
Apr  2 10:20:31 kong kernel: --> schedule [kernel] 0x100 <--
Apr  2 10:20:31 kong kernel:
Apr  2 10:20:31 kong kernel: psr : 0000101008026018 ifs :=20
8000000000000894 ip  : [schedule+256/4576]    Tainted: P
Apr  2 10:20:31 kong kernel: psr : 0000101008026018 ifs :=20
8000000000000894 ip  : [<e0000000044e6520>]    Tainted: P
Apr  2 10:20:31 kong kernel: unat: 0000000000000000 pfs :=20
000000000000050a rsc : 0000000000000003
Apr  2 10:20:31 kong kernel: rnat: e00000003e6b66c8 bsps:=20
40000000000007e0 pr  : 000000000002005b
Apr  2 10:20:31 kong kernel: ldrs: 0000000000000000 ccv :=20
0000000000000000 fpsr: 0009804c8a70033f
Apr  2 10:20:31 kong kernel: b0  : e0000000044923e0 b6  :=20
e0000000046e73c0 b7  : e000000004492050
Apr  2 10:20:31 kong kernel: f6  : 0fffafffffffff0000000 f7  :=20
0ffdee000000000000000
Apr  2 10:20:31 kong kernel: f8  : 10002e000000000000000 f9  :=20
100038000000000000000
Apr  2 10:20:31 kong kernel: r1  : e00000000454b1a0 r2  :=20
e00000003af1ff00 r3  : e00000003af18000
Apr  2 10:20:31 kong kernel: r8  : 0000000000000000 r9  :=20
0000000000000894 r10 : 0000000000000000
Apr  2 10:20:31 kong kernel: r11 : 000000000002029b r12 :=20
e00000003af1fe50 r13 : e00000003af18000
Apr  2 10:20:31 kong kernel: r14 : e00000003af18038 r15 :=20
8401190100420084 r16 : e000000004a9bb78
Apr  2 10:20:31 kong kernel: r17 : 0000000000000001 r18 :=20
0000000000000000 r19 : 0000000000000000
Apr  2 10:20:31 kong kernel: r20 : e000000004aff1b0 r21 :=20
e000000004aff1d0 r22 : 0000000000000000
Apr  2 10:20:31 kong kernel: r23 : e000000004aa6a90 r24 :=20
0000001008026018 r25 : e00000003cfd0040
Apr  2 10:20:31 kong kernel: r26 : e00000003cfd0050 r27 :=20
e00000003cfd0068 r28 : e00000003af18064
Apr  2 10:20:31 kong kernel: r29 : 0000000000000001 r30 :=20
0000000000000000 r31 : 0000000000000000
Apr  2 10:20:31 kong kernel: r32 : 6f732e6362696c00 r33 :=20
72747300312e362e r34 : 7478657400797063
Apr  2 10:20:31 kong kernel: r35 : 74730066746e6972 r36 :=20
7465670074756f64 r37 : 676e6f6c5f74706f
Apr  2 10:20:31 kong kernel: r38 : 646e6570665f5f00 r39 :=20
74635f5f00676e69 r40 : 656d00625f657079
Apr  2 10:20:31 kong kernel: r41 : 747570007970636d r42 :=20
776f7472626d0073 r43 : 636f6c6c616d0063
Apr  2 10:20:31 kong kernel: r44 : 0067726174706f00 r45 :=20
0072696464616572 r46 : 756f747274735f5f
Apr  2 10:20:31 kong kernel: r47 : 6e7265746e695f6c r48 :=20
74726f6261006c61 r49 : 5f00646f6d686300
Apr  2 10:20:31 kong kernel: r50 : 0074617473786c5f r51 : 746e697270777369
Apr  2 10:20:31 kong kernel: Call Trace: [show_stack+80/192]=20
sp=3D0xe00000003af1f9d0 bsp=3D0xe00000003af191d0
Apr  2 10:20:31 kong kernel: Call Trace: [<e000000004497710>]=20
sp=3D0xe00000003af1f9d0 bsp=3D0xe00000003af191d0
Apr  2 10:20:31 kong kernel: decoded to show_stack [kernel] 0x50
Apr  2 10:20:31 kong kernel: [show_regs+1968/2016] sp=3D0xe00000003af1fb90 =

bsp=3D0xe00000003af19178
Apr  2 10:20:31 kong kernel: [<e000000004497f30>] sp=3D0xe00000003af1fb90=20
bsp=3D0xe00000003af19178
Apr  2 10:20:31 kong kernel: decoded to show_regs [kernel] 0x7b0
Apr  2 10:20:31 kong kernel: [die_if_kernel+112/320]=20
sp=3D0xe00000003af1fbb0 bsp=3D0xe00000003af19150
Apr  2 10:20:31 kong kernel: [<e0000000044a8ef0>] sp=3D0xe00000003af1fbb0=20
bsp=3D0xe00000003af19150
Apr  2 10:20:31 kong kernel: decoded to die_if_kernel [kernel] 0x70
Apr  2 10:20:31 kong kernel: [ia64_fault+1936/1984]=20
sp=3D0xe00000003af1fbb0 bsp=3D0xe00000003af19118
Apr  2 10:20:31 kong kernel: [<e0000000044aa470>] sp=3D0xe00000003af1fbb0=20
bsp=3D0xe00000003af19118
Apr  2 10:20:31 kong kernel: decoded to ia64_fault [kernel] 0x790
Apr  2 10:20:31 kong kernel: [ia64_leave_kernel+0/640]=20
sp=3D0xe00000003af1fcb0 bsp=3D0xe00000003af19118
Apr  2 10:20:31 kong kernel: [<e000000004491fe0>] sp=3D0xe00000003af1fcb0=20
bsp=3D0xe00000003af19118
Apr  2 10:20:31 kong kernel: decoded to ia64_leave_kernel [kernel] 0x0
Apr  2 10:20:31 kong kernel: [schedule+256/4576] sp=3D0xe00000003af1fe50=20
bsp=3D0xe00000003af19078
Apr  2 10:20:31 kong kernel: [<e0000000044e6520>] sp=3D0xe00000003af1fe50=20
bsp=3D0xe00000003af19078
Apr  2 10:20:31 kong kernel: decoded to schedule [kernel] 0x100
Apr  2 10:20:31 kong kernel: [invoke_schedule+32/64]=20
sp=3D0xe00000003af1fe60 bsp=3D0xe00000003af19028
Apr  2 10:20:32 kong kernel: [<e0000000044923e0>] sp=3D0xe00000003af1fe60=20
bsp=3D0xe00000003af19028
Apr  2 10:20:32 kong kernel: decoded to invoke_schedule [kernel] 0x20
Apr  2 10:20:32 kong kernel: [ia64_leave_kernel+32/640]=20
sp=3D0xe00000003af1fe60 bsp=3D0xe00000003af19028
Apr  2 10:20:32 kong kernel: [<e000000004492000>] sp=3D0xe00000003af1fe60=20
bsp=3D0xe00000003af19028
Apr  2 10:20:32 kong kernel: decoded to ia64_leave_kernel [kernel] 0x20


Any help in figuring out what I am doing wrong would be greatly appreciated.

--joubert


