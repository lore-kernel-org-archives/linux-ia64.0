From: Manfred Koizar <mkoi-pg@aon.at>
Date: Mon, 29 Mar 2004 22:42:54 +0000
Subject: Re: [HACKERS] PostgreSQL block size vs. LVM2 stripe width
Message-Id: <5r5h60pus29i6hf4eftka319gmqlrd6ies@email.aon.at>
List-Id: <linux-ia64.vger.kernel.org>
References: <06sb60hni6h5cok941gqnuo4ld1b0v1rgi@email.aon.at>
	<200403291650.i2TGop212446@mail.osdl.org>
In-Reply-To: <200403291650.i2TGop212446@mail.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: markw@osdl.org
Cc: linux-lvm@redhat.com, linux-ia64@vger.kernel.org, pgsql-hackers@postgresql.org

On Mon, 29 Mar 2004 08:50:42 -0800 (PST), markw@osdl.org wrote:
>In this case, I've only done 1 per each combination.  I've found the
>results for this test to be reproduceable.

Pardon?

>>>                        Linux-2.6.3, LVM2 Stripe Width
>>>BLCKSZ
>>>(going down)    16 KB   32 KB   64 KB   128 KB  256 KB  512 KB
>>>2 KB            2617    2656    2652    2664    2667    2642
>>>4 KB            4393    4486    4577    4557    4511    4448
>>>8 KB            4337    4423    4471    4576    4111    3642
>>>16 KB           4412    4495    4532    4536    2985    2312
>>>32 KB           3705    3784    3886    3925    2936    2362

>> Does this mean that you first ran all test with 8 KB, then with 4, 2, 16
>> and 32 KB BLCKSZ?  If so, I suspect that you are measuring the effects
>> of something different.
>
>Yes, that's correct, but why do you suspect that?

Gut feelings, hard to put into words.  Let me try:

Nobody really knows what the "optimal" BLCKSZ is.  Most probably it
depends on the application, OS, hardware, and other factors.  8 KB is
believed to be a good general purpose BLCKSZ.

I wouldn't be surprised if 8 KB turns out to be suboptimal in one or the
other case (or even in most cases).  But if so, I would expect it to be
either too small or too large.

In your tests, however, there are three configurations where 8 KB is
slower than both 4 KB and 16 KB.  Absent any explanation for this
interesting effect, it is easier to mistrust your numbers.

If you run your tests in the opposite order, on the same hardware, in
the same freshly formatted partitions, and you get the same results,
that would be an argument in favour of their accurancy.

Maybe we find out that those 1.5% are just noise.

Servus
 Manfred
