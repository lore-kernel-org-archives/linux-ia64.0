From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Sep 2004 16:28:58 +0000
Subject: RE: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020512EB@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
In-Reply-To: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Unless anyone has a better solution, I think Keith's suggestion is the
>next best alternative.  It is no worse than the current code 
>(in terms of off-node access) and allows forward progress on the rest
>of the code.

Take a look at the MCA-TLB recovery code.  It saves per-cpu
information in the "ia64_mca_tlb_list[]" array, and searches
through it for an entry that matches cr.lid at fault time.

You could add extra element(s) to this structure for the percpu
areas.

-Tony
