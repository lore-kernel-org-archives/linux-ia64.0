From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 May 2007 16:50:19 +0000
Subject: RE: Fix section conflict of ia64_mlogbuf_finish
Message-Id: <617E1C2C70743745A92448908E030B2A01785DF3@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070515164202.GA19839@deprecation.cyrius.com>
In-Reply-To: <20070515164202.GA19839@deprecation.cyrius.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  CC      arch/ia64/kernel/mca.o
> arch/ia64/kernel/mca.c:275: error: __ksymtab_ia64_mlogbuf_finish causes a section type conflict
>
> This is because ia64_mlogbuf_finish is both declared static and exported.

Why is it exported?  mca_drv.c (our only mca related module) doesn't
use it.  Perhaps the fix should be to drop the EXPORT?

-Tony
