From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 12 Mar 2007 22:08:32 +0000
Subject: RE: [Patch] min_low_pfn and max_low_pfn calcultion fix
Message-Id: <617E1C2C70743745A92448908E030B2A01390760@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1172619535.20006.334.camel@linux-znh>
In-Reply-To: <1172619535.20006.334.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I tested on 2.6.21-rc3 with DEBUG_VM turned on. The vanilla 2.6.21-rc3
> without Nan-hai's patch, panicked on bugcheck on free_initmem->free_page
> as predicted. We still need this patch.

I've applied Nan hai's patch ... will push upstream in a little while.

> However, the zero-size vmcore problem is back on SN. But that is a
> differnet problem.

I applied a fix that was supposed to fix this after -rc3.  It is
in Linus' tree now.  Let me know if it really is still broken.

-Tony
