From: Zack Weinberg <zack@codesourcery.com>
Date: Sun, 07 Mar 2004 21:53:19 +0000
Subject: Re: Possible race condition with deferred binding on IPF
Message-Id: <87u1102uk0.fsf@egil.codesourcery.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
In-Reply-To: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cary Coutant <cary@cup.hp.com> writes:

> We (HP) have discovered a missing requirement in the psABI document
> with respect to import stubs and inlined import stubs.
...

> 2. The example code in Figure 5-4 needs the ".acq" completer on the
> first load instruction, as follows:
>
>      ...
>      .PLT1: (entry for symbol name1)
>          addl     r15 = @pltoff(name1), gp ;;
>          ld8.acq  r16 = [r15], 8
>          mov      r14 = gp ;;
>          ld8      gp = [r15]
>          mov      b6 = r16
>          br       b6

I believe that this corresponds to the following code in bfd/elfxx-ia64.c:

static const bfd_byte plt_full_entry[PLT_FULL_ENTRY_SIZE] {
  0x0b, 0x78, 0x00, 0x02, 0x00, 0x24,  /*   [MMI]       addl r15=0,r1;;    */
  0x00, 0x41, 0x3c, 0x30, 0x28, 0xc0,  /*               ld8 r16=[r15],8    */
  0x01, 0x08, 0x00, 0x84,              /*               mov r14=r1;;       */
  0x11, 0x08, 0x00, 0x1e, 0x18, 0x10,  /*   [MIB]       ld8 r1=[r15]       */
  0x60, 0x80, 0x04, 0x80, 0x03, 0x00,  /*               mov b6=r16         */
  0x60, 0x00, 0x80, 0x00               /*               br.few b6;;        */
};

Converting the ld8 to a ld8.acq is a simple matter of changing the
second line of this array to

  0x00, 0x41, 0x3c, 0x70, 0x29, 0xc0,  /*               ld8.acq r16=[r15],8 */

However, I have two related concerns before I try to submit a patch:

1) If I assemble the sample code above, using GAS 2.14, the first byte
   of the first bundle is 0a, not 0b.  Hex-editing it to 0b doesn't
   seem to make any difference to the disassembly, but I would like to
   know if there is a difference anyway.

2) There is another code sequence synthesized by the linker that might
   need the same treatment:

static const bfd_byte plt_header[PLT_HEADER_SIZE] {
  0x0b, 0x10, 0x00, 0x1c, 0x00, 0x21,  /*   [MMI]       mov r2=r14;;       */
  0xe0, 0x00, 0x08, 0x00, 0x48, 0x00,  /*               addl r14=0,r2      */
  0x00, 0x00, 0x04, 0x00,              /*               nop.i 0x0;;        */
  0x0b, 0x80, 0x20, 0x1c, 0x18, 0x14,  /*   [MMI]       ld8 r16=[r14],8;;  */
  0x10, 0x41, 0x38, 0x30, 0x28, 0x00,  /*               ld8 r17=[r14],8    */
  0x00, 0x00, 0x04, 0x00,              /*               nop.i 0x0;;        */
  0x11, 0x08, 0x00, 0x1c, 0x18, 0x10,  /*   [MIB]       ld8 r1=[r14]       */
  0x60, 0x88, 0x04, 0x80, 0x03, 0x00,  /*               mov b6=r17         */
  0x60, 0x00, 0x80, 0x00               /*               br.few b6;;        */
};

I don't understand what this code is doing so I can't be sure which
ld8 needs an .acq.  (In fact, I don't understand the point of the
first bundle at all.)

zw
