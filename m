From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 07 Nov 2005 21:18:37 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04E3F865@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Another thing: has people tested 4 level page table with 4GB hugetlb page
>size?  Looks like pud is already falling short on bits and entire pgd bits
>will be falling off the 64-bit.  128-bit computing anybody? (just kidding).

I didn't try 4GB huge page ... but I did just try to build with
a 64K normal page, and the build failed with fatal errors in ivt.S
because of attempts to shift by more than 64.  There are also
a gazillion[1] warnings about "left shift count >= width of type"
from all over the build.

Perhaps arch/ia64/Kconfig shouldn't let you choose 4-level tables
with a 64K pagesize?

-Tony

[1] Actually "just" 1368 warnings.
