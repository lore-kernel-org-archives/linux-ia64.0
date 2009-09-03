From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Sep 2009 16:02:52 +0000
Subject: RE: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E038E14B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
	 <20090828062212.GB11552@elte.hu>
	 <57C9024A16AD2D4C97DC78E552063EA3E038DE7E@orsmsx505.amr.corp.intel.com>
 <1251967590.7447.0.camel@twins>
In-Reply-To: <1251967590.7447.0.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>, Luming Yu <luming.yu@gmail.com>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Felix Blyakher <felixb@sgi.com>, "Li, Shaohua" <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

> > #ifdef CONFIG_LOCKDEP
> > #define PERCPU_PAGE_SHIFT 20 /* Need a Megabyte for lockdep */
> > #else
> > #define PERCPU_PAGE_SHIFT 16 /* 64K should be enough for normal use */
> > #endif
> 
> Hmm, isn't all that percpu stuff in a special section, who's size you
> can query at boot time and set-up accordingly?

The size is a build time parameter (must match with a supported TLB page
size for ia64 ... i.e. even power of two ... so 64K, 256K, 1M, 4M are all
possible, but 128K, 512K, 2M, ... are not).

Any code that includes the right header files can look at PERCPU_PAGE_SHIFT
(or PERCPU_PAGE_SIZE) and make decisions about things.  But in the
lockdep case the extra percpu space is statically allocated, so the special
section overflows and results in a build failure.

-Tony



