From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 May 2002 23:26:32 +0000
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905559@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think it would be interesting to see a discontig patch which leaves
> out all the NUMA stuff.  I really believe it would actually help clean
> up that patch a lot.

Without using a virtual mem_map, it would still have many of the warts.
The trickiest part is making sure that "virt_to_page()" is implemented
efficiently ... and with no constraints on how the physical memory can be
arranged on a DIG platform this becomes a hard problem (which we evaded
with the discontigmem patch by pushing some of the macros into platform
dependent files, and having our hardcoded limits ... clumps per node etc).

Now that you have virtual mem_map working, it will be interesting to look
at whether it adds significantly to TLB pressure (or has a measureable
impact on any other performance measurement).  If it doesn't, then it
becomes a viable way to clean up the discontig/numa code, so long as we
can persuade the platform designers to keep their hands off the very high
order physical bits. SGI/sn2 physical memory layout (which is the current
worst case that I'm aware of) will be able to fit the virtual mem_map it
needs into region 5 (2^42 bytes ... works ok unless you want to use a 4K
page size).

-Tony

