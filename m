From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 02:51:53 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805590@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Dec 2002 13:34:03 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> I built binutils-2.13.90.0.2-2 (from rh 8.0) on ia64.  I
  Keith> extracted the generated assembler for ia64_fault as traps.S.
  Keith> The bug still exists in 2.13.90.0.2.  traps.S has been sent
  Keith> to Jim Wilson as a test case.

Which compiler did you use?  With gcc-3.0, I get the info attached
below.  It looks correct to me (I only checked the total length, not
the individual regions).

	--david

<ia64_fault>: [0xe00000000442cd00-0xe00000000442d840], info at +0x545c80
  v1, flags=0x0 (), len$ bytes
    R2:prologue_gr(mask=[rp,ar.pfs],grsave=r37,rlen)
        P7:pfs_when(t=0)
        P7:mem_stack_f(t=1,size%6)
        P7:rp_when(t)
    R3:body(rlenU)
        B1:label_state(label=1)
        B2:epilogue(t=2,ecount=0)
    R3:body(rlenG1)
        B1:copy_state(label=1)

e00000000442cd00 <ia64_fault>:
e00000000442cd00:       00 30 31 0e 80 05       [MII]       alloc r38=ar.pfs,12,
7,0
e00000000442cd06:       c0 00 30 7c 46 00                   adds r12=-256,r12
e00000000442cd0c:       00 00 04 00                         nop.i 0x0
      :
e00000000442d820:       00 70 c0 03 96 26       [MII]       addl r14=-2077840,r1
e00000000442d826:       90 02 85 5e 29 60                   shr.u r41=r33,16
e00000000442d82c:       04 61 04 84                         adds r354,r12
e00000000442d830:       1d 00 00 00 01 00       [MFB]       nop.m 0x0
e00000000442d836:       00 00 00 02 00 00                   nop.f 0x0
e00000000442d83c:       c0 fe ff 48                         br.few e000000004426f0 <ia64_fault+0x9f0>;;

