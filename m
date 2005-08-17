From: Mark Goodwin <markgw@sgi.com>
Date: Wed, 17 Aug 2005 22:16:40 +0000
Subject: [PATCH RESPIN 2/3] - SGI SN hwperf enhancements - sn_hwperf_get_nearest_node
Message-Id: <Pine.LNX.4.62.0508180812170.18474@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Respun after the original posting to work correctly on systems
with I/O nodes attached to routers.

Add a new exported function for determining the nearest node
with CPUs for I/O nodes and fix a bug where the hwperf dynamic
misc device was being registered before misc_init(). 


Signed-off-by: Mark Goodwin <markgw@sgi.com>

Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-08-16 16:07:34.651901161 +1000
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-08-17 16:45:53.002978756 +1000
@@ -59,7 +59,7 @@
 	struct sn_hwperf_object_info *objbuf = NULL;
 
 	if ((e = sn_hwperf_init()) < 0) {
-		printk("sn_hwperf_init failed: err %d\n", e);
+		printk(KERN_ERR "sn_hwperf_init failed: err %d\n", e);
 		goto out;
 	}
 
@@ -111,7 +111,7 @@
 	if (sn_hwperf_location_to_bpos(location, &rack, &bay, &slot, &slab))
 		return -1;
 
-	for (cnode = 0; cnode < numionodes; cnode++) {
+	for_each_node(cnode) {
 		geoid = cnodeid_get_geoid(cnode);
 		module_id = geo_module(geoid);
 		this_rack = MODULE_GET_RACK(module_id);
@@ -124,11 +124,13 @@
 		}
 	}
 
-	return cnode < numionodes ? cnode : -1;
+	return node_possible(cnode) ? cnode : -1;
 }
 
 static int sn_hwperf_obj_to_cnode(struct sn_hwperf_object_info * obj)
 {
+	if (!SN_HWPERF_IS_NODE(obj) && !SN_HWPERF_IS_IONODE(obj))
+		BUG();
 	if (!obj->sn_hwp_this_part)
 		return -1;
 	return sn_hwperf_geoid_to_cnode(obj->location);
@@ -192,6 +194,181 @@
 	}
 }
 
+static inline int sn_hwperf_has_cpus(cnodeid_t node)
+{
+	return node_online(node) && nr_cpus_node(node);
+}
+
+static inline int sn_hwperf_has_mem(cnodeid_t node)
+{
+	return node_online(node) && NODE_DATA(node)->node_present_pages;
+}
+
+static struct sn_hwperf_object_info *
+sn_hwperf_findobj_id(struct sn_hwperf_object_info *objbuf,
+	int nobj, int id)
+{
+	int i;
+	struct sn_hwperf_object_info *p = objbuf;
+
+	for (i=0; i < nobj; i++, p++) {
+		if (p->id = id)
+			return p;
+	}
+
+	return NULL;
+
+}
+
+static int sn_hwperf_get_nearest_node_objdata(struct sn_hwperf_object_info *objbuf,
+	int nobj, cnodeid_t node, cnodeid_t *near_mem_node, cnodeid_t *near_cpu_node)
+{
+	int e;
+	struct sn_hwperf_object_info *nodeobj = NULL;
+	struct sn_hwperf_object_info *op;
+	struct sn_hwperf_object_info *dest;
+	struct sn_hwperf_object_info *router;
+	struct sn_hwperf_port_info ptdata[16];
+	int sz, i, j;
+	cnodeid_t c;
+	int found_mem = 0;
+	int found_cpu = 0;
+
+	if (!node_possible(node))
+		return -EINVAL;
+
+	if (sn_hwperf_has_cpus(node)) {
+		if (near_cpu_node)
+			*near_cpu_node = node;
+		found_cpu++;
+	}
+
+	if (sn_hwperf_has_mem(node)) {
+		if (near_mem_node)
+			*near_mem_node = node;
+		found_mem++;
+	}
+
+	if (found_cpu && found_mem)
+		return 0; /* trivially successful */
+
+	/* find the argument node object */
+	for (i=0, op=objbuf; i < nobj; i++, op++) {
+		if (!SN_HWPERF_IS_NODE(op) && !SN_HWPERF_IS_IONODE(op))
+			continue;
+		if (node = sn_hwperf_obj_to_cnode(op)) {
+			nodeobj = op;
+			break;
+		}
+	}
+	if (!nodeobj) {
+		e = -ENOENT;
+		goto err;
+	}
+
+	/* get it's interconnect topology */
+	sz = op->ports * sizeof(struct sn_hwperf_port_info);
+	if (sz > sizeof(ptdata))
+		BUG();
+	e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
+			      SN_HWPERF_ENUM_PORTS, nodeobj->id, sz,
+			      (u64)&ptdata, 0, 0, NULL);
+	if (e != SN_HWPERF_OP_OK) {
+		e = -EINVAL;
+		goto err;
+	}
+
+	/* find nearest node with cpus and nearest memory */
+	for (router=NULL, j=0; j < op->ports; j++) {
+		dest = sn_hwperf_findobj_id(objbuf, nobj, ptdata[j].conn_id);
+		if (!dest || SN_HWPERF_FOREIGN(dest) ||
+		    !SN_HWPERF_IS_NODE(dest) || SN_HWPERF_IS_IONODE(dest)) {
+			continue;
+		}
+		c = sn_hwperf_obj_to_cnode(dest);
+		if (!found_cpu && sn_hwperf_has_cpus(c)) {
+			if (near_cpu_node)
+				*near_cpu_node = c;
+			found_cpu++;
+		}
+		if (!found_mem && sn_hwperf_has_mem(c)) {
+			if (near_mem_node)
+				*near_mem_node = c;
+			found_mem++;
+		}
+		if (SN_HWPERF_IS_ROUTER(dest))
+			router = dest;
+	}
+
+	if (router && (!found_cpu || !found_mem)) {
+		/* search for a node connected to the same router */
+		sz = router->ports * sizeof(struct sn_hwperf_port_info);
+		if (sz > sizeof(ptdata))
+			BUG();
+		e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
+				      SN_HWPERF_ENUM_PORTS, router->id, sz,
+				      (u64)&ptdata, 0, 0, NULL);
+		if (e != SN_HWPERF_OP_OK) {
+			e = -EINVAL;
+			goto err;
+		}
+		for (j=0; j < router->ports; j++) {
+			dest = sn_hwperf_findobj_id(objbuf, nobj,
+				ptdata[j].conn_id);
+			if (!dest || dest->id = node ||
+			    SN_HWPERF_FOREIGN(dest) ||
+			    !SN_HWPERF_IS_NODE(dest) ||
+			    SN_HWPERF_IS_IONODE(dest)) {
+				continue;
+			}
+			c = sn_hwperf_obj_to_cnode(dest);
+			if (!found_cpu && sn_hwperf_has_cpus(c)) {
+				if (near_cpu_node)
+					*near_cpu_node = c;
+				found_cpu++;
+			}
+			if (!found_mem && sn_hwperf_has_mem(c)) {
+				if (near_mem_node)
+					*near_mem_node = c;
+				found_mem++;
+			}
+			if (found_cpu && found_mem)
+				break;
+		}
+	}
+
+	if (!found_cpu || !found_mem) {
+		/* resort to _any_ node with CPUs and memory */
+		for (i=0, op=objbuf; i < nobj; i++, op++) {
+			if (SN_HWPERF_FOREIGN(op) ||
+			    SN_HWPERF_IS_IONODE(op) ||
+			    !SN_HWPERF_IS_NODE(op)) {
+				continue;
+			}
+			c = sn_hwperf_obj_to_cnode(op);
+			if (!found_cpu && sn_hwperf_has_cpus(c)) {
+				if (near_cpu_node)
+					*near_cpu_node = c;
+				found_cpu++;
+			}
+			if (!found_mem && sn_hwperf_has_mem(c)) {
+				if (near_mem_node)
+					*near_mem_node = c;
+				found_mem++;
+			}
+			if (found_cpu && found_mem)
+				break;
+		}
+	}
+
+	if (!found_cpu || !found_mem)
+		e = -ENODATA;
+
+err:
+	return e;
+}
+
+
 static int sn_topology_show(struct seq_file *s, void *d)
 {
 	int sz;
@@ -265,11 +442,24 @@
 	if (!SN_HWPERF_IS_NODE(obj) && !SN_HWPERF_IS_IONODE(obj))
 		seq_putc(s, '\n');
 	else {
+		cnodeid_t near_mem = -1;
+		cnodeid_t near_cpu = -1;
+
 		seq_printf(s, ", nasid 0x%x", cnodeid_to_nasid(ordinal));
-		for (i=0; i < numionodes; i++) {
-			seq_printf(s, i ? ":%d" : ", dist %d",
-				node_distance(ordinal, i));
+
+		if (sn_hwperf_get_nearest_node_objdata(objs, sn_hwperf_obj_cnt,
+			ordinal, &near_mem, &near_cpu) = 0) {
+			seq_printf(s, ", near_mem_nodeid %d, near_cpu_nodeid %d",
+				near_mem, near_cpu);
+		}
+
+		if (!SN_HWPERF_IS_IONODE(obj)) {
+			for_each_online_node(i) {
+				seq_printf(s, i ? ":%d" : ", dist %d",
+					node_distance(ordinal, i));
+			}
 		}
+
 		seq_putc(s, '\n');
 
 		/*
@@ -554,6 +744,8 @@
 		if ((r = sn_hwperf_enum_objects(&nobj, &objs)) = 0) {
 			memset(p, 0, a.sz);
 			for (i = 0; i < nobj; i++) {
+				if (!SN_HWPERF_IS_NODE(objs + i))
+					continue;
 				node = sn_hwperf_obj_to_cnode(objs + i);
 				for_each_online_cpu(j) {
 					if (node != cpu_to_node(j))
@@ -580,7 +772,7 @@
 
 	case SN_HWPERF_GET_NODE_NASID:
 		if (a.sz != sizeof(u64) ||
-		   (node = a.arg) < 0 || node >= numionodes) {
+		   (node = a.arg) < 0 || !node_possible(node)) {
 			r = -EINVAL;
 			goto error;
 		}
@@ -609,6 +801,14 @@
 				vfree(objs);
 				goto error;
 			}
+
+			if (!SN_HWPERF_IS_NODE(objs + i) &&
+			    !SN_HWPERF_IS_IONODE(objs + i)) {
+			    	r = -ENOENT;
+				vfree(objs);
+				goto error;
+			}
+
 			*(u64 *)p = (u64)sn_hwperf_obj_to_cnode(objs + i);
 			vfree(objs);
 		}
@@ -674,6 +874,7 @@
 
 	/* single threaded, once-only initialization */
 	down(&sn_hwperf_init_mutex);
+
 	if (sn_hwperf_salheap) {
 		up(&sn_hwperf_init_mutex);
 		return e;
@@ -724,19 +925,6 @@
 		sn_hwperf_salheap = NULL;
 		sn_hwperf_obj_cnt = 0;
 	}
-
-	if (!e) {
-		/*
-		 * Register a dynamic misc device for ioctl. Platforms
-		 * supporting hotplug will create /dev/sn_hwperf, else
-		 * user can to look up the minor number in /proc/misc.
-		 */
-		if ((e = misc_register(&sn_hwperf_dev)) != 0) {
-			printk(KERN_ERR "sn_hwperf_init: misc register "
-			       "for \"sn_hwperf\" failed, err %d\n", e);
-		}
-	}
-
 	up(&sn_hwperf_init_mutex);
 	return e;
 }
@@ -764,3 +952,41 @@
 	vfree(seq->private);
 	return seq_release(inode, file);
 }
+
+int sn_hwperf_get_nearest_node(cnodeid_t node,
+	cnodeid_t *near_mem_node, cnodeid_t *near_cpu_node)
+{
+	int e;
+	int nobj;
+	struct sn_hwperf_object_info *objbuf;
+
+	if ((e = sn_hwperf_enum_objects(&nobj, &objbuf)) = 0) {
+		e = sn_hwperf_get_nearest_node_objdata(objbuf, nobj,
+			node, near_mem_node, near_cpu_node);
+		vfree(objbuf);
+	}
+
+	return e;
+}
+
+static int __devinit sn_hwperf_misc_register_init(void)
+{
+	int e;
+
+	sn_hwperf_init();
+
+	/*
+	 * Register a dynamic misc device for hwperf ioctls. Platforms
+	 * supporting hotplug will create /dev/sn_hwperf, else user
+	 * can to look up the minor number in /proc/misc.
+	 */
+	if ((e = misc_register(&sn_hwperf_dev)) != 0) {
+		printk(KERN_ERR "sn_hwperf_misc_register_init: failed to "
+		"register misc device for \"%s\"\n", sn_hwperf_dev.name);
+	}
+
+	return e;
+}
+
+device_initcall(sn_hwperf_misc_register_init); /* after misc_init() */
+EXPORT_SYMBOL(sn_hwperf_get_nearest_node);
Index: linux/include/asm-ia64/sn/sn2/sn_hwperf.h
=================================--- linux.orig/include/asm-ia64/sn/sn2/sn_hwperf.h	2005-08-16 16:05:32.949690412 +1000
+++ linux/include/asm-ia64/sn/sn2/sn_hwperf.h	2005-08-17 16:45:53.004931882 +1000
@@ -43,6 +43,7 @@
 
 /* macros for object classification */
 #define SN_HWPERF_IS_NODE(x)		((x) && strstr((x)->name, "SHub"))
+#define SN_HWPERF_IS_NODE_SHUB2(x)	((x) && strstr((x)->name, "SHub 2."))
 #define SN_HWPERF_IS_IONODE(x)		((x) && strstr((x)->name, "TIO"))
 #define SN_HWPERF_IS_ROUTER(x)		((x) && strstr((x)->name, "Router"))
 #define SN_HWPERF_IS_NL3ROUTER(x)	((x) && strstr((x)->name, "NL3Router"))
@@ -214,6 +215,15 @@
  */
 #define SN_HWPERF_GET_NODE_NASID	(102|SN_HWPERF_OP_MEM_COPYOUT)
 
+/*
+ * Given a node id, determine the id of the nearest node with CPUs
+ * and the id of the nearest node that has memory. The argument
+ * node would normally be a "headless" node, e.g. an "IO node".
+ * Return 0 on success.
+ */
+extern int sn_hwperf_get_nearest_node(cnodeid_t node,
+	cnodeid_t *near_mem, cnodeid_t *near_cpu);
+
 /* return codes */
 #define SN_HWPERF_OP_OK			0
 #define SN_HWPERF_OP_NOMEM		1
