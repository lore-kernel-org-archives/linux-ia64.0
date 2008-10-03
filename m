From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 03 Oct 2008 08:54:50 +0000
Subject: Re: [PATCH 1/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <20081003085450.GA27551@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com> <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com> <20081001165725.GA21559@linux-os.sc.intel.com> <20081002082942.GA26084@elte.hu> <A6AD88C3F2289247BE726C37303E1EB88408AE54@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB88408AE54@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>


* Yu, Fenghua <fenghua.yu@intel.com> wrote:

> >What's this all about?  Why do we need #ifdef CONFIG_IA64 here? 
> >Doesn't x86 provide its own readq/writeq implementation?
> 
> This is a comment from Bjorn.
> 
> In my patch, one readq/one writeq are working faster than two 
> readl/two writel on IA64. X86 uses two readl/two writel so that the 
> code works on both x86 and x86-64 although Intel IOMMU only has x86-64 
> version currently. dmar_readq() and dmar_writeq() are in moderate 
> performance critical path.
> 
> Do you think my current implementation is ok to have #ifdef 
> CONFIG_IA64 here? Or I can change X86 to use readq/writeq as well or 
> IA64 uses two readl/two writel for clean code?

yes, clean code is very much preferred for a small detail like this.

	Ingo
