From: Keith Owens <kaos@sgi.com>
Date: Thu, 16 Sep 2004 11:44:33 +0000
Subject: Re: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <2828.1095335073@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
In-Reply-To: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Sep 2004 09:28:58 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>Unless anyone has a better solution, I think Keith's suggestion is the
>>next best alternative.  It is no worse than the current code 
>>(in terms of off-node access) and allows forward progress on the rest
>>of the code.
>
>Take a look at the MCA-TLB recovery code.  It saves per-cpu
>information in the "ia64_mca_tlb_list[]" array, and searches
>through it for an entry that matches cr.lid at fault time.
>
>You could add extra element(s) to this structure for the percpu
>areas.

What about storing the physical address of the per-cpu data area in
ar.k3?

AFAICT we can also reclaim ar.k5 (FPU_OWNER), that field is rarely used
and can be moved to the per_cpu data area.

