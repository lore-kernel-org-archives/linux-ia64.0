From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 13 Jul 2005 01:59:50 +0000
Subject: Re: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42D475D7.2090307@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB6961.2060508@jp.fujitsu.com> <20050712211401.GF26607@austin.ibm.com>
In-Reply-To: <20050712211401.GF26607@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Linas Vepstas wrote:
> On Wed, Jul 06, 2005 at 02:17:21PM +0900, Hidetoshi Seto was heard to remark:
> 
>>Touching poisoned data become a MCA, so now it directly means
> 
> Several questions: 
> 
> Is MCA an exception or fault of some sort, so at some point, 
> the kernel would catch a fault?
> 
> So when you say "Touching poisoned data become a MCA", you mean that
> if the CPU attempts to read poisoned data through the pci-to-host
> bridge, it will (at some point) catch an exception?

Yes.
More specifically, transferring poisoned data doesn't cause MCA,
but loading it to CPU register cause MCA. At the end of load,
CPU checks the data and deliver MCA if it was poisoned.

>>+	ia64_mca_barrier(ret);
> 
> I assume that the point of this barrier is to make sure that the fault,
> if any, is delivered before this routine returns?

Yes, that's what I expecting.

Thanks,
H.Seto

