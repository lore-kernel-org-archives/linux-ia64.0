From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 08 Aug 2006 17:44:24 +0000
Subject: RE: Silent data corruption caused by XPC V2.
Message-Id: <617E1C2C70743745A92448908E030B2A57D867@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807174933.GB24663@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+	/* ensure that the physically mapped memory is contiguous */
+	DBUG_ON(REGION_NUMBER(vdst) != RGN_KERNEL &&
+		REGION_NUMBER(vdst) != RGN_UNCACHED &&
+		PAGE_SIZE - (vdst & ~PAGE_MASK) < len);
 
I thought that part of the point of this patch was that
by using kmalloc() for the buffer, you actually guaranteed
that the whole thing is contiguous (since kmalloc will give
you an order(N) page for requests greater than a page.

This test is a bit convoluted, but looks it will ping you
whenever a transfer crosses a page boundary, regardless of
whether the pages are contiguous or not.  Certainly the
comment seems tenuously connected to the code.

-Tony
