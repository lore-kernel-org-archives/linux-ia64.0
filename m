From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 27 Sep 2003 14:05:59 +0000
Subject: Re: [PATCH] compile discontig with -Whch
Message-Id: <marc-linux-ia64-106467157926027@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106460503816753@msgid-missing>
In-Reply-To: <marc-linux-ia64-106460503816753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 26, 2003 at 12:36:20PM -0700, Jesse Barnes wrote:
> Incorporate some more feedback from hch like moving more stuff to
> contig.c, removing some unneeded functions, etc..  Still left todo:

I need the following hack to compile.  Shouldn't be needed anymore as soon
as you switch to a proper per-node mem_map :)

--- a/kernel/ksyms.c	Sat Sep 27 16:03:09 2003
+++ b/kernel/ksyms.c	Sat Sep 27 16:03:09 2003
@@ -115,7 +115,7 @@
 EXPORT_SYMBOL(vmalloc_to_page);
 EXPORT_SYMBOL(remap_page_range);
 #if defined(CONFIG_VIRTUAL_MEM_MAP) || !defined(CONFIG_DISCONTIGMEM)
-EXPORT_SYMBOL(contig_page_data);
+//EXPORT_SYMBOL(contig_page_data);
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(max_mapnr);
 #endif
