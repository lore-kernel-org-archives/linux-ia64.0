From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Dec 2007 23:25:46 +0000
Subject: RE: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <617E1C2C70743745A92448908E030B2A03187988@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Oh well, whatever.  Please treat this as a bug report.
>
> ie: someone please fix it.

Perhaps with?

-	-$(Q)READELF=$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
+	-$(Q)READELF=$(READELF) python $(srctree)/arch/ia64/scripts/unwcheck.py $<
