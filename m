From: Cary Coutant <cary@cup.hp.com>
Date: Mon, 08 Mar 2004 17:15:44 +0000
Subject: Re: Possible race condition with deferred binding on IPF
Message-Id: <3BC7D31F-7124-11D8-A2F3-003065589C02@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
In-Reply-To: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Converting the ld8 to a ld8.acq is a simple matter of changing the
> second line of this array to
>
>   0x00, 0x41, 0x3c, 0x70, 0x29, 0xc0,  /*               ld8.acq 
> r16=[r15],8 */

Yes, this is the same bit pattern Steve Ellcey and I came up with.

> 1) If I assemble the sample code above, using GAS 2.14, the first byte
>    of the first bundle is 0a, not 0b.  Hex-editing it to 0b doesn't
>    seem to make any difference to the disassembly, but I would like to
>    know if there is a difference anyway.

As you discovered, that's just a missing stop bit.

> 2) There is another code sequence synthesized by the linker that might
>    need the same treatment:
>
> static const bfd_byte plt_header[PLT_HEADER_SIZE] > {
>   0x0b, 0x10, 0x00, 0x1c, 0x00, 0x21,  /*   [MMI]       mov r2=r14;;   
>     */
>   0xe0, 0x00, 0x08, 0x00, 0x48, 0x00,  /*               addl r14=0,r2  
>     */
>   0x00, 0x00, 0x04, 0x00,              /*               nop.i 0x0;;    
>     */
>   0x0b, 0x80, 0x20, 0x1c, 0x18, 0x14,  /*   [MMI]       ld8 
> r16=[r14],8;;  */
>   0x10, 0x41, 0x38, 0x30, 0x28, 0x00,  /*               ld8 
> r17=[r14],8    */
>   0x00, 0x00, 0x04, 0x00,              /*               nop.i 0x0;;    
>     */
>   0x11, 0x08, 0x00, 0x1c, 0x18, 0x10,  /*   [MIB]       ld8 r1=[r14]   
>     */
>   0x60, 0x88, 0x04, 0x80, 0x03, 0x00,  /*               mov b6=r17     
>     */
>   0x60, 0x00, 0x80, 0x00               /*               br.few b6;;    
>     */
> };

This code does not need to be patched. The two words loaded here point 
to the dynamic loader's BOR routine. The dynamic loader must provide 
the proper values in the linkage table before the program can run; 
these values will not change, so the ordering isn't important. Adding 
an ld.acq here would unnecessarily slow the code down.

> I have a related question.  It seems to me that the canonical form of
> the PLT entries has not been optimized quite as much as it could be.
> In particular, the use of r14 as the pointer to the function
> descriptor seems suboptimal.  As I read the document, this register is
> dead after it's used to load the global pointer.  If r2 were used
> instead, I think PLT0 could be tightened up a bit, at the cost of
> pushing the PLT_RESERVE pointer load into the secondary PLT entries
> (where there is a free bundle slot - the cost is in having to update
> all of them at load time, but then, that has to happen anyway to set
> up the PLT index).

I don't see anything wrong with you're reasoning, but changing this 
will have a binary compatibility impact, as the copy of gp to r14 is 
now part of the ABI, and will be present in inlined import stubs in 
existing .o files. I don't think gcc generates inlined import stubs at 
the moment, but I think Intel's compiler does.

Too bad. It leaves me wondering why we didn't design it this way in the 
first place.

-cary

