From: Uros Prestor <uros@turbolinux.com>
Date: Thu, 11 Jan 2001 20:12:38 +0000
Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005028@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> Are you sure you picked up the new kernel?  Try "objdump -d" on
> vmlinux and verify that itlb_fault ends with "b0" being restored.

This is the disassembly output of itlb_fault:
e000000000500400 <itlb_fault>:
e000000000500400:       00 80 00 28 24 04       [MII]       mov r16=3Dcr20
e000000000500406:       d0 01 00 62 00 e0                   mov r29=B0
e00000000050040c:       03 00 cc 00                         mov r31=3Dpr
e000000000500410:       05 88 00 32 24 44       [MLX]       mov r17=3Dcr25
e000000000500416:       00 00 00 00 60 c0                   movl r30=3D0xe0=
0000000
0500420;;
e00000000050041c:       03 02 22 68
e000000000500420:       0a 90 00 22 18 10       [MMI]       ld8 r18=3D[r17]=
;;
e000000000500426:       00 00 00 02 00 c0                   nop.m 0x0
e00000000050042c:       00 90 00 50                         tbit.z p6,p0=3D=
r18,0
e000000000500430:       11 00 00 00 01 00       [MIB]       nop.m 0x0
e000000000500436:       00 00 00 02 00 03                   nop.i 0x0
e00000000050043c:       98 0c 00 41                   (p06) br.cond.spnt.ma=
ny e0
000000005010c0 <page_fault>;;
e000000000500440:       0a 00 48 00 2f 04       [MMI]       itc.i r18;;
e000000000500446:       00 00 00 02 00 00                   nop.m 0x0
e00000000050044c:       d0 09 00 07                         mov b0=3Dr29
e000000000500450:       11 00 00 00 01 00       [MIB]       nop.m 0x0
e000000000500456:       f0 ff c0 bf 05 00                   mov pr=3Dr31,0x=
fffffff
ffffffffe
e00000000050045c:       00 00 20 00                         rfi;;

Seems like the b0 register is getting restored correctly.

Uros

--
Uros Prestor
uros@turbolinux.com




