From: Andrew Morton <akpm@osdl.org>
Date: Tue, 15 Mar 2005 01:08:26 +0000
Subject: Re: Fix irq_affinity write from /proc for IPF
Message-Id: <20050314170826.26c1a7f4.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050314155004.A22573@unix-os.sc.intel.com>
	<20050314155923.4847aea3.akpm@osdl.org>
	<20050314162330.A22861@unix-os.sc.intel.com>
In-Reply-To: <20050314162330.A22861@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ashok Raj <ashok.raj@intel.com>
Cc: ashok.raj@intel.com, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, davidm@hpl.hp.com, hch@lst.de

Ashok Raj <ashok.raj@intel.com> wrote:
>
> > Is it not possible for ia64's ->set_affinity() handler to do this deferring?
> > 
> 
> There are other places where we re-program, and its fine to call the 
> current version of set_affinity directly, like when we are doing cpu offline
> and trying to force migrate irqs for ia64.
> 
> Changing the default set_affinity() for ia64 would result in many changes, 
> this still keeps the same purpose of those access functions, and 
> differentiates the proc write cases alone without changing the meaning 
> of those handler functions. (and a smaller patch)
> 
> this would further complicate the force migrate irq's when we consider 
> MSI interrupts as well. Since it would have its own set_affinity, and we need
> to hack into MSI's set affinity handler as well which would complicate things.

OK, just checking.

I'll include this change in the next batch, probably post-2.6.12-rc1, thanks.
