From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 27 Oct 2005 18:41:13 +0000
Subject: RE: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04CC08DF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014195554.GA21639@sgi.com>
In-Reply-To: <20051014195554.GA21639@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Roe <roe@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org

>flush_tlb_range() only calls platform_global_tlb_purge() for CONFIG_SMP,
>so there's no point in having that code in ia64_global_tlb_purge().

So you have dropped the "mm->context = 0;" for the UP case (and replaced
it with a series of ia64_ptcl() calls).

To maintain the old behaivour you need to have:

#ifndef SMP
	if (mm != current->active_mm) {
		mm->context = 0;
		return;
	}
#endif

in the start of flush_tlb_range().


-Tony
