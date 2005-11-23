From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Date: Wed, 23 Nov 2005 08:54:46 +0000
Subject: Re: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <a2a560aa9aa53494165df9ccdb7d8d4e@cl.cam.ac.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C069E3@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069E3@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Tian, Kevin" <kevin.tian@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, Xen Mailing List <xen-devel@lists.xensource.com>, David Mosberger-Tang <David.Mosberger@acm.org>


On 23 Nov 2005, at 02:58, Tian, Kevin wrote:

> Now I think even '16' can't cover all cases. It's possible for a user 
> defined structure with .align directive to force by '32' or larger, 
> and then allocator happens to have similar check upon SMP_CACHE_BYTES 
> like case in this thread. Because both structure definition and 
> allocator may have no idea about IA64 trick of saving space for UP. 
> Max alignment of any C style only solves the natural alignment case, 
> but not above forced one. We can just give its real assumption to 
> SMP_CACHE_BYTES - cache line size. ;-)

It's not hard to support arbitrary alignment, at the cost of burning 
some space. We should probably do that.

  -- Keir

