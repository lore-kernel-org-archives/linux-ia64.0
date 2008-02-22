From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 03:54:57 +0000
Subject: Re: [PATCH 13/28] ia64/xen: introduce xen hypercall routines necessary for domU.
Message-Id: <20080222035457.GB2406%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BE0D7E.7080301@goop.org>
In-Reply-To: <47BE0D7E.7080301@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 21, 2008 at 03:47:10PM -0800, Jeremy Fitzhardinge wrote:
> yamahata@valinux.co.jp wrote:
> >+static inline unsigned long
> >+HYPERVISOR_machtophys(unsigned long mfn)
> >+{
> >+	unsigned long ret = mfn;
> >+	if (is_running_on_xen())
> >  
> 
> Do you often call hypercalls when not booting under Xen?  It seems to me 
> this check should have already been done at a higher layer, and it 
> needn't be repeated here.

IA64 pv_ops frame work doesn't exist yet so that xen code does
in order to boot on both native and xen for now.
I expect those check will be eliminated during developing ia64 pv_ops.

-- 
yamahata
