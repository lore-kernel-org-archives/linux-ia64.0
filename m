From: Omar Stradella <omar@sgi.com>
Date: Mon, 15 May 2000 17:57:20 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205085@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 11 May 2000, Jim Wilson wrote:

> I wrote a simple program that generates a very large program with out of range
> calls, compiled it with -Wl,-relax, and looked at the code.  It looks fine.
> The out-of-range call gets redirected to a stub at the end of the function
> that does a brl with absolute address to the target function.  I don't see
> how this can corrupt the gp.
> 
> Maybe it is a kernel problem with the emulation?  Have you tried debugging the
> code to see where the gp gets corrupted?  Try stepping over the brl instruction
> to see if the kernel is clobbering gp.  I don't have a kernel with brl
> emulation support yet, so I can not try this myself.
> 
> Alternatively, there could be something different about your testcase that
> causes the linker relaxation to fail.  I might be obvious if you look at the
> code you are getting.

OK. This is a disassembly of the part of _init where __do_global_ctors_aux 
is called in my program (created with -relax):

4000000000001c00:       0b 60 40 18 00 21       [MMI]       adds r12,r12;;
4000000000001c06:       10 00 30 30 20 00                   ld8 r1=[r12]
4000000000001c0c:       00 00 04 00                         nop.i 0x0;;
4000000000001c10:       1d 80 07 18 99 17       [MFB]       st8 [r12]=r1,-16
4000000000001c16:       00 00 00 02 00 00                   nop.f 0x0
4000000000001c1c:       28 00 00 50                         br.call.sptk.many b0@00000000001c30 <_init+0xa0>;;
4000000000001c20:       0b 60 40 18 00 21       [MMI]       adds r12,r12;;
4000000000001c26:       10 00 30 30 20 00                   ld8 r1=[r12]
4000000000001c2c:       00 00 04 00                         nop.i 0x0;;
4000000000001c30:       05 00 00 00 01 00       [MLX]       nop.m 0x0
4000000000001c36:       01 00 00 00 00 00                   brl 400000000158eb40 <__do_global_ctors_aux>;;
4000000000001c3c:       10 cf 58 c0 
4000000000001c40:       00 60 00 40 00 21       [MII]       mov r12=r32
4000000000001c46:       00 10 01 55 00 00                   mov.i ar.pfs=r34
4000000000001c4c:       10 0a 00 07                         mov b0=r33
4000000000001c50:       11 00 00 00 01 00       [MIB]       nop.m 0x0
4000000000001c56:       00 00 00 02 00 80                   nop.i 0x0
4000000000001c5c:       08 00 84 00                         br.ret.sptk.many b0;;

Notice at 1c1c the branch to the brl instruction at 1c30. In contrast this
is the disassembly of the same part for a small program:

40000000000019f0:       0b 60 40 18 00 21       [MMI]       adds r12,r12;;
40000000000019f6:       10 00 30 30 20 00                   ld8 r1=[r12]
40000000000019fc:       00 00 04 00                         nop.i 0x0;;
4000000000001a00:       1d 80 07 18 99 17       [MFB]       st8 [r12]=r1,-16
4000000000001a06:       00 00 00 02 00 00                   nop.f 0x0
4000000000001a0c:       e8 05 13 50                         br.call.sptk.many b0@00000000131fe0 <__do_global_ctors_aux>;;
4000000000001a10:       0b 60 40 18 00 21       [MMI]       adds r12,r12;;
4000000000001a16:       10 00 30 30 20 00                   ld8 r1=[r12]
4000000000001a1c:       00 00 04 00                         nop.i 0x0;;
4000000000001a20:       00 60 00 40 00 21       [MII]       mov r12=r32
4000000000001a26:       00 10 01 55 00 00                   mov.i ar.pfs=r34
4000000000001a2c:       10 0a 00 07                         mov b0=r33
4000000000001a30:       11 00 00 00 01 00       [MIB]       nop.m 0x0
4000000000001a36:       00 00 00 02 00 80                   nop.i 0x0
4000000000001a3c:       08 00 84 00                         br.ret.sptk.many b0;;

Following the execution of my program under gbd one can see:

1) the branch to 1c30 in _init
2) the brl branch to __do_global_ctors_aux
3) entering __do_global_ctors_aux at 158eb40
4) exiting __do_global_ctors_aux
5) next instruction is at 1c20 
6) it keeps going, reaching the brl instruction at 1c30 again !!
7) it gets a SEGV in __do_global_ctors_aux after a few instructions

The second time that enters __do_global_ctors_aux, r1 is zero.
Shouldn't the brl be out of the way so it doesn't get executed two times ?
The program was linked using gcc from gnupro-2.9-000501p2 and run under the
2.3.99-pre6-000501-20smp kernel.


Omar
+---------------------------------------------------------------------+
Omar G. Stradella, Ph.D.                    
SGI / Chemistry and Biology Applications Group
1 Cabot Rd, Suite 250, Hudson, MA 01749, USA    N 42 22'40" W 71 33'37"
E-mail: omar@sgi.com        Phone: +1-781-839-2258 FAX: +1-978-562-7450 
http://www.sgi.com/chembio                  http://reality.sgi.com/omar 
+--------  Ph-nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn  -------+



