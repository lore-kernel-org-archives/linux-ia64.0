From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 14 May 2009 15:31:32 +0000
Subject: Re: [PATCH] Fix Intel IOMMU Compilation Warnings on IA64
Message-Id: <20090514153132.GS15360@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090327212241.234500000@intel.com> <20090327212321.070229000@intel.com> <20090416001957.GA1527@linux-os.sc.intel.com> <1240135508.3589.75.camel@macbook.infradead.org> <A6AD88C3F2289247BE726C37303E1EB8A4DF7DB1@orsmsx505.amr.corp.intel.com> <20090513231351.GA22386@linux-os.sc.intel.com> <1242314271.3393.11.camel@macbook.infradead.org>
In-Reply-To: <1242314271.3393.11.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>, 'Tony Luck' <tony.luck@intel.com>, 'lkml' <linux-kernel@vger.kernel.org>, 'iommu' <iommu@lists.linux-foundation.org>, 'ia64' <linux-ia64@vger.kernel.org>

On Thu, May 14, 2009 at 04:17:51PM +0100, David Woodhouse wrote:
> Perhaps this would be better, modelled after commit fe333321:
>  
> +#ifdef __KERNEL__
> +#include <asm-generic/int-ll64.h>
> +#else
>  #include <asm-generic/int-l64.h>
> +#endif

It's certainly something I've been lobbying for for a while.  There's
various new warnings that crop up, and I wasn't able to log into the
system Tony offered me to fix it on.  Maybe someone who cares about ia64
these days could take care of fixing up the remaining warnings?

I see http://kerneltrap.org/mailarchive/linux-ia64/2008/10/19/3945454
is out there.  There might be a more recent version ... somewhere ...
Perhaps Tony has a copy of it?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
