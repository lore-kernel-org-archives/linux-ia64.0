From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Nov 2005 16:11:18 +0000
Subject: Re: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <20051122161118.GA28064@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1132548798.1478.7.camel@localhost.localdomain> <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Tian, Kevin" <kevin.tian@intel.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Xen Mailing List <xen-devel@lists.xensource.com>, Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, linux-ia64@vger.kernel.org

This comment:
>   /*
>    * The "aligned" directive can only _increase_ alignment, so this is
>    * safe and provides an easy way to avoid wasting space on a
>    * uni-processor:
>    */
suggests that we only expected SMP_CACHE_BYTES to be used in "aligned"
directives, where having a smaller value than the actual alignment
requirement of some object would simply be ignored by the compiler.

A search for SMP_CACHE_BYTES across the kernel picks up a few drivers
that don't follow this usage model.   E.g. drivers/net/acenic.c might
print a warning about unsupported cache line size on a UP ia64.

Your usage:
	BUG_ON(align > SMP_CACHE_BYTES);

is another instance of this define being used in a way that ia64
didn't expect (it appears that only ia64 has this space saving
trick in the definition of SMP_CACHE_BYTES ... so it is unsurprising
that general users are not following our usage model).

How much is this trick saving us?  Static size of data area in
vmlinux doesn't change very much as SMP_CACHE_BYTES is varied:

   text    data     bss     dec     hex filename
8677481 1139704 1206357 11023542         a834b6 vmlinux-8
8677417 1141808 1206397 11025622         a83cd6 vmlinux-16
8677417 1146000 1206477 11029894         a84d86 vmlinux-32
8677353 1146256 1206573 11030182         a84ea6 vmlinux-64
8677353 1163152 1207085 11047590         a892a6 vmlinux-128

I'm not sure how to evaluate dynamic behavior (allocation of
structures whose size is dependent on SMP_CACHE_BYTES at
runtime).

-Tony
