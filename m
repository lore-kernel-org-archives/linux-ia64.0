From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 23 Nov 2005 17:49:05 +0000
Subject: RE: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <516F50407E01324991DD6D07B0531AD5875C34@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Keir Fraser <Keir.Fraser@cl.cam.ac.uk>, "Tian, Kevin" <kevin.tian@intel.com>
Cc: Xen Mailing List <xen-devel@lists.xensource.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-ia64@vger.kernel.org, Tony Breeds <tony@bakeyournoodle.com>, David Mosberger-Tang <David.Mosberger@acm.org>

> Subject: RE: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix 
> ar.unat handling forfast paths"
> 
> >It's not hard to support arbitrary alignment, at the cost of burning 
> >some space. We should probably do that.
> 
> The "we" in that last sentence is the Xen team ... referring
> to making fixes to xmalloc?
> 
> -Tony

Since this thread is cross-posted to two lists neither one of which
is xen-ia64-devel, a short explanation might be in order:

Since there a fair overlap of functionality, Xen/ia64 heavily
leverages Linux and Linux/ia64 code.  About 120 .c/.h files are
100% reused from linux-2.6.13 and another 36 files are
reused but require small patches (total of ~120 chunks, mostly
1-2 line diffs).  The leveraged files are periodically updated
to use the latest version of linux (started with 2.6.7, then 2.6.9,
now 2.6.13); this allows Xen/ia64 to easily pick up new functionality
and bug fixes from Linux/ia64 without reinventing the wheel.

HOWEVER, one disadvantage is that some bugs in Linux get inherited
by Xen/ia64.  As Tony previously noted, Linux/ia64 makes some
assumptions about SMP_CACHE_BYTES which are not adhered to throughout
Linux.  Xen apparently does not adhere to those assumptions either.
Xen/ia64 will need to add another patch to the (previously unchanged)
file linux/include/asm-ia64/cache.h.  Presumably this should
be fixed in Linux/ia64 as well and the file will be resynced
in the future.

Hope that helps!

Dan
