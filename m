From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Sat, 19 Mar 2005 20:22:20 +0000
Subject: RE: [patch] arch hook for notifying changes in PTE protections bits
Message-Id: <01EF044AAEE12F4BAAD955CB75064943033468DE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318200555.2d1980f6.davem@davemloft.net>
In-Reply-To: <20050318200555.2d1980f6.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davidm@hpl.hp.com

David S. Miller <mailto:davem@davemloft.net> wrote on Friday, March 18,
2005 8:06 PM:

> 
> Take a look at set_pte_at().  You get the "mm", the
> virtual address, the pte pointer, and the new pte value.
> 

Thanks for pointing out the updated interface in 2.6.12-* kernel.  I
think I can overload the arch specific part of set_pte_at(or for that
matter set_pte, as what I need is only pte_t) to always check if we need
to do lazy I/D coherency for IA-64.....but this incurs extra cost for
making a check every time set_pte_at is called.  This new hook,
lazy_mmu_prot_update, though needs to be used only when the permissions
on a valid PTE is changing. For example, at the time of remap or swap,
this API is not called.
  
> What else could you possibly need to track stuff like this
> and react appropriately? :-)
> 

Stuff is there, though the call needs to be made to ensure we are
reacting to it most optimally and correctly.....I guess something
similar to why update_mmu_cache API is still existing in generic part
and not overloading arch specific set_pte_at definition.


-rohit
