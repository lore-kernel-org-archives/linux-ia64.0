From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 16 Jan 2008 06:26:21 +0000
Subject: Re: [patch 1/3] IA64: Slim down __clear_bit_unlock #2
Message-Id: <200801161726.22213.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
In-Reply-To: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 16 January 2008 00:15, Zoltan Menyhart wrote:
> Please have a look at the patch below.
>
> Taking this opportunity, in addition:
> - I removed the unnecessary barrier() from __clear_bit_unlock().
>   ia64_st4_rel_nta() makes sure all the modifications are globally
>   seen before the bit is seen to be off.
> - I made __clear_bit() modeled after __set_bit() and __change_bit().
> - I corrected some comments sating that a memory barrier is provided,
>   yet in reality, it is the acquisition side of the memory barrier only.
> - I corrected some comments, e.g. test_and_clear_bit() was peaking
>   about "bit to set".
>
> Here is the code generated from my and the old versions.
> (Though I do not know why "and" is moved in the 2nd bundle.):
>
> test_new()
> {
>         __clear_bit_unlock(3, &data);
> }
>
> test_old()
> {
>         old__clear_bit_unlock(3, &data);
> }
>
> 0000000000000000 <test_new>:
>    0:   02 00 00 00 01 00       [MII]       nop.m 0x0
>    6:   e0 00 04 00 48 00                   addl r14=0,r1;;
>    c:   00 00 04 00                         nop.i 0x0
>   10:   0b 10 00 1c 10 10       [MMI]       ld4 r2=[r14];;
>   16:   f0 b8 0b 58 44 00                   and r15=-9,r2
>   1c:   00 00 04 00                         nop.i 0x0;;
>   20:   0a 00 3c 1c b6 11       [MMI]       st4.rel.nta [r14]=r15;;
>   26:   00 00 00 02 00 00                   nop.m 0x0
>   2c:   01 70 00 84                         mov r8=r14
>   30:   1d 00 00 00 01 00       [MFB]       nop.m 0x0
>   36:   00 00 00 02 00 80                   nop.f 0x0
>   3c:   08 00 84 00                         br.ret.sptk.many b0;;
>
> 0000000000000040 <test_old>:
>   40:   02 00 00 00 01 00       [MII]       nop.m 0x0
>   46:   e0 00 04 00 48 00                   addl r14=0,r1;;
>   4c:   00 00 04 00                         nop.i 0x0
>   50:   03 10 00 1c b0 10       [MII]       ld4.acq r2=[r14]
>   56:   00 00 00 02 00 e0                   nop.i 0x0;;
>   5c:   71 17 b0 88                         and r15=-9,r2;;
>   60:   0a 00 3c 1c b6 11       [MMI]       st4.rel.nta [r14]=r15;;
>   66:   00 00 00 02 00 00                   nop.m 0x0
>   6c:   01 70 00 84                         mov r8=r14
>   70:   1d 00 00 00 01 00       [MFB]       nop.m 0x0
>   76:   00 00 00 02 00 80                   nop.f 0x0
>   7c:   08 00 84 00                         br.ret.sptk.many b0;;
>
> Signed-off-by: Zoltan Menyhart, <Zoltan.Menyhart@bull.net>

I don't see any problem with this patch.
FWIW:
Acked-by: Nick Piggin <npiggin@suse.de>
