From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 04 Feb 2004 20:57:48 +0000
Subject: [PATCH] Altix - cleanup HWGRAPH_DEBUG
Message-Id: <20040204205748.GN3387@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="bGR76rFJjkSxVeRa"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--bGR76rFJjkSxVeRa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi Andrew,

Another patch against 2.6.2-rc3-mm1 to cleanup HWGRAPH_DEBUG.  It also
cleans up some compile warning by changing the prototype of
hwgraph_debug().

I ran this patch by Pat & Colin and they asked me to send it to you.

Thanks
mh

-- 
Martin Hicks                Wild Open Source Inc.
mort@wildopensource.com     613-266-2296

--bGR76rFJjkSxVeRa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-hwgraph-debug-cleanup.diff"

diff -X /home/mort/diffex -uNr linux-2.6.2.altix/arch/ia64/sn/io/hwgfs/hcl.c linux-2.6.2.mod/arch/ia64/sn/io/hwgfs/hcl.c
--- linux-2.6.2.altix/arch/ia64/sn/io/hwgfs/hcl.c	2004-02-03 22:43:55.000000000 -0500
+++ linux-2.6.2.mod/arch/ia64/sn/io/hwgfs/hcl.c	2004-02-04 13:29:46.987261800 -0500
@@ -645,7 +645,7 @@
 
 
 void
-hwgraph_debug(char *file, char * function, int line, vertex_hdl_t vhdl1, vertex_hdl_t vhdl2, char *format, ...)
+hwgraph_debug(char *file, const char * function, int line, vertex_hdl_t vhdl1, vertex_hdl_t vhdl2, char *format, ...)
 {
 
 	int pos;
diff -X /home/mort/diffex -uNr linux-2.6.2.altix/arch/ia64/sn/io/hwgfs/hcl_util.c linux-2.6.2.mod/arch/ia64/sn/io/hwgfs/hcl_util.c
--- linux-2.6.2.altix/arch/ia64/sn/io/hwgfs/hcl_util.c	2004-02-03 22:43:05.000000000 -0500
+++ linux-2.6.2.mod/arch/ia64/sn/io/hwgfs/hcl_util.c	2004-02-04 13:29:05.289840719 -0500
@@ -151,7 +151,7 @@
 		(void)hwgraph_edge_add( hwgraph_all_cnodes,
 					vhdl,
 					cnodeid_buffer);
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, hwgraph_all_cnodes, NULL, "Creating path vhdl1\n"));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, hwgraph_all_cnodes, NULL, "Creating path vhdl1\n");
 	}
 }
 
diff -X /home/mort/diffex -uNr linux-2.6.2.altix/arch/ia64/sn/io/sn2/klgraph.c linux-2.6.2.mod/arch/ia64/sn/io/sn2/klgraph.c
--- linux-2.6.2.altix/arch/ia64/sn/io/sn2/klgraph.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2.mod/arch/ia64/sn/io/sn2/klgraph.c	2004-02-04 13:32:52.980155709 -0500
@@ -43,7 +43,7 @@
 
 	hwgraph_path_add(node_vertex, EDGE_LBL_HUB, &myhubv);
 
-	HWGRAPH_DEBUG((__FILE__, __FUNCTION__,__LINE__, myhubv, NULL, "Created path for hub vertex for Shub node.\n"));
+	HWGRAPH_DEBUG(__FILE__, __FUNCTION__,__LINE__, myhubv, NULL, "Created path for hub vertex for Shub node.\n");
 
 	rc = device_master_set(myhubv, node_vertex);
 	if (rc) {
@@ -71,7 +71,7 @@
 		snprintf(name, 120, "%s/%s/%c", EDGE_LBL_DISABLED, EDGE_LBL_CPU, 'a' + cpu->cpu_info.physid);
 		(void) hwgraph_path_add(node_vertex, name, &my_cpu);
 
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__,__LINE__, my_cpu, NULL, "Created path for disabled cpu slice.\n"));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__,__LINE__, my_cpu, NULL, "Created path for disabled cpu slice.\n");
 
 		mark_cpuvertex_as_cpu(my_cpu, cpu_id);
 		device_master_set(my_cpu, node_vertex);
@@ -98,7 +98,7 @@
 
         (void) hwgraph_path_add(node_vertex, name, &my_cpu);
 
-	HWGRAPH_DEBUG((__FILE__, __FUNCTION__,__LINE__, my_cpu, NULL, "Created path for active cpu slice.\n"));
+	HWGRAPH_DEBUG(__FILE__, __FUNCTION__,__LINE__, my_cpu, NULL, "Created path for active cpu slice.\n");
 
 	mark_cpuvertex_as_cpu(my_cpu, cpu_id);
         device_master_set(my_cpu, node_vertex);
@@ -107,7 +107,7 @@
         if (hwgraph_edge_get(node_vertex, EDGE_LBL_CPU, &cpu_dir) == GRAPH_SUCCESS) {
                 snprintf(name, 120, "%c", 'a' + cpu->cpu_info.physid);
                 (void) hwgraph_edge_add(cpu_dir, my_cpu, name);
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__,__LINE__, cpu_dir, my_cpu, "Created % from vhdl1 to vhdl2.\n", name));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__,__LINE__, cpu_dir, my_cpu, "Created % from vhdl1 to vhdl2.\n", name);
         }
 }
 
@@ -166,7 +166,7 @@
 			return;
                 }
 
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, xbow_v, NULL, "Created path for xtalk.\n"));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, xbow_v, NULL, "Created path for xtalk.\n");
 
 		xswitch_vertex_init(xbow_v); 
 
@@ -212,7 +212,7 @@
 		return;
 	}
 
-	HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, node_vertex, NULL, "Created path for SHUB node.\n"));
+	HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, node_vertex, NULL, "Created path for SHUB node.\n");
 	hub = (klhub_t *)find_first_component(brd, KLSTRUCT_HUB);
 	ASSERT(hub);
 	if(hub->hub_info.flags & KLINFO_ENABLE)
@@ -250,7 +250,7 @@
 			printk("klhwg_add_node: Cannot create CPU directory\n");
 			return;
 		}
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, cpu_dir, NULL, "Created cpu directiry on SHUB node.\n"));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, cpu_dir, NULL, "Created cpu directiry on SHUB node.\n");
 
 	}
 
@@ -305,7 +305,7 @@
 						  "failed.  Path == %s", path_buffer);
 				return;
 			}
-			HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, node_vertex, NULL, "Created router path.\n"));
+			HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, node_vertex, NULL, "Created router path.\n");
 
 		/* Find the rest of the routers stored on this node. */
 		} while ( (brd = find_lboard_class_any(KLCF_NEXT_ANY(brd),
@@ -400,7 +400,7 @@
 				path_buffer, dest_path, (void *)dest_hndl, rc);
 			return;
 		}
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, router_hndl, dest_hndl, "Created edge %s from vhdl1 to vhdl2.\n", dest_path));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, router_hndl, dest_hndl, "Created edge %s from vhdl1 to vhdl2.\n", dest_path);
 		
 	}
 }
@@ -492,14 +492,14 @@
 
 				rc = hwgraph_path_add(hub_hndl, EDGE_LBL_INTERCONNECT, &hub_hndl);
 
-				HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, hub_hndl, NULL, "Created link path.\n"));
+				HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, hub_hndl, NULL, "Created link path.\n");
 
 				sprintf(buf,"%s/%s",path_buffer,EDGE_LBL_INTERCONNECT);
 				rc = hwgraph_traverse(hwgraph_root, buf, &hub_hndl);
 				sprintf(buf,"%d",port);
 				rc = hwgraph_edge_add(hub_hndl, dest_hndl, buf);
 
-				HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, hub_hndl, dest_hndl, "Created edge %s from vhdl1 to vhdl2.\n", buf));
+				HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, hub_hndl, dest_hndl, "Created edge %s from vhdl1 to vhdl2.\n", buf);
 
 				if (rc != GRAPH_SUCCESS) {
 					printk("Can't create edge: %s/%s to vertex 0x%p, error 0x%x\n",
@@ -533,7 +533,7 @@
 		rc = hwgraph_path_add(hwgraph_root, name, &module_vhdl);
 		ASSERT(rc == GRAPH_SUCCESS);
 		rc = rc;
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, module_vhdl, NULL, "Created module path.\n"));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, module_vhdl, NULL, "Created module path.\n");
 
 		hwgraph_fastinfo_set(module_vhdl, (arbitrary_info_t) modules[cm]);
 
@@ -545,7 +545,7 @@
 		rc = hwgraph_path_add(hwgraph_root, name, &vhdl);
 		ASSERT_ALWAYS(rc == GRAPH_SUCCESS); 
 		rc = rc;
-		HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, vhdl, NULL, "Created L1 path.\n"));
+		HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, vhdl, NULL, "Created L1 path.\n");
 
 		hwgraph_info_add_LBL(vhdl, INFO_LBL_ELSC,
 				     (arbitrary_info_t)1);
diff -X /home/mort/diffex -uNr linux-2.6.2.altix/arch/ia64/sn/io/sn2/module.c linux-2.6.2.mod/arch/ia64/sn/io/sn2/module.c
--- linux-2.6.2.altix/arch/ia64/sn/io/sn2/module.c	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2.mod/arch/ia64/sn/io/sn2/module.c	2004-02-04 13:34:39.236240853 -0500
@@ -200,7 +200,7 @@
 	board = find_lboard_nasid((lboard_t *) KL_CONFIG_INFO(nasid), nasid, KLTYPE_SNIA);
 	ASSERT(board);
 
-	HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, NULL, NULL, "Found Shub lboard 0x%lx nasid 0x%x cnode 0x%x \n", (unsigned long)board, (int)nasid, (int)node));
+	HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, NULL, NULL, "Found Shub lboard 0x%lx nasid 0x%x cnode 0x%x \n", (unsigned long)board, (int)nasid, (int)node);
 
 	m = module_add_node(board->brd_geoid, node);
 	if (! m->snum_valid && module_probe_snum(m, nasid, nasid))
@@ -219,7 +219,7 @@
 				nasid, KLTYPE_SNIA);
 	ASSERT(board);
 
-	HWGRAPH_DEBUG((__FILE__, __FUNCTION__, __LINE__, NULL, NULL, "Found headless/memless lboard 0x%lx node %d nasid %d cnode %d\n", (unsigned long)board, node, (int)nasid, (int)node));
+	HWGRAPH_DEBUG(__FILE__, __FUNCTION__, __LINE__, NULL, NULL, "Found headless/memless lboard 0x%lx node %d nasid %d cnode %d\n", (unsigned long)board, node, (int)nasid, (int)node);
 
         m = module_add_node(board->brd_geoid, node);
 
diff -X /home/mort/diffex -uNr linux-2.6.2.altix/include/asm-ia64/sn/hcl.h linux-2.6.2.mod/include/asm-ia64/sn/hcl.h
--- linux-2.6.2.altix/include/asm-ia64/sn/hcl.h	2004-02-04 09:40:35.000000000 -0500
+++ linux-2.6.2.mod/include/asm-ia64/sn/hcl.h	2004-02-04 13:30:14.870178855 -0500
@@ -14,10 +14,10 @@
 extern vertex_hdl_t hwgraph_root;
 extern vertex_hdl_t linux_busnum;
 
-void hwgraph_debug(char *, char *, int, vertex_hdl_t, vertex_hdl_t, char *, ...);
+void hwgraph_debug(char *, const char *, int, vertex_hdl_t, vertex_hdl_t, char *, ...);
 
 #if 1
-#define HWGRAPH_DEBUG(args) hwgraph_debug args ;
+#define HWGRAPH_DEBUG(args...) hwgraph_debug(args)
 #else   
 #define HWGRAPH_DEBUG(args)
 #endif  

--bGR76rFJjkSxVeRa--
