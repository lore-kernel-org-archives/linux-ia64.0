From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 26 Aug 2004 21:20:07 +0000
Subject: Re: Long Format VHPT patches
Message-Id: <16686.21511.721755.137564@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Lameter <christoph@lameter.com> writes:

Christoph> One issue that bothers me is that it is no longer possible
Christoph> to swap pte, pmd and pgd entries via cmpxchg. My page fault
Christoph> scalability patches are based on that ability. The Itanium
Christoph> can only do a cmpxchg with a 64 bit value.  The long VHPT
Christoph> entries are 32 bytes long.

I don't think that that's an issue at present: in our patch, the
hardware-walked long format VHPT is used as a cache of the existing
linux 3-level table, kind of like a software loaded TLB.  Thus your
cmpxchg stuff on the pagetables will still work.

And if/when we add new page table structures (inevitable eventually for the
superpage work, I think) they can be designed from the start with
scalability in mind.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
