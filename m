From: Manfred Spraul <manfred@colorfullife.com>
Date: Thu, 31 Aug 2000 22:28:56 +0000
Subject: Re: [Linux-ia64] SMP TLB flushes
Message-Id: <marc-linux-ia64-105590678205436@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205428@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205428@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephan.Zeisset@intel.com wrote:
> 
> As for the ptc.g, the region id comes from the region register that
> is selected through bits [63:61] of the address.
> 

That means flush_tlb_range on SMP should

* acquire ptcg_lock
* change the region register to mm->...
* ptc.g
* restore the region register from current->active_mm->...
* release the spinlock.


Thanks for your answer,

	Manfred

