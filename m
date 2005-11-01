From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 01 Nov 2005 00:46:23 +0000
Subject: RE: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04D4C978@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+#define pfn_to_kaddr(pfn) 	__va((pfn) << PAGE_SHIFT)
> 
> #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
> #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)

Almost identical to Bob Picco's fix.  He put exactly the same
definition for pfn_to_kaddr() three lines further down ... and
since he got there first, his patch is going in.

But thanks for confirming.

-Tony
 
