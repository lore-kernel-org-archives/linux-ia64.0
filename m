From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 04 Feb 2006 00:32:45 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F059F4C35@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> mca_asm.S, GET_IA64_MCA_DATA().  ia64_mca_data is per cpu and is
> accessed right from the start of the MCA/INIT handlers, with psr.i,
> psr.ic both 0.

But PSR.dt is also zero, and we are accessing via the physical address
(using ar.k3).  Right?  At the start of the mca/init handlers we don't
trust that the TLB is working.

-Tony
