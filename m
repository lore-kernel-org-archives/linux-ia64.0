From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Sun, 20 Mar 2005 22:38:11 +0000
Subject: RE: [patch] arch hook for notifying changes in PTE protections bits
Message-Id: <01EF044AAEE12F4BAAD955CB7506494303346A10@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318200555.2d1980f6.davem@davemloft.net>
In-Reply-To: <20050318200555.2d1980f6.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, davidm@hpl.hp.com
Cc: davidm@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

David S. Miller <mailto:davem@davemloft.net> wrote on Saturday, March
19, 2005 4:27 PM:

> On Sat, 19 Mar 2005 12:30:05 -0800
> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> 
>> I agree about your concern about cost.  Accessing the page_map is
>> expensive (integer division + memory access) and we have to do that
>> in order to find out if the page is i-cache clean.
> 
> First, it's a multiply by reciprocol.  At least on sparc64 I get
> this emitted by the compiler.
> 
> Secondly, if you're willing to sacrifice 8 bytes per page struct
> simply define WANT_PAGE_VIRTUAL and page struct will be exactly
> 64 bytes and thus the divide a will turn into a simple shift.

As said earlier, set_pte_at is getting called from different places.
Not all of these times, we are actually installing valid page entries in
page tables.  Validating the incoming entry for all of these scenarois
(or changing page struct) is an extra overhead that should be
avoided...besides being less palatable as compared to new API.

The recent changes in interfaces, because of set_pte_at, does provide an
opportunity though to handle mprotect issue little differently.  We
could call update_mmu_cache after setting the new protections in
change_pte_range function.....similar to the way update_mmu_cache gets
called at fault and any other times......though for this solution, we
need to extend change_pte_range interface to have vma parameter as well.



-rohit
