From: Zack Weinberg <zack@codesourcery.com>
Date: Sun, 07 Mar 2004 23:09:56 +0000
Subject: Re: Possible race condition with deferred binding on IPF
Message-Id: <87ptbo2r0b.fsf@egil.codesourcery.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
In-Reply-To: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zack Weinberg <zack@codesourcery.com> writes:

> I have two related concerns before I try to submit a patch:
>
> 1) If I assemble the sample code above, using GAS 2.14, the first byte
>    of the first bundle is 0a, not 0b.  Hex-editing it to 0b doesn't
>    seem to make any difference to the disassembly, but I would like to
>    know if there is a difference anyway.

... maybe I should read the disassembly dumps more carefully.  This
turns out to be because I dropped the ;; on the third instruction of
the first bundle.

> 2) There is another code sequence synthesized by the linker that might
>    need the same treatment:
>
> static const bfd_byte plt_header[PLT_HEADER_SIZE] > {
>   0x0b, 0x10, 0x00, 0x1c, 0x00, 0x21,  /*   [MMI]       mov r2=r14;;       */
>   0xe0, 0x00, 0x08, 0x00, 0x48, 0x00,  /*               addl r14=0,r2      */
>   0x00, 0x00, 0x04, 0x00,              /*               nop.i 0x0;;        */
>   0x0b, 0x80, 0x20, 0x1c, 0x18, 0x14,  /*   [MMI]       ld8 r16=[r14],8;;  */
>   0x10, 0x41, 0x38, 0x30, 0x28, 0x00,  /*               ld8 r17=[r14],8    */
>   0x00, 0x00, 0x04, 0x00,              /*               nop.i 0x0;;        */
>   0x11, 0x08, 0x00, 0x1c, 0x18, 0x10,  /*   [MIB]       ld8 r1=[r14]       */
>   0x60, 0x88, 0x04, 0x80, 0x03, 0x00,  /*               mov b6=r17         */
>   0x60, 0x00, 0x80, 0x00               /*               br.few b6;;        */
> };

I looked this up in the ABI document, and now I understand what it is
doing.  There is in fact a function descriptor fetch in here, from the
PLT_RESERVE area; it's the second and third ld8 instructions.  It
seems unlikely that we have to worry about this getting changed on the
fly at runtime, but a belt-and-suspenders approach would put an .acq
suffix on the second ld8.

I have a related question.  It seems to me that the canonical form of
the PLT entries has not been optimized quite as much as it could be.
In particular, the use of r14 as the pointer to the function
descriptor seems suboptimal.  As I read the document, this register is
dead after it's used to load the global pointer.  If r2 were used
instead, I think PLT0 could be tightened up a bit, at the cost of
pushing the PLT_RESERVE pointer load into the secondary PLT entries
(where there is a free bundle slot - the cost is in having to update
all of them at load time, but then, that has to happen anyway to set
up the PLT index).  Thus:

.PLT0:
        ld8     r16 = [r2], 8
        ld8     r17 = [r2], 8 ;;   # possibly ld8.acq
        ld8     r1 = [r2]
        mov     b6 = r17
        br      b6            ;;

.PLT1:
        addl    r15 = @pltoff(name1), r1 ;;
        ld8.acq r16 = [r15], 8
        mov     r2 = r1 ;;
        ld8     r1 = [r15]
        mov     b6 = r16
        br.few  b6      ;;

.PLT1a:
        addl    r2 = @gprel(plt_reserve), r2
        mov     r15 = @iplt(name1)
        br      .PLT0

The net effect is to shrink .PLT0 by one bundle and execute one fewer
non-NOP instruction.  Thoughts?

zw
