From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 28 Aug 2002 16:42:04 +0000
Subject: [Linux-ia64] [RFD] physical memory granularity
Message-Id: <marc-linux-ia64-105590701905996@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linux on IA64 currently supports "granules" of 16MB and 64MB.  
This is the page size used for the kernel identity-mapped
regions.  Everything mapped by a page must actually exist (to
avoid MCAs when prefetching into a hole) and must have the same
attributes (to avoid attribute aliasing), so we assume that
physical memory comes in granule-sized chunks.

DIG64 2.1 says nothing about the granularity of physical memory, 
but it seems that for all existing IA64 machines, memory comes in
chunks of at least 64MB.  But there's an HP machine in the pipe
that may support only 4MB granularity.

I'm not keen on reducing the granule size to 4MB, because I'm 
afraid the extra TLB misses will be a noticeable performance
problem.  Does anybody have any quantitative data on the effect
of granule size on performance?  Or any strong opinions on what
granule sizes we should support?

Bjorn

