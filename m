From: "Zhu, Yi" <yi.zhu@intel.com>
Date: Wed, 31 Mar 2004 05:58:38 +0000
Subject: RE: realfeel4 for libpfm-3.0
Message-Id: <3ACA40606221794F80A5670F0AF15F8403BD53C5@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F842DB199@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F842DB199@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> I looked at your ported version of realfeel4.c. There were three
> problems with it: 
> 
> 	- with the new perfmon interface, a system-wide context
> 	  is not automatically pinned to a CPU. You need an
> 	  explicit call to sched_setaffinity(). The perfmonctl()
> 	  calls, in this case, are only authorized from when the
> 	  calling tasking is running on the CPU that was used when
> 	  PFM_LOAD_CONTEXT was issued. To avoid problems it is always
> 	  best to explicitely call sched_setaffinity() prior to

> PFM_LOAD_CONTEXT. 
> 
> 	- for system-wide context, you currently cannot use
> 	  pfm_self_start()/pfm_self_stop() which are lighweight
> 	  versions of PFM_START/PFM_STOP. I am hoping to remove
this
> restrictions soon. 
> 
> 	- You had two calls to PFM_RESTART in you overflow handler.
> 
> The attached program does work for me.


Thank you very much Stephane and Peter!

I make the realfeel4 work with the modified realfeel4n.c and Peter's tip
to
disable CONFIG_IA64_PAL_IDLE.

Thanks,
-yi
