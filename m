From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Feb 2006 20:03:09 +0000
Subject: RE: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05BF6145@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> ia64: avoid broken SAL_CACHE_FLUSH implementations
>
> If SAL_CACHE_FLUSH drops interrupts, complain about it and fall back to
> using PAL_CACHE_FLUSH instead.
>
> This is to work around a defect in HP rx5670 firmware: when an interrupt
> occurs during SAL_CACHE_FLUSH, SAL drops the interrupt but leaves it marked
> "in-service", which leaves the interrupt (and others of equal or lower
> priority) masked.
>
> HP internal defect reports: F1859, F2775, F3031.

Sometimes I forget to test patches against my zx2000 workstation (because
it is such a pain to restart all my apps after I reboot).  This patch
slipped through.  My zx2000 hasn't been booting since 2.6.15 and I
finally spent the time to track down why.  It hangs (or dies) inside
check_sal_cache_flush() :-(

-Tony
