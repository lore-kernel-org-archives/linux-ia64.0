From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Dec 2004 17:25:55 +0000
Subject: RE: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02900608@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Martin J. Bligh" <mbligh@aracnet.com>, Andi Kleen <ak@suse.de>, Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

>> Also at least on IA64 the large page size is usually 1-2GB 
>> and that would seem to be a little too large to me for
>> interleaving purposes. Also it may prevent the purpose 
>> you implemented it - not using too much memory from a single
>> node. 
>
>Yes, that'd bork it. But I thought that they had a large sheaf of
>mapping sizes to chose from on ia64?

Yes, ia64 supports lots of pagesizes (the exact list for each cpu
model can be found in /proc/pal/cpu*/vm_info, but the architecture
requires that 4k, 8k, 16k, 64k, 256k, 1m, 4m, 16m, 64m, 256m be
supported by all implementations).  To make good use of them
for vmalloc() would require that we switch the kernel over to
using long format VHPT ... as well as all the architecture
independent changes that Andi listed.

It would be interesting to see some perfmon data on TLB miss rates
before and after this patch, but I'd personally be amazed if you
could find a macro-level benchmark that could reliably detect the
perfomance effects relating to TLB caused by this change.

-Tony
