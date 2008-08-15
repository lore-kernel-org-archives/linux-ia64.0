From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 Aug 2008 16:11:04 +0000
Subject: RE: ia64 allmodconfig on current mainline
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309B828E1@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080812150608.231a948a.akpm@linux-foundation.org>
 <200808130022.50501.rjw@sisk.pl>
 <20080812155806.4e8554a9.akpm@linux-foundation.org>
 <57C9024A16AD2D4C97DC78E552063EA30844B247@orsmsx505.amr.corp.intel.com>
 <20080815120113.GN6824@sgi.com>
In-Reply-To: <20080815120113.GN6824@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> of per_cpu__kmem_cache_cpu at 0x28a0.  A couple other low-hanging fruit
> here are per_cpu__shadow_flush_counts and per_cpu__mmu_gathers each of
> which takes approx 16k.

Ah.  That perhaps explains the recent jump in usage that has put
allmodconfig over the limit.  mmu_gathers is an int[NR_CPUS], and
NR_CPUS was just raised from 1024 to 4096

-Tony
