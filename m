From: Christoph Lameter <christoph@engr.sgi.com>
Date: Wed, 03 May 2006 23:54:20 +0000
Subject: Re: RFC: RCU protected page table walking
Message-Id: <Pine.LNX.4.64.0605031649400.32117@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4458CCDC.5060607@bull.net> <200605031846.51657.ak@suse.de>
 <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kenneth.w.chen@intel.com
Cc: Hugh Dickins <hugh@veritas.com>, Andi Kleen <ak@suse.de>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr, linux-i64@vger.kernel.org

On Wed, 3 May 2006, Hugh Dickins wrote:

> Those architectures (including i386 and x86_64) which #define their
> __pte_free_tlb etc. to tlb_remove_page are safe as is.  But Zoltan's
> ia64 #defines it to pte_free, which looks like it may free_page before
> the TLB flush.  But it is surprising if it has actually been unsafe

Sorry but I am in .au right now with spotty high latency connectivity. 
But the people on linux-ia64 should know. Ken?

Why was linux-ia64 not cced??
