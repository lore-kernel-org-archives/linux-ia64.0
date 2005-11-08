From: Gerald Pfeifer <gp@suse.de>
Date: Tue, 08 Nov 2005 23:58:51 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <Pine.LNX.4.63.0511082003120.11938@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 8 Nov 2005, Rohit Seth wrote:
> I agree with you completely about OSV certification part.  And SuSE is
> again a good example here, they have a released kernel with 64K page
> size.  There is no reason why end customer should not be using this
> bigger page kernel when desired.

Unfortuantely, I'm pretty sure that if you run such a kernel and call
$BIGISV for support you'll find yourself in troubles. :-(

For example, at least one important ISV even requires a specific
version of the distro kernel RPMs (excluding security updates), so
I pretty much doubt they'll support an alternative kernel such as
one with 64K page size.

> I just think that we should validate the 64K page size more rigorously. 
> So as to have the OSVs gain more confidence.  There is such a wide range 
> of system configurations...having a single kernel configuration may not 
> be the optimal solution.

As an OSV, we are facing combinatorial explosion.  For example when
we also consider CPU counts we get 32p vs 512p maximum on one dimension,
and 16K vs 64K on another, and there may be further ones lurking in the
dark right now (like Xen Dom0 versus Xen Dom1).

OSVs and ISVs, on the other hand, usually prefer to only test and harden 
and qualify/certify a single kernel (which is why Dan's approach to Xen/ia64
looks quite appealing).

Gerald
