From: Zack Weinberg <zack@codesourcery.com>
Date: Mon, 08 Mar 2004 18:08:09 +0000
Subject: Re: Possible race condition with deferred binding on IPF
Message-Id: <87wu5v1aba.fsf@egil.codesourcery.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
In-Reply-To: <BEC72735-6E38-11D8-9E11-003065589C02@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cary Coutant <cary@cup.hp.com> writes:

>> Converting the ld8 to a ld8.acq is a simple matter of changing the
>> second line of this array to
>>
>>   0x00, 0x41, 0x3c, 0x70, 0x29, 0xc0,  /*               ld8.acq
>> r16=[r15],8 */
>
> Yes, this is the same bit pattern Steve Ellcey and I came up with.

Ok.  I'll see about testing this and submitting a proper patch.

> This code does not need to be patched. The two words loaded here point
> to the dynamic loader's BOR routine. The dynamic loader must provide
> the proper values in the linkage table before the program can run;
> these values will not change, so the ordering isn't important. Adding
> an ld.acq here would unnecessarily slow the code down.

Ok, thanks for the clarification.

> I don't see anything wrong with you're reasoning, but changing this
> will have a binary compatibility impact, as the copy of gp to r14 is
> now part of the ABI, and will be present in inlined import stubs in
> existing .o files. I don't think gcc generates inlined import stubs at
> the moment, but I think Intel's compiler does.
>
> Too bad. It leaves me wondering why we didn't design it this way in
> the first place.

Understood.  I can still squeeze PLT0 down to two bundles by moving
the r2=r14 move into PLT1a, but I suspect that it only fits because
I didn't put in all the necessary stop bits.  Also it relies on being
able to express a relocation to PLT_RESERVE+8, which may not be
possible.  And I'm not sure whether this actually executes any faster.

(The idea is, since the ordering doesn't matter, to fetch the branch
target address first, and then the move to b6 can fit into that bundle -
but only if I don't need a stop bit between the load and the move to b6.)

.PLT0:
        addl    r2 = @gprel(plt_reserve+8), r2 ;;
        ld8     r17 = [r2], 8
        mov     b6 = r17
        ld8     r1 = [r2], -16
        ld8     r16 = [r2]
        br      b6 ;;
.PLT1:
        addl    r15 = @pltoff(name1), r1 ;;
        ld8.acq r16 = [r15], 8
        mov     r14 = r1 ;;
        ld8     r1 = [r15]
        mov     b6 = r16
        br      b6 ;;
.PLT1a:
        mov     r2 = r14
        mov     r15 = @iplt(name1)
        br      .PLT0 ;;

zw
