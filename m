From: markw@osdl.org
Date: Mon, 29 Mar 2004 16:50:42 +0000
Subject: Re: [HACKERS] PostgreSQL block size vs. LVM2 stripe width
Message-Id: <200403291650.i2TGop212446@mail.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <06sb60hni6h5cok941gqnuo4ld1b0v1rgi@email.aon.at>
References: <06sb60hni6h5cok941gqnuo4ld1b0v1rgi@email.aon.at>
In-Reply-To: <06sb60hni6h5cok941gqnuo4ld1b0v1rgi@email.aon.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mkoi-pg@aon.at
Cc: linux-lvm@redhat.com, linux-ia64@vger.kernel.org, pgsql-hackers@postgresql.org

Hi Manfred,

On 27 Mar, Manfred Koizar wrote:
> Mark,
> 
> how often did you run your tests?  Are the results reproduceable?

In this case, I've only done 1 per each combination.  I've found the
results for this test to be reproduceable.
 
> On Fri, 26 Mar 2004 14:00:01 -0800 (PST), markw@osdl.org wrote:
>>                        Linux-2.6.3, LVM2 Stripe Width
>>                        (going across)
>>PostgreSQL
>>BLCKSZ
>>(going down)    16 KB   32 KB   64 KB   128 KB  256 KB  512 KB
>>2 KB            2617    2656    2652    2664    2667    2642
>>4 KB            4393    4486    4577    4557    4511    4448
>>8 KB            4337    4423    4471    4576    4111    3642
>>16 KB           4412    4495    4532    4536    2985    2312
>>32 KB           3705    3784    3886    3925    2936    2362
> 
> Unless someone can present at least an idea of a theory why a BLCKSZ of
> 8 KB is at a local minimum (1 or 2% below the neighbouring values) for
> stripe widths up to 64 KB I'm not sure whether we can trust these
> numbers.
> 
> Before I hit the send button, I did a quick check of the link you
> provided.  The links in the table contain the following test numbers:
> 
>         16 KB   32 KB   64 KB   128 KB  256 KB  512 KB
> 2 KB     72      71      70       69      66      65
> 4 KB     64      63      62       61      60      58
> 8 KB     54      53      52       51      50      49
> 16 KB    79      78      77       76      75      74
> 32 KB    86      85      84       83      82      80
> 
> Does this mean that you first ran all test with 8 KB, then with 4, 2, 16
> and 32 KB BLCKSZ?  If so, I suspect that you are measuring the effects
> of something different.

Yes, that's correct, but why do you suspect that?

Mark
