From: Mark Goodwin <markgw@sgi.com>
Date: Fri, 10 Sep 2004 07:05:31 +0000
Subject: [PATCH] arch/ia64/sn: SGI Altix hardware performance monitoring API
Message-Id: <Pine.LNX.4.44.0409101641020.17255-100000@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The SGI Altix PROM supports a SAL call for performance monitoring and for
exporting NUMA topology. We need this in community kernels for diagnostic
and performance tools to use, especially on very large machines.

This patch registers a dynamic misc device "sn_hwperf" that supports an
ioctl interface for reading/writing memory mapped registers on Altix
nodes and routers via the new SAL call. It also creates a read-only
procfs file "/proc/sgi_sn/sn_topology" to export NUMA topology and Altix
hardware inventory.

Any review/comments most welcome ..  thanks

Signed-off-by: Mark Goodwin <markgw@sgi.com>
---


Index: linux/arch/ia64/sn/kernel/sn2/Makefile
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/Makefile	Fri Sep 10 15:26:56 2004
+++ linux/arch/ia64/sn/kernel/sn2/Makefile	Fri Sep 10 15:27:38 2004
@@ -10,4 +10,4 @@
 #
 
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
-	 prominfo_proc.o timer.o timer_interrupt.o
+	 prominfo_proc.o timer.o timer_interrupt.o sn_hwperf.o
Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	Thu Jan  1 10:00:00 1970
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	Fri Sep 10 15:27:38 2004
@@ -0,0 +1,650 @@
+/* 
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
+ *
+ * SGI Altix topology and hardware performance monitoring API.
+ * Mark Goodwin <markgw@sgi.com>. 
+ *
+ * Creates /proc/sgi_sn/sn_topology (read-only) to export
+ * info about Altix nodes, routers, CPUs and NumaLink
+ * interconnection/topology.
+ *
+ * Also creates a dynamic misc device named "sn_hwperf"
+ * that supports an ioctl interface to call down into SAL
+ * to discover hw objects, topology and to read/write
+ * memory mapped registers, e.g. for performance monitoring.
+ *
+ * The "sn_hwperf" device is registered only after the procfs
+ * file is first opened, i.e. only if/when it's needed.
+ */
+
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/seq_file.h>
+#include <linux/miscdevice.h>
+#include <linux/cpumask.h>
+#include <linux/smp_lock.h>
+#include <asm/processor.h>
+#include <asm/topology.h>
+#include <asm/smp.h>
+#include <asm/semaphore.h>
+#include <asm/segment.h>
+#include <asm/uaccess.h>
+#include <asm-ia64/sal.h>
+#include <asm-ia64/sn/sn_sal.h>
+#include <asm-ia64/sn/sn2/sn_hwperf.h>
+
+static void *sn_hwperf_salheap = NULL;
+static int sn_hwperf_obj_cnt = 0;
+static nasid_t sn_hwperf_master_nasid = INVALID_NASID;
+static int sn_hwperf_init(void);
+static DECLARE_MUTEX(sn_hwperf_init_mutex);
+
+static int sn_hwperf_enum_objects(int *nobj, struct sn_hwperf_object_info **ret)
+{
+	int e;
+	u64 sz;
+	struct sn_hwperf_object_info *objbuf = NULL;
+
+	if ((e = sn_hwperf_init()) < 0) {
+		printk("sn_hwperf_init failed: err %d\n", e);
+		goto out;
+	}
+
+	sz = sn_hwperf_obj_cnt * sizeof(struct sn_hwperf_object_info);
+	if ((objbuf = (struct sn_hwperf_object_info *) vmalloc(sz)) = NULL) {
+		printk("sn_hwperf_enum_objects: vmalloc(%d) failed\n", (int)sz);
+		e = -ENOMEM;
+		goto out;
+	}
+
+	e = ia64_sn_hwperf_op(sn_hwperf_master_nasid, SN_HWPERF_ENUM_OBJECTS,
+		0, sz, (u64) objbuf, 0, 0, NULL);
+	if (e != SN_HWPERF_OP_OK) {
+		e = -EINVAL;
+		vfree(objbuf);
+	}
+
+out:
+	*nobj = sn_hwperf_obj_cnt;
+	*ret = objbuf;
+	return e;
+}
+
+static int sn_hwperf_geoid_to_cnode(char *location)
+{
+	int cnode;
+	int mod, slot, slab;
+	int cmod, cslot, cslab;
+
+	if (sscanf(location, "%03dc%02d#%d", &mod, &slot, &slab) != 3)
+		return -1;
+	for (cnode = 0; cnode < numnodes; cnode++) {
+		/* XXX: need a better way than this ... */
+		if (sscanf(NODEPDA(cnode)->hwg_node_name,
+		   "hw/module/%03dc%02d/slab/%d", &cmod, &cslot, &cslab) = 3) {
+			if (mod = cmod && slot = cslot && slab = cslab)
+				break;
+		}
+	}
+
+	return cnode < numnodes ? cnode : -1;
+}
+
+static int sn_hwperf_obj_to_cnode(struct sn_hwperf_object_info * obj)
+{
+	if (!obj->sn_hwp_this_part)
+		return -1;
+	return sn_hwperf_geoid_to_cnode(obj->location);
+}
+
+static int sn_hwperf_generic_ordinal(struct sn_hwperf_object_info *obj,
+				struct sn_hwperf_object_info *objs)
+{
+	int ordinal;
+	struct sn_hwperf_object_info *p;
+
+	for (ordinal=0, p=objs; p != obj; p++) {
+		if (SN_HWPERF_FOREIGN(p))
+			continue;
+		if (p->location[3] = obj->location[3])
+			ordinal++;
+	}
+
+	return ordinal;
+}
+
+#ifndef MODULE_IOBRICK 
+/* this will be available when ioif TIO support is added */
+#define MODULE_IOBRICK (MODULE_OPUSBRICK+1)
+#endif
+
+static const char *sn_hwperf_get_brickname(struct sn_hwperf_object_info *obj,
+				struct sn_hwperf_object_info *objs, int *ordinal)
+{
+	int i;
+	const char *objtype = NULL;
+
+	for (i=0; i < MAX_BRICK_TYPES; i++) {
+		if (brick_types[i] != obj->location[3])
+			continue;
+		switch (i) {
+		case MODULE_CBRICK:
+		    objtype = "node";
+		    *ordinal = sn_hwperf_obj_to_cnode(obj); /* cnodeid */
+		    break;
+
+		case MODULE_RBRICK:
+		    objtype = "router";
+		    *ordinal = sn_hwperf_generic_ordinal(obj, objs);
+		    break;
+
+		case MODULE_IOBRICK:
+		    objtype = "ionode";
+		    *ordinal = sn_hwperf_generic_ordinal(obj, objs);
+		    break;
+		}
+		break;
+	}
+
+	if (i = MAX_BRICK_TYPES) {
+		objtype = "other";
+		*ordinal = sn_hwperf_generic_ordinal(obj, objs);
+	}
+
+	return objtype;
+}
+
+static int sn_topology_show(struct seq_file *s, void *d)
+{
+	int sz;
+	int pt;
+	int e;
+	int i;
+	int j;
+	const char *brickname;
+	int ordinal;
+	cpumask_t cpumask;
+	char slice;
+	struct cpuinfo_ia64 *c;
+	struct sn_hwperf_port_info *ptdata;
+	struct sn_hwperf_object_info *p;
+	struct sn_hwperf_object_info *obj = d;	/* this object */
+	struct sn_hwperf_object_info *objs = s->private; /* all objects */
+
+	if (obj = objs) {
+		seq_printf(s, "# sn_topology version 1\n");
+		seq_printf(s, "# objtype ordinal location partition"
+			" [attribute value [, ...]]\n");
+	}
+
+	if (SN_HWPERF_FOREIGN(obj)) {
+		/* private in another partition: not interesting */
+		return 0;
+	}
+
+	for (i = 0; obj->name[i]; i++) {
+		if (obj->name[i] = ' ')
+			obj->name[i] = '_';
+	}
+
+	brickname = sn_hwperf_get_brickname(obj, objs, &ordinal);
+	seq_printf(s, "%s %d %s %s asic %s", brickname, ordinal, obj->location,
+		obj->sn_hwp_this_part ? "local" : "shared", obj->name);
+
+	if (obj->location[3] != 'c')
+		seq_putc(s, '\n');
+	else {
+		seq_printf(s, ", nasid 0x%x", cnodeid_to_nasid(ordinal));
+		for (i=0; i < numnodes; i++) {
+			seq_printf(s, i ? ":%d" : ", dist %d",
+				node_distance(ordinal, i));
+		}
+		seq_putc(s, '\n');
+
+		/*
+		 * CPUs on this node
+		 */
+		cpumask = node_to_cpumask(ordinal);
+		for_each_online_cpu(i) {
+			if (cpu_isset(i, cpumask)) {
+				slice = 'a' + cpuid_to_slice(i);
+				c = cpu_data(i);
+				seq_printf(s, "cpu %d %s%c local"
+					" freq %luMHz, arch ia64",
+					i, obj->location, slice,
+					c->proc_freq / 1000000);
+				for_each_online_cpu(j) {
+					seq_printf(s, j ? ":%d" : ", dist %d",
+						node_distance(
+						    cpuid_to_cnodeid(i),
+						    cpuid_to_cnodeid(j)));
+				}
+				seq_putc(s, '\n');
+			}
+		}
+	}
+
+	if (obj->ports) {
+		/*
+		 * numalink ports
+		 */
+		sz = obj->ports * sizeof(struct sn_hwperf_port_info);
+		if ((ptdata = vmalloc(sz)) = NULL)
+			return -ENOMEM;
+		e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
+				      SN_HWPERF_ENUM_PORTS, obj->id, sz,
+				      (u64) ptdata, 0, 0, NULL);
+		if (e != SN_HWPERF_OP_OK)
+			return -EINVAL;
+		for (ordinal=0, p=objs; p != obj; p++) {
+			if (!SN_HWPERF_FOREIGN(p))
+				ordinal += p->ports;
+		}
+		for (pt = 0; pt < obj->ports; pt++) {
+			for (p = objs, i = 0; i < sn_hwperf_obj_cnt; i++, p++) {
+				if (ptdata[pt].conn_id = p->id) {
+					break;
+				}
+			}
+			if (i >= sn_hwperf_obj_cnt)
+				continue;
+			seq_printf(s, "numalink %d %s-%d",
+			    ordinal+pt, obj->location, ptdata[pt].port);
+
+			if (obj->sn_hwp_this_part && p->sn_hwp_this_part)
+				/* both ends local to this partition */
+				seq_puts(s, " local");
+			else if (!obj->sn_hwp_this_part && !p->sn_hwp_this_part)
+				/* both ends of the link in foreign partiton */
+				seq_puts(s, " foreign");
+			else
+				/* link straddles a partition */
+				seq_puts(s, " shared");
+
+			/*
+			 * Unlikely, but strictly should query the LLP config
+			 * registers because an NL4R can be configured to run
+			 * NL3 protocol, even when not talking to an NL3 router.
+			 * Ditto for node-node.
+			 */
+			seq_printf(s, " endpoint %s-%d, protocol %s\n",
+				p->location, ptdata[pt].conn_port,
+				strcmp(obj->name, "NL3Router") = 0 ||
+				strcmp(p->name, "NL3Router") = 0 ?
+				"LLP3" : "LLP4");
+		}
+		vfree(ptdata);
+	}
+
+	return 0;
+}
+
+static void *sn_topology_start(struct seq_file *s, loff_t * pos)
+{
+	struct sn_hwperf_object_info *objs = s->private;
+
+	if (*pos < sn_hwperf_obj_cnt)
+		return (void *)(objs + *pos);
+
+	return NULL;
+}
+
+static void *sn_topology_next(struct seq_file *s, void *v, loff_t * pos)
+{
+	++*pos;
+	return sn_topology_start(s, pos);
+}
+
+static void sn_topology_stop(struct seq_file *m, void *v)
+{
+	return;
+}
+
+/*
+ * /proc/sgi_sn/sn_topology, read-only using seq_file
+ */
+static struct seq_operations sn_topology_seq_ops = {
+	.start = sn_topology_start,
+	.next = sn_topology_next,
+	.stop = sn_topology_stop,
+	.show = sn_topology_show
+};
+
+struct sn_hwperf_op_info {
+	u64 op;
+	struct sn_hwperf_ioctl_args *a;
+	void *p;
+	int *v0;
+	int ret;
+};
+
+static void sn_hwperf_call_sal(void *info)
+{
+	struct sn_hwperf_op_info *op_info = info;
+	int r;
+
+	r = ia64_sn_hwperf_op(sn_hwperf_master_nasid, op_info->op,
+		      op_info->a->arg, op_info->a->sz,
+		      (u64) op_info->p, 0, 0, op_info->v0);
+	op_info->ret = r;
+}
+
+static int sn_hwperf_op_cpu(struct sn_hwperf_op_info *op_info)
+{
+	u32 cpu;
+	u32 use_ipi;
+	int r = 0;
+	cpumask_t save_allowed;
+	
+	cpu = (op_info->a->arg & SN_HWPERF_ARG_CPU_MASK) >> 32;
+	use_ipi = op_info->a->arg & SN_HWPERF_ARG_USE_IPI_MASK;
+	op_info->a->arg &= SN_HWPERF_ARG_OBJID_MASK;
+
+	if (cpu != SN_HWPERF_ARG_ANY_CPU) {
+		if (cpu >= num_online_cpus() || !cpu_online(cpu)) {
+			r = -EINVAL;
+			goto out;
+		}
+	}
+
+	if (cpu = SN_HWPERF_ARG_ANY_CPU || cpu = get_cpu()) {
+		/* don't care, or already on correct cpu */
+		sn_hwperf_call_sal(op_info);
+	}
+	else {
+		if (use_ipi) {
+			/* use an interprocessor interrupt to call SAL */
+			smp_call_function_single(cpu, sn_hwperf_call_sal,
+				op_info, 1, 1);
+		}
+		else {
+			/* migrate the task before calling SAL */ 
+			save_allowed = current->cpus_allowed;
+			set_cpus_allowed(current, cpumask_of_cpu(cpu));
+			sn_hwperf_call_sal(op_info);
+			set_cpus_allowed(current, save_allowed);
+		}
+	}
+	r = op_info->ret;
+
+out:
+	return r;
+}
+
+/*
+ * ioctl for "sn_hwperf" misc device
+ */
+static int
+sn_hwperf_ioctl(struct inode *in, struct file *fp, u32 op, u64 arg)
+{
+	struct sn_hwperf_ioctl_args a;
+	struct cpuinfo_ia64 *cdata;
+	struct sn_hwperf_object_info *objs;
+	struct sn_hwperf_object_info *cpuobj;
+	struct sn_hwperf_op_info op_info;
+	void *p = NULL;
+	int nobj;
+	char slice;
+	int node;
+	int r;
+	int v0;
+	int i;
+	int j;
+
+	unlock_kernel();
+
+	/* only user requests are allowed here */
+	if ((op & SN_HWPERF_OP_MASK) < 10) {
+		r = -EINVAL;
+		goto error;
+	}
+	r = copy_from_user(&a, (const void *)arg,
+		sizeof(struct sn_hwperf_ioctl_args));
+	if (r != 0) {
+		r = -EFAULT;
+		goto error;
+	}
+
+	/*
+	 * Allocate memory to hold a kernel copy of the user buffer. The
+	 * buffer contents are either copied in or out (or both) of user
+	 * space depending on the flags encoded in the requested operation.
+	 */
+	if (a.ptr) {
+		p = vmalloc(a.sz);
+		if (!p) {
+			r = -ENOMEM;
+			goto error;
+		}
+	}
+
+	if (op & SN_HWPERF_OP_MEM_COPYIN) {
+		r = copy_from_user(p, (const void *)a.ptr, a.sz);
+		if (r != 0) {
+			r = -EFAULT;
+			goto error;
+		}
+	}
+
+	switch (op) {
+	case SN_HWPERF_GET_CPU_INFO:
+		if (a.sz = sizeof(u64)) {
+			/* special case to get size needed */
+			*(u64 *) p = (u64) num_online_cpus() *
+				sizeof(struct sn_hwperf_object_info);
+		} else
+		if (a.sz < num_online_cpus() * sizeof(struct sn_hwperf_object_info)) {
+			r = -ENOMEM;
+			goto error;
+		} else
+		if ((r = sn_hwperf_enum_objects(&nobj, &objs)) = 0) {
+			memset(p, 0, a.sz);
+			for (i = 0; i < nobj; i++) {
+				node = sn_hwperf_obj_to_cnode(objs + i);
+				for_each_online_cpu(j) {
+					if (node != cpu_to_node(j))
+						continue;
+					cpuobj = (struct sn_hwperf_object_info *) p + j;
+					slice = 'a' + cpuid_to_slice(j);
+					cdata = cpu_data(j);
+					cpuobj->id = j;
+					snprintf(cpuobj->name,
+						 sizeof(cpuobj->name),
+						 "CPU %luMHz %s",
+						 cdata->proc_freq / 1000000,
+						 cdata->vendor);
+					snprintf(cpuobj->location,
+						 sizeof(cpuobj->location),
+						 "%s%c", objs[i].location,
+						 slice);
+				}
+			}
+
+			vfree(objs);
+		}
+		break;
+
+	case SN_HWPERF_GET_NODE_NASID:
+		if (a.sz != sizeof(u64) ||
+		   (node = a.arg) < 0 || node >= numnodes) {
+			r = -EINVAL;
+			goto error;
+		}
+		*(u64 *)p = (u64)cnodeid_to_nasid(node);
+		break;
+
+	case SN_HWPERF_GET_OBJ_NODE:
+		if (a.sz != sizeof(u64) || a.arg < 0) {
+			r = -EINVAL;
+			goto error;
+		}
+		if ((r = sn_hwperf_enum_objects(&nobj, &objs)) = 0) {
+			if (a.arg >= nobj) {
+				r = -EINVAL;
+				vfree(objs);
+				goto error;
+			}
+			if (objs[(i = a.arg)].id != a.arg) {
+				for (i = 0; i < nobj; i++) {
+					if (objs[i].id = a.arg)
+						break;
+				}
+			}
+			if (i = nobj) {
+				r = -EINVAL;
+				vfree(objs);
+				goto error;
+			}
+			*(u64 *)p = (u64)sn_hwperf_obj_to_cnode(objs + i);
+			vfree(objs);
+		}
+		break;
+
+	case SN_HWPERF_GET_MMRS:
+	case SN_HWPERF_SET_MMRS:
+	case SN_HWPERF_OBJECT_DISTANCE:
+		op_info.p = p;
+		op_info.a = &a;
+		op_info.v0 = &v0;
+		op_info.op = op;
+		r = sn_hwperf_op_cpu(&op_info);
+		break;
+
+	default:
+		/* all other ops are a direct SAL call */
+		r = ia64_sn_hwperf_op(sn_hwperf_master_nasid, op,
+			      a.arg, a.sz, (u64) p, 0, 0, &v0);
+		a.v0 = v0;
+		break;
+	}
+
+	if (op & SN_HWPERF_OP_MEM_COPYOUT) {
+		r = copy_to_user((void *)a.ptr, p, a.sz);
+		if (r != 0) {
+			r = -EFAULT;
+			goto error;
+		}
+	}
+
+error:
+	if (p)
+		vfree(p);
+
+	lock_kernel();
+	return r;
+}
+
+static struct file_operations sn_hwperf_fops = {
+	.ioctl = sn_hwperf_ioctl,
+};
+
+static struct miscdevice sn_hwperf_dev = {
+	MISC_DYNAMIC_MINOR,
+	"sn_hwperf",
+	&sn_hwperf_fops
+};
+
+static int sn_hwperf_init(void)
+{
+	u64 v;
+	int salr;
+	int e = 0;
+
+	/* single threaded, once-only initialization */
+	down(&sn_hwperf_init_mutex);
+	if (sn_hwperf_salheap) {
+		up(&sn_hwperf_init_mutex);
+		return e;
+	}
+
+	/*
+	 * The PROM code needs a fixed reference node. For convenience the
+	 * same node as the console I/O is used.
+	 */
+	sn_hwperf_master_nasid = (nasid_t) ia64_sn_get_console_nasid();
+
+	/*
+	 * Request the needed size and install the PROM scratch area.
+	 * The PROM keeps various tracking bits in this memory area.
+	 */
+	salr = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
+				 (u64) SN_HWPERF_GET_HEAPSIZE, 0,
+				 (u64) sizeof(u64), (u64) &v, 0, 0, NULL);
+	if (salr != SN_HWPERF_OP_OK) {
+		e = -EINVAL;
+		goto out;
+	}
+
+	if ((sn_hwperf_salheap = vmalloc(v)) = NULL) {
+		e = -ENOMEM;
+		goto out;
+	}
+	salr = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
+				 SN_HWPERF_INSTALL_HEAP, 0, v,
+				 (u64) sn_hwperf_salheap, 0, 0, NULL);
+	if (salr != SN_HWPERF_OP_OK) {
+		e = -EINVAL;
+		goto out;
+	}
+
+	salr = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
+				 SN_HWPERF_OBJECT_COUNT, 0,
+				 sizeof(u64), (u64) &v, 0, 0, NULL);
+	if (salr != SN_HWPERF_OP_OK) {
+		e = -EINVAL;
+		goto out;
+	}
+	sn_hwperf_obj_cnt = (int)v;
+
+out:
+	if (e < 0 && sn_hwperf_salheap) {
+		vfree(sn_hwperf_salheap);
+		sn_hwperf_salheap = NULL;
+		sn_hwperf_obj_cnt = 0;
+	}
+
+	if (!e) {
+		/*
+		 * Register a dynamic misc device for ioctl. Platforms
+		 * supporting hotplug will create /dev/sn_hwperf, else
+		 * user can to look up the minor number in /proc/misc.
+		 */
+		if ((e = misc_register(&sn_hwperf_dev)) != 0) {
+			printk(KERN_ERR "sn_hwperf_init: misc register "
+			       "for \"sn_hwperf\" failed, err %d\n", e);
+		}
+	}
+
+	up(&sn_hwperf_init_mutex);
+	return e;
+}
+
+int sn_topology_open(struct inode *inode, struct file *file)
+{
+	int e;
+	struct seq_file *seq;
+	struct sn_hwperf_object_info *objbuf;
+	int nobj;
+
+	if ((e = sn_hwperf_enum_objects(&nobj, &objbuf)) = 0) {
+		e = seq_open(file, &sn_topology_seq_ops);
+		seq = file->private_data;
+		seq->private = objbuf;
+	}
+
+	return e;
+}
+
+int sn_topology_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+
+	if (seq->private)
+		vfree(seq->private);
+	return seq_release(inode, file);
+}
Index: linux/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Fri Sep 10 13:58:39 2004
+++ linux/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	Fri Sep 10 15:27:38 2004
@@ -107,6 +107,10 @@
 	return e;
 }
 
+/* /proc/sgi_sn/sn_topology uses seq_file, see sn_hwperf.c */
+extern int sn_topology_open(struct inode *, struct file *);
+extern int sn_topology_release(struct inode *, struct file *);
+
 void register_sn_procfs(void)
 {
 	static struct proc_dir_entry *sgi_proc_dir = NULL;
@@ -132,6 +136,9 @@
 
 	sn_procfs_create_entry("coherence_id", sgi_proc_dir, 
 		coherence_id_open, single_release);
+	
+	sn_procfs_create_entry("sn_topology", sgi_proc_dir,
+		sn_topology_open, sn_topology_release);
 }
 
 #endif /* CONFIG_PROC_FS */
Index: linux/include/asm-ia64/sn/sn2/sn_hwperf.h
=================================--- linux.orig/include/asm-ia64/sn/sn2/sn_hwperf.h	Thu Jan  1 10:00:00 1970
+++ linux/include/asm-ia64/sn/sn2/sn_hwperf.h	Fri Sep 10 15:27:38 2004
@@ -0,0 +1,218 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
+ *
+ * Data types used by the SN_SAL_HWPERF_OP SAL call for monitoring
+ * SGI Altix node and router hardware
+ *
+ * Mark Goodwin <markgw@sgi.com> Mon Aug 30 12:23:46 EST 2004
+ */
+
+#ifndef SN_HWPERF_H
+#define SN_HWPERF_H
+
+/*
+ * object structure. SN_HWPERF_ENUM_OBJECTS and SN_HWPERF_GET_CPU_INFO
+ * return an array of these. Do not change this without also
+ * changing the corresponding SAL code.
+ */
+#define SN_HWPERF_MAXSTRING		128
+struct sn_hwperf_object_info {
+	u32 id;
+	union {
+		struct {
+			u64 this_part:1;
+			u64 is_shared:1;
+		} fields;
+		struct {
+			u64 flags;
+			u64 reserved;
+		} b;
+	} f;
+	char name[SN_HWPERF_MAXSTRING];
+	char location[SN_HWPERF_MAXSTRING];
+	u32 ports;
+};
+
+#define sn_hwp_this_part	f.fields.this_part
+#define sn_hwp_is_shared	f.fields.is_shared
+#define sn_hwp_flags		f.b.flags
+
+#define SN_HWPERF_FOREIGN(x)	(!(x)->sn_hwp_this_part && !(x)->sn_hwp_is_shared)
+
+/* numa port structure, SN_HWPERF_ENUM_PORTS returns an array of these */
+struct sn_hwperf_port_info {
+	u32 port;
+	u32 conn_id;
+	u32 conn_port;
+};
+
+/* for HWPERF_{GET,SET}_MMRS */
+struct sn_hwperf_data {
+	u64 addr;
+	u64 data;
+};
+
+/* user ioctl() argument, see below */
+struct sn_hwperf_ioctl_args {
+        u64 arg;		/* argument, usually an object id */
+        u64 sz;                 /* size of transfer */
+        void *ptr;              /* pointer to source/target */
+        u32 v0;			/* second return value */
+};
+
+/*
+ * For SN_HWPERF_{GET,SET}_MMRS and SN_HWPERF_OBJECT_DISTANCE,
+ * sn_hwperf_ioctl_args.arg can be used to specify a CPU on which
+ * to call SAL, and whether to use an interprocessor interrupt
+ * or task migration in order to do so. If the CPU specified is
+ * SN_HWPERF_ARG_ANY_CPU, then the current CPU will be used.
+ */
+#define SN_HWPERF_ARG_ANY_CPU		0x7fffffffUL
+#define SN_HWPERF_ARG_CPU_MASK		0x7fffffff00000000ULL
+#define SN_HWPERF_ARG_USE_IPI_MASK	0x8000000000000000ULL
+#define SN_HWPERF_ARG_OBJID_MASK	0x00000000ffffffffULL
+
+/* 
+ * ioctl requests on the "sn_hwperf" misc device that call SAL.
+ */
+#define SN_HWPERF_OP_MEM_COPYIN		0x1000
+#define SN_HWPERF_OP_MEM_COPYOUT	0x2000
+#define SN_HWPERF_OP_MASK		0x0fff
+
+/*
+ * Determine mem requirement.
+ * arg	don't care
+ * sz	8
+ * p	pointer to u64 integer
+ */
+#define	SN_HWPERF_GET_HEAPSIZE		1
+
+/*
+ * Install mem for SAL drvr
+ * arg	don't care
+ * sz	sizeof buffer pointed to by p
+ * p	pointer to buffer for scratch area
+ */
+#define SN_HWPERF_INSTALL_HEAP		2
+
+/*
+ * Determine number of objects
+ * arg	don't care
+ * sz	8
+ * p	pointer to u64 integer
+ */
+#define SN_HWPERF_OBJECT_COUNT		(10|SN_HWPERF_OP_MEM_COPYOUT)
+
+/*
+ * Determine object "distance", relative to a cpu. This operation can
+ * execute on a designated logical cpu number, using either an IPI or
+ * via task migration. If the cpu number is SN_HWPERF_ANY_CPU, then
+ * the current CPU is used. See the SN_HWPERF_ARG_* macros above.
+ *
+ * arg	bitmap of IPI flag, cpu number and object id
+ * sz	8
+ * p	pointer to u64 integer
+ */
+#define SN_HWPERF_OBJECT_DISTANCE	(11|SN_HWPERF_OP_MEM_COPYOUT)
+
+/*
+ * Enumerate objects. Special case if sz = 8, returns the required
+ * buffer size.
+ * arg	don't care
+ * sz	sizeof buffer pointed to by p
+ * p	pointer to array of struct sn_hwperf_object_info
+ */
+#define SN_HWPERF_ENUM_OBJECTS		(12|SN_HWPERF_OP_MEM_COPYOUT)
+
+/*
+ * Enumerate NumaLink ports for an object. Special case if sz = 8,
+ * returns the required buffer size.
+ * arg	object id
+ * sz	sizeof buffer pointed to by p
+ * p	pointer to array of struct sn_hwperf_port_info
+ */
+#define SN_HWPERF_ENUM_PORTS		(13|SN_HWPERF_OP_MEM_COPYOUT)
+
+/*
+ * SET/GET memory mapped registers. These operations can execute
+ * on a designated logical cpu number, using either an IPI or via
+ * task migration. If the cpu number is SN_HWPERF_ANY_CPU, then
+ * the current CPU is used. See the SN_HWPERF_ARG_* macros above.
+ *
+ * arg	bitmap of ipi flag, cpu number and object id
+ * sz	sizeof buffer pointed to by p
+ * p	pointer to array of struct sn_hwperf_data
+ */
+#define SN_HWPERF_SET_MMRS		(14|SN_HWPERF_OP_MEM_COPYIN)
+#define SN_HWPERF_GET_MMRS		(15|SN_HWPERF_OP_MEM_COPYOUT| \
+					    SN_HWPERF_OP_MEM_COPYIN)
+/*
+ * Lock a shared object
+ * arg	object id
+ * sz	don't care
+ * p	don't care
+ */
+#define SN_HWPERF_ACQUIRE		16
+
+/*
+ * Unlock a shared object
+ * arg	object id
+ * sz	don't care
+ * p	don't care
+ */
+#define SN_HWPERF_RELEASE		17
+
+/*
+ * Break a lock on a shared object
+ * arg	object id
+ * sz	don't care
+ * p	don't care
+ */
+#define SN_HWPERF_FORCE_RELEASE		18
+
+/*
+ * ioctl requests on "sn_hwperf" that do not call SAL
+ */
+
+/*
+ * get cpu info as an array of hwperf_object_info_t. 
+ * id is logical CPU number, name is description, location
+ * is geoid (e.g. 001c04#1c). Special case if sz = 8,
+ * returns the required buffer size.
+ *
+ * arg	don't care
+ * sz	sizeof buffer pointed to by p
+ * p	pointer to array of struct sn_hwperf_object_info
+ */
+#define SN_HWPERF_GET_CPU_INFO		(100|SN_HWPERF_OP_MEM_COPYOUT)
+
+/*
+ * Given an object id, return it's node number (aka cnode).
+ * arg	object id
+ * sz	8
+ * p	pointer to u64 integer
+ */
+#define SN_HWPERF_GET_OBJ_NODE		(101|SN_HWPERF_OP_MEM_COPYOUT)
+
+/*
+ * Given a node number (cnode), return it's nasid.
+ * arg	ordinal node number (aka cnodeid)
+ * sz	8
+ * p	pointer to u64 integer
+ */
+#define SN_HWPERF_GET_NODE_NASID	(102|SN_HWPERF_OP_MEM_COPYOUT)
+
+/* return codes */
+#define SN_HWPERF_OP_OK			0
+#define SN_HWPERF_OP_NOMEM		1
+#define SN_HWPERF_OP_NO_PERM		2
+#define SN_HWPERF_OP_IO_ERROR		3
+#define SN_HWPERF_OP_BUSY		4
+#define SN_HWPERF_OP_RECONFIGURE	253
+#define SN_HWPERF_OP_INVAL		254
+
+#endif				/* SN_HWPERF_H */
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	Fri Sep 10 15:26:56 2004
+++ linux/include/asm-ia64/sn/sn_sal.h	Fri Sep 10 15:27:38 2004
@@ -61,6 +61,7 @@
 
 #define  SN_SAL_SYSCTL_IOBRICK_PCI_OP		   0x02000042	// reentrant
 #define	 SN_SAL_IROUTER_OP			   0x02000043
+#define  SN_SAL_HWPERF_OP			   0x02000050   // lock
 
 /*
  * Service-specific constants
@@ -844,4 +845,21 @@
 	return (int) rv.status;
 }
 
+/*
+ * This is the access point to the Altix PROM hardware performance
+ * and status monitoring interface. For info on using this, see
+ * include/asm-ia64/sn/sn2/sn_hwperf.h
+ */
+static inline int
+ia64_sn_hwperf_op(nasid_t nasid, u64 opcode, u64 a0, u64 a1, u64 a2,
+                  u64 a3, u64 a4, int *v0)
+{
+	struct ia64_sal_retval rv;
+	SAL_CALL_NOLOCK(rv, SN_SAL_HWPERF_OP, (u64)nasid,
+		opcode, a0, a1, a2, a3, a4);
+	if (v0)
+		*v0 = (int) rv.v0;
+	return (int) rv.status;
+}
+
 #endif /* _ASM_IA64_SN_SN_SAL_H */


