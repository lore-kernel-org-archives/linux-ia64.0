From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 10 Nov 2003 15:52:49 +0000
Subject: discontig patch question
Message-Id: <marc-linux-ia64-106847971018555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I tried running the discontig patch on a more "normal" machine
(one that wasn't fully loaded with memory), and I found the results
suprising.

The EFI memory map is simple, and looks like:
 0- 4G Node 0 (2G + 2G hole)
 4- 8G Node 1
 8-12G Node 2
12-16G Node 3
16-20G Node 0 (2 G memory-map I/O reclaim)
with 4G per node, 16GB total.

Because of ORDERROUNDDOWN in count_pages (arch/ia64/mm/init.c),
the memory ended up being assigned like this:

 0- 8G Node 1 (6G, 2GB hole)
 8-16G Node 3 (8G)
16-20G Node 0 (2G)
       Node 2 (0G)

Which was not at all what I wanted.

ORDERROUNDDOWN causes the kernel to assign all memory starting at the
(PAGE_SIZE << MAX_ORDER) boundary to the current node, which in my case
is 16KB << 19 (hard-coded for IA64), or 8GB.

I understand the GRANULE rounding, but is there a compelling reason that
we need 8GB node chunks on IA64 Linux (with 16KB pages)?

Thanks,
Kevin Van Maren
