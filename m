From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Sep 2003 19:02:55 +0000
Subject: Re: SN files update for 2.4
Message-Id: <marc-linux-ia64-106270290113959@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 03 September 2003 4:23 pm, Erik Jacobson wrote:
> The attached patch is an update to the SN files that are in the 2.4 bitkeeper
> tree.

Thanks, I applied this (after converting CR/NL to NL).

I didn't read the patch, since it only touches sn files, but I did
notice several checks of kmalloc return values for "<= 0", which
seems wrong because kmalloc returns NULL for failure.  For example:

--- a/arch/ia64/sn/io/drivers/ioconfig_bus.c	Thu Sep  4 14:38:03 2003
+++ b/arch/ia64/sn/io/drivers/ioconfig_bus.c	Thu Sep  4 14:38:03 2003
@@ -162,8 +165,13 @@
 	struct ascii_moduleid *moduleid;
 
 	line = kmalloc(256, GFP_KERNEL);
+	if (line <= 0)
+		BUG(); /* Do not want to continue system boot .. */
 	memset(line, 0,256);
 	name = kmalloc(125, GFP_KERNEL);
+	if (name <= 0){
+		BUG(); /* Do not want to continue system boot .. */
+	}
 	memset(name, 0, 125);
 	moduleid = table;
 	current = file_contents;
@@ -252,6 +260,9 @@
 		ret_stuff.v0, (void *)ioconfig_file, (int)ioconfig_file_size);
 
 	ioconfig_bus_table = kmalloc( 512, GFP_KERNEL );
+	if (ioconfig_bus_table <= 0)
+		BUG(); /* Seriously, we should not be out of memory at init */
+
 	memset(ioconfig_bus_table, 0, 512);
 
 	/*
--- a/arch/ia64/sn/io/drivers/pciba.c	Thu Sep  4 14:38:03 2003
+++ b/arch/ia64/sn/io/drivers/pciba.c	Thu Sep  4 14:38:03 2003
@@ -341,8 +341,8 @@
 	TRACE();
 	
 	node = kmalloc(sizeof(struct node_data), GFP_KERNEL);
-	if (node = NULL)
-		return NULL;
+	if (node <= 0)
+		return node;
 	list_add(&node->global_node_list, &global_node_list);
 	return node;
 }
@@ -763,7 +763,7 @@
 
 		dma_alloc = (struct dma_allocation *)
 			kmalloc(sizeof(struct dma_allocation), GFP_KERNEL);
-		if (dma_alloc = NULL)
+		if (dma_alloc <= 0)
 			return -ENOMEM;
 
 		dma_alloc->size = (size_t)argv;

