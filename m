From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Feb 2005 18:29:51 +0000
Subject: RE: [PATCH] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EA1102@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin> For the 4-level case with 64k pages, what about just using
Robin> 16k page tables?  That leaves us with 60 bits of addressable
Robin> space which is fairly close to the full space.

David> You're kidding, right?  If getting "fairly close" to 64 bits was good
David> enough, there would be no point for 64KB pages.

User space will only end up with just over 63.5 bits since the kernel
has grabbed regions 5, 6, 7 for itself.  Unless someone comes up with
a 16EB+16EB patch analogous to the 4G+4G ia32 patch :-)

We also lose some space out of each region for the VHPT.

Region 4 is reserved for hugetlb pages.

Page 0 of region 0 is a NaT page.

So we fall short of a full, flat 64-bit address space for a variety
of reasons.

Nonetheless, I agree with David that reducing available virtual
space by a factor of 16 sounds like a poor idea.

-Tony
