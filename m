From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 03 Mar 2005 05:51:43 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.58.0503022149210.4272@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
 <20050302174507.7991af94.akpm@osdl.org> <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
 <20050302185508.4cd2f618.akpm@osdl.org> <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
 <20050302201425.2b994195.akpm@osdl.org> <16934.39386.686708.768378@cargo.ozlabs.ibm.com>
 <20050302213831.7e6449eb.davem@davemloft.net>
In-Reply-To: <20050302213831.7e6449eb.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: Paul Mackerras <paulus@samba.org>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, benh@kernel.crashing.org, anton@samba.org

On Wed, 2 Mar 2005, David S. Miller wrote:

> Actually, I guess I could do the pte_cmpxchg() stuff, but only if it's
> used to "add" access.  If the TLB miss handler races, we just go into
> the handle_mm_fault() path unnecessarily in order to synchronize.
>
> However, if this pte_cmpxchg() thing is used for removing access, then
> sparc64 can't use it.  In such a case a race in the TLB handler would
> result in using an invalid PTE.  I could "spin" on some lock bit, but
> there is no way I'm adding instructions to the carefully constructed
> TLB miss handler assembler on sparc64 just for that :-)

There is no need to provide pte_cmpxchg. If the arch does not support
cmpxchg on ptes (CONFIG_ATOMIC_TABLE_OPS not defined)
then it will fall back to using pte_get_and_clear while holding the
page_table_lock to insure that the entry is not touched while performing
the comparison.
