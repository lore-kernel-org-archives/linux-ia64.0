From: Keith Owens <kaos@sgi.com>
Date: Tue, 17 Dec 2002 02:34:03 +0000
Subject: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805589@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 16 Dec 2002 18:10:21 -0500,=20
Jim Wilson <wilson@redhat.com> wrote:
>Yes, this is the latest one that we give away free of charge to non-custom=
ers.
>I think we stopped maintaining these tools a while ago when we started
>recommending RH AS 2.[01] instead of RHL 7.[012] for IA-64 customers.

I built binutils-2.13.90.0.2-2 (from rh 8.0) on ia64.  I extracted the
generated assembler for ia64_fault as traps.S.  The bug still exists in
2.13.90.0.2.  traps.S has been sent to Jim Wilson as a test case.

/usr/src/redhat/BUILD/binutils-2.13.90.0.2/binutils/tmpdir/gas/as -x -mcons=
tant-gp traps.S -o traps.o
/usr/src/redhat/BUILD/binutils-2.13.90.0.2/binutils/readelf -u traps.o

Unwind section '.IA_64.unwind' at offset 0xb40 contains 1 entries:

<ia64_fault>: [0x0-0xad0), info at +0x0
  v1, flags=3D0x0 ( ), len=16 bytes
    R2:prologue_gr(mask=3D[rp,ar.pfs],grsave=3Dr37,rlen=3D8)
        P7:pfs_when(t=3D0)
        P7:mem_stack_f(t=3D2,size%6)
        P7:rp_when(t=3D7)
    R3:body(rlenG5)			<=3D should be 511
        B2:epilogue(t=3D2,ecount=3D0)
    R1:prologue(rlen=3D0)

0000000000000000 <ia64_fault>:
   0:   0c 30 31 0e 80 05       [MFI]       alloc r38=3Dar.pfs,12,7,0
   6:   00 00 00 02 00 80                   nop.f 0x0
   c:   01 60 f8 8c                         adds r12=3D-256,r12
  10:   04 00 00 00 01 00       [MLX]       nop.m 0x0
  16:   00 08 00 00 00 c0                   movl r14=3D0x80000000f
  1c:   f1 00 00 60=20
  20:   02 00 00 00 01 00       [MII]       nop.m 0x0
  26:   50 02 00 62 00 c0                   mov r37=B0;;
  2c:   e1 08 31 80                         and r14=3Dr14,r33
.....
 ab0:   00 00 00 00 01 00       [MII]       nop.m 0x0
 ab6:   00 30 01 55 00 00                   mov.i ar.pfs=3Dr38
 abc:   50 0a 00 07                         mov b0=3Dr37
 ac0:   1d 60 00 18 02 21       [MFB]       adds r12%6,r12
 ac6:   00 00 00 02 00 80                   nop.f 0x0
 acc:   08 00 84 00                         br.ret.sptk.many b0;;
 ad0:   0c 00 00 00 01 00       [MFI]       nop.m 0x0			<=3D=3D end of code=
 at slot 519
 ad6:   00 00 00 02 00 00                   nop.f 0x0
 adc:   00 00 04 00                         nop.i 0x0


