From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Nov 2005 07:01:15 +0000
Subject: RE: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F050B5616@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Cc: linux-ia64@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Tony Breeds <tony@bakeyournoodle.com>, Xen Mailing List <xen-devel@lists.xensource.com>, djm@kirby.fc.hp.com, "Tian, Kevin" <kevin.tian@intel.com>, David Mosberger-Tang <David.Mosberger@acm.org>

>So it makes most sense for ia64 Xen to define SMP_CACHE_BYTES to a 
>sensible largeish number irrespective of CONFIG_SMP (after all, how 
>many uniproc ia64 systems are there), and solve the general alignment 
>problem in xmalloc only if we really need to.

Changing from 8 to 16 (as David suggested) looks to be the right
thing to do.  If you think it needs to be higher than this, then
I'll need some more convincing.

-Tony
