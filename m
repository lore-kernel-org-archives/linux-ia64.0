From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Sep 2009 23:27:15 +0000
Subject: RE: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E038DE7E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
 <20090828062212.GB11552@elte.hu>
In-Reply-To: <20090828062212.GB11552@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Luming Yu <luming.yu@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Felix Blyakher <felixb@sgi.com>, "Li, Shaohua" <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

>> diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/page.h
>> linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/page.h
>> --- linux-2.6.31-rc6/arch/ia64/include/asm/page.h	2009-08-13
>> 15:43:34.000000000 -0700
>> +++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/page.h	2009-08-23
>> 18:59:00.000000000 -0700
>> @@ -41,7 +41,7 @@
>>  #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
>>  #define PAGE_MASK		(~(PAGE_SIZE - 1))
>> 
>> -#define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
>> +#define PERCPU_PAGE_SHIFT	20	/*16 log2() of max. size of per-CPU area */
>>  #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
>
> Why was this seemingly unrelated change done in a lockdep patch?

IIRC it is because the lockdep code needs a lot more percpu memory than the
64K that ia64 allocates.

But I think that I'd prefer to only allocate the extra space when it
is needed:

#ifdef CONFIG_LOCKDEP
#define PERCPU_PAGE_SHIFT 20 /* Need a Megabyte for lockdep */
#else
#define PERCPU_PAGE_SHIFT 16 /* 64K should be enough for normal use */
#endif

-Tony


