From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 03 Mar 2005 05:54:08 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <1109829248.5679.178.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
	 <20050302174507.7991af94.akpm@osdl.org>
	 <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
	 <20050302185508.4cd2f618.akpm@osdl.org>
	 <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
	 <20050302201425.2b994195.akpm@osdl.org>
	 <16934.39386.686708.768378@cargo.ozlabs.ibm.com>
	 <20050302213831.7e6449eb.davem@davemloft.net>
In-Reply-To: <20050302213831.7e6449eb.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Anton Blanchard <anton@samba.org>


> However, if this pte_cmpxchg() thing is used for removing access, then
> sparc64 can't use it.  In such a case a race in the TLB handler would
> result in using an invalid PTE.  I could "spin" on some lock bit, but
> there is no way I'm adding instructions to the carefully constructed
> TLB miss handler assembler on sparc64 just for that :-)

Can't you add a lock bit in the PTE itself like we do on ppc64 hash
refill ?

Ok, ok, you don't want to add instructions, fair enough :) On ppc64, I
had to do that to close some nasty race we had in the hash refill, but
it came almost for free as we already had an atomic loop in there.

Ben.


