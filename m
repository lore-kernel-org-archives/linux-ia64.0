From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 25 Oct 2007 08:46:15 +0000
Subject: Re: [PATCH] IA64/perfmon: kill dead code, clean irq handling
Message-Id: <20071025084615.GA32656@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071023230908.GA12417@havoc.gtf.org>
In-Reply-To: <20071023230908.GA12417@havoc.gtf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, joshua.i.stone@intel.com, juan.villacis@intel.com

Jeff,

On Tue, Oct 23, 2007 at 07:09:08PM -0400, Jeff Garzik wrote:
> 
> By deleting unused code, this makes perfmon irq handling more efficient,
> as well as reducing code size.
> 
> * remove unused pfm_install_alt_pmu_interrupt()
> * remove unused pfm_remove_alt_pmu_interrupt()
> 
I have not problem with the patch except maybe for those two functions.
How do you know they are not used?
Have you checked the VTUNE open-source driver?
I thought at some point they were using this hook.


> * remove now-unused pfm_alt_intr_handler pointer, and associated
>   function call in perfmon interrupt handler.
> 
> * remove unused 'irq' argument from pfm_do_interrupt_handler()
> 
> * un-indent code in pfm_interrupt_handler() now that
>   pfm_alt_intr_handler is no longer used.
> 
--
-Stephane
