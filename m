From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 May 2002 18:25:08 +0000
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> If you look at the patch, you'll also see that I started merging
> the "mem_map in virtual memory" patch (CONFIG_VIRTUAL_MEM_MAP),
> which is currently needed on zx1 platforms with >1GB of memory.
> However, the merge isn't complete and the new code isn't working yet.

David,

When I started working on a new discontigmem patch for ia64, Kanoj
Sarcar dissuaded me from a virtual mem_map with a lot of fast handwaving
on the cost of TLB faults to access page structures.  He stated (and I
agreed) that there wasn't much reason to expect good locality of reference
to page structs ... so this could have a measurable impact.  Sadly, neither
of us actually made any measurements to back up this belief.

Have you looked at the possible performance effect of this change?

Would the discontigmem patch meet the needs of the zx1 platform?

-Tony Luck


