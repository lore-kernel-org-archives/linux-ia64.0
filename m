From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 25 Aug 2004 00:19:58 +0000
Subject: [PATCH] fix show_mem on discontig machines
Message-Id: <200408241719.58648.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_us9KBIuERw+qqcP"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_us9KBIuERw+qqcP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dave Hansen recently did some bootmem and paging init cleanups, but I missed 
this little bit when I tested his original patches.  We need to initialize 
pgdat->node_mem_map correctly since a) we're using vmem_map, and b) the core 
won't do it for us since we have a valid node_start_pfn I believe.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_us9KBIuERw+qqcP
Content-Type: text/plain;
  charset="us-ascii";
  name="node-mem-map-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="node-mem-map-fix.patch"

===== arch/ia64/mm/discontig.c 1.17 vs edited =====
--- 1.17/arch/ia64/mm/discontig.c	2004-08-24 02:08:33 -07:00
+++ edited/arch/ia64/mm/discontig.c	2004-08-24 17:11:35 -07:00
@@ -664,6 +664,7 @@
 
 		pfn_offset = mem_data[node].min_pfn;
 
+		NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
 		free_area_init_node(node, NODE_DATA(node), zones_size,
 				    pfn_offset, zholes_size);
 	}

--Boundary-00=_us9KBIuERw+qqcP--
