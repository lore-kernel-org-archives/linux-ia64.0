From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 29 Aug 2003 17:07:30 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106217745730276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Fri, Aug 29, 2003 at 06:41:56PM +0200, Xavier Bru wrote:
> 
> printing "On node %d totalpages:":
> 
> ifa=0xf000ff54f7c5722b
> iip=0xa0000001007780d0
> 0xa0000001007780d0 <__alloc_bootmem_core+592>:	[MII]       ld8 r17=[r19],8
> 
> 
> I will try to look at this a bit more if I find some more time.

Do you have this changeset in your tree?  It sounds like a similar
problem to what I was seeing.

ChangeSet@1.1292.1.3, 2003-08-25 12:23:20-07:00, mort@wildopensource.com
  [PATCH] ia64: paddr_to_nid fixup
  
  Here is a small patch for paddr_to_nid().  This fix is already in 2.4
  and is used in the case where a NUMA kernel is running on a machine
  without a SRAT ACPI table.  Without this patch the node info is not
  correctly located.


mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com
