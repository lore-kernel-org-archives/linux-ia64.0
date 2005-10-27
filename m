From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 27 Oct 2005 16:01:53 +0000
Subject: RE: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04C8CF40@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014195554.GA21639@sgi.com>
In-Reply-To: <20051014195554.GA21639@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Roe <roe@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org

-	if (mm != current->active_mm) {
-		/* this does happen, but perhaps it's not worth optimizing for? */
-#ifdef CONFIG_SMP
-		flush_tlb_all();
-#else
-		mm->context = 0;
-#endif
-		return;
-	}

Your patch moves this secion of code up to ia64_global_tlb_purge(),
but the new code that is added there doesn't include the UP case
where mm->context is set to zero.

-Tony
