From: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>
Date: Mon, 26 Dec 2005 08:28:39 +0000
Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <20051226002839.A24653@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E84044DE5EA@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E84044DE5EA@pdsmsx404>; from yanmin.zhang@intel.com on Mon, Dec 26, 2005 at 03:38:16PM +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Greg KH <greg@kroah.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, yanmin.zhang@intel.com

On Mon, Dec 26, 2005 at 03:38:16PM +0800, Zhang, Yanmin wrote:
> >>-----Original Message-----
> >>From: Greg KH [mailto:greg@kroah.com]
> >>Sent: 2005=C4=EA12=D4=C224=C8=D5 3:16
> >>To: Zhang, Yanmin
> >>Cc: Yanmin Zhang; linux-kernel@vger.kernel.org; discuss@x86-64.org; lin=
ux-ia64@vger.kernel.org; Siddha, Suresh B; Shah, Rajesh;
> >>Pallipadi, Venkatesh
> >>Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
> >>
> >>On Fri, Dec 23, 2005 at 12:03:27PM +0800, Zhang, Yanmin wrote:
> >>> >>Can't you just use an attribute group and attach it to the cpu kobj=
ect?
> >>> >>That would save an array of kobjects I think.
> >>> As you know, current i386/x86_64 arch also export cache info under
> >>> /sys/device/system/cpu/cpuX/cache. Is it clearer to export topology
> >>> under a new directory than under cpu directly?
> >>
> >>No, the place in the sysfs tree you are putting this is just fine.  I'm
> >>just saying that you do not need to create a new kobject for these
> >>attributes.  Just use an attribute group, and you will get the same
> >>naming, without the need for an extra kobject (and the whole array of
> >>kobjects) at all.
> >>
> >>Does that make more sense?
> Yes, indeed. Now, I used your idea and the patch became simpler. Thanks.
>=20
>=20
> >>
> >>> >>> +static int __cpuinit topology_cpu_callback(struct notifier_block=
 *nfb,
> >>> >>> +		unsigned long action, void *hcpu)
> >>> >>> +{
> >>> >>> +	unsigned int cpu =3D (unsigned long)hcpu;
> >>> >>> +	struct sys_device *sys_dev;
> >>> >>> +
> >>> >>> +	sys_dev =3D get_cpu_sysdev(cpu);
> >>> >>> +	switch (action) {
> >>> >>> +		case CPU_ONLINE:
> >>> >>> +			topology_add_dev(sys_dev);
> >>> >>> +			break;
> >>> >>> +#ifdef	CONFIG_HOTPLUG_CPU
> >>> >>> +		case CPU_DEAD:
> >>> >>> +			topology_remove_dev(sys_dev);
> >>> >>> +			break;
> >>> >>> +#endif
> >>> >>
> >>> >>Why ifdef?  Isn't it safe to just always have this in?
> >>> If no ifdef here, gcc reported a compiling warning when I compiled it
> >>> on IA64 with CONFIG_HOTPLUG_CPU=3Dn.
> >>
> >>Then you should probably go change it so that CPU_DEAD is defined on
> >>non-smp builds, otherwise the code gets quite messy like the above :)
>=20
> Sorry. My previous explanation is confusing. It's a link warning on ia64.=
 On ia64, the kernel vmlinux doesn't include section .exit.text, so ld will=
 report a link warning when a function is in section .exit.text and another=
 function (not in .exit.text) calls the first one. When CONFIG_HOTPLUG_CPU=
=3Dn, function topology_remove_dev is in section .exit.text, but its caller=
 topology_remove_dev is not in .exit.text.
>=20
> i386 and x86_64 kernel vmlinux does include .exit.text and discard it onl=
y when running, so there is no such warning on i386/x86_64.
>=20
> There is no other better approach to get rid of the warning unless we cha=
nge arch/ia64/kernel/vmlinux.lds.S to keep all .exit.text in kernel image.

Here is the new patch. Thank Greg.

---

diff -Nraup linux-2.6.15_rc3/arch/ia64/kernel/topology.c linux-2.6.15_rc3_t=
opology/arch/ia64/kernel/topology.c
--- linux-2.6.15_rc3/arch/ia64/kernel/topology.c	2001-06-06 08:57:20.000000=
000 +0800
+++ linux-2.6.15_rc3_topology/arch/ia64/kernel/topology.c	2001-06-06 08:55:=
35.000000000 +0800
@@ -98,4 +98,4 @@ out:
 	return err;
 }
=20
-__initcall(topology_init);
+subsys_initcall(topology_init);
diff -Nraup linux-2.6.15_rc3/Documentation/cputopology.txt linux-2.6.15_rc3=
_topology/Documentation/cputopology.txt
--- linux-2.6.15_rc3/Documentation/cputopology.txt	1970-01-01 08:00:00.0000=
00000 +0800
+++ linux-2.6.15_rc3_topology/Documentation/cputopology.txt	2001-06-06 08:5=
5:35.000000000 +0800
@@ -0,0 +1,31 @@
+
+Export cpu topology info by sysfs. Items (attributes) are similar
+to /proc/cpuinfo.
+
+1) /sys/devices/system/cpu/cpuX/topology/physical_package_id:
+represent the physical package id of  cpu X;
+2) /sys/devices/system/cpu/cpuX/topology/core_id:
+represent the cpu core id to cpu X;
+3) /sys/devices/system/cpu/cpuX/topology/thread_id:
+represent the cpu thread id  to cpu X;
+4) /sys/devices/system/cpu/cpuX/topology/thread_siblings:
+represent the thread siblings to cpu X in the same core;
+5) /sys/devices/system/cpu/cpuX/topology/core_siblings:
+represent the thread siblings to cpu X in the same physical package;
+
+To implement it in an architecture-neutral way, a new source file,
+driver/base/topology.c, is to export the 5 attributes.
+
+If one architecture wants to support this feature, it just needs to
+implement 5 defines, typically in file include/asm-XXX/topology.h.
+The 5 defines are:
+#define topology_physical_package_id(cpu)
+#define topology_core_id(cpu)
+#define topology_thread_id(cpu)
+#define topology_thread_siblings(cpu)
+#define topology_core_siblings(cpu)
+
+The type of siblings is cpumask_t.
+
+If an attribute isn't defined on an architecture, it won't be exported.
+
diff -Nraup linux-2.6.15_rc3/drivers/base/Makefile linux-2.6.15_rc3_topolog=
y/drivers/base/Makefile
--- linux-2.6.15_rc3/drivers/base/Makefile	2001-06-06 08:57:20.000000000 +0=
800
+++ linux-2.6.15_rc3_topology/drivers/base/Makefile	2001-06-06 08:55:35.000=
000000 +0800
@@ -8,6 +8,7 @@ obj-y			+=3D power/
 obj-$(CONFIG_FW_LOADER)	+=3D firmware_class.o
 obj-$(CONFIG_NUMA)	+=3D node.o
 obj-$(CONFIG_MEMORY_HOTPLUG) +=3D memory.o
+obj-$(CONFIG_SMP)	+=3D topology.o
=20
 ifeq ($(CONFIG_DEBUG_DRIVER),y)
 EXTRA_CFLAGS +=3D -DDEBUG
diff -Nraup linux-2.6.15_rc3/drivers/base/topology.c linux-2.6.15_rc3_topol=
ogy/drivers/base/topology.c
--- linux-2.6.15_rc3/drivers/base/topology.c	1970-01-01 08:00:00.000000000 =
+0800
+++ linux-2.6.15_rc3_topology/drivers/base/topology.c	2001-06-06 09:01:30.0=
00000000 +0800
@@ -0,0 +1,159 @@
+/*
+ * driver/base/topology.c - Populate sysfs with cpu topology information
+ *
+ * Written by: Zhang Yanmin, Intel Corporation
+ *
+ * Copyright (C) 2005, Intel Corp.
+ *
+ * All rights reserved.         =20
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ */
+#include <linux/sysdev.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/cpu.h>
+#include <linux/module.h>
+#include <linux/topology.h>
+
+#define define_one_ro(_name) 		\
+static SYSDEV_ATTR(_name, 0444, show_##_name, NULL)
+
+#define define_id_show_func(name)				\
+static ssize_t show_##name(struct sys_device *dev, char *buf)	\
+{								\
+	unsigned int cpu =3D dev->id;				\
+	return sprintf(buf, "%d\n", topology_##name(cpu));	\
+}
+
+#define define_siblings_show_func(name)					\
+static ssize_t show_##name(struct sys_device *dev, char *buf)		\
+{									\
+	ssize_t len =3D -1;						\
+	unsigned int cpu =3D dev->id;					\
+	len =3D cpumask_scnprintf(buf, NR_CPUS+1, topology_##name(cpu));	\
+	return (len + sprintf(buf + len, "\n"));			\
+}
+
+#ifdef	topology_physical_package_id
+define_id_show_func(physical_package_id);
+define_one_ro(physical_package_id);
+#define ref_physical_package_id_attr	&attr_physical_package_id.attr,
+#else
+#define ref_physical_package_id_attr
+#endif
+
+#ifdef topology_core_id
+define_id_show_func(core_id);
+define_one_ro(core_id);
+#define ref_core_id_attr		&attr_core_id.attr,
+#else
+#define ref_core_id_attr
+#endif
+
+#ifdef topology_thread_id
+define_id_show_func(thread_id);
+define_one_ro(thread_id);
+#define ref_thread_id_attr		&attr_thread_id.attr,
+#else
+#define ref_thread_id_attr
+#endif
+
+#ifdef topology_thread_siblings
+define_siblings_show_func(thread_siblings);
+define_one_ro(thread_siblings);
+#define ref_thread_siblings_attr	&attr_thread_siblings.attr,
+#else
+#define ref_thread_siblings_attr
+#endif
+
+#ifdef topology_core_siblings
+define_siblings_show_func(core_siblings);
+define_one_ro(core_siblings);
+#define ref_core_siblings_attr		&attr_core_siblings.attr,
+#else
+#define ref_core_siblings_attr
+#endif
+
+static struct attribute * default_attrs[] =3D {
+	ref_physical_package_id_attr
+	ref_core_id_attr
+	ref_thread_id_attr
+	ref_thread_siblings_attr
+	ref_core_siblings_attr
+	NULL
+};
+
+static struct attribute_group topology_attr_group =3D {
+	.attrs =3D default_attrs,
+	.name =3D "topology"
+};
+
+/* Add/Remove cpu_topology interface for CPU device */
+static int __cpuinit topology_add_dev(struct sys_device * sys_dev)
+{
+	sysfs_create_group(&sys_dev->kobj, &topology_attr_group);
+	return 0;
+}
+
+static int __cpuexit topology_remove_dev(struct sys_device * sys_dev)
+{
+	sysfs_remove_group(&sys_dev->kobj, &topology_attr_group);
+	return 0;
+}
+
+static int __cpuinit topology_cpu_callback(struct notifier_block *nfb,
+		unsigned long action, void *hcpu)
+{
+	unsigned int cpu =3D (unsigned long)hcpu;
+	struct sys_device *sys_dev;
+
+	sys_dev =3D get_cpu_sysdev(cpu);
+	switch (action) {
+		case CPU_ONLINE:
+			topology_add_dev(sys_dev);
+			break;
+#ifdef	CONFIG_HOTPLUG_CPU
+		case CPU_DEAD:
+			topology_remove_dev(sys_dev);
+			break;
+#endif
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block topology_cpu_notifier +{
+	.notifier_call =3D topology_cpu_callback,
+};
+
+static int __cpuinit topology_sysfs_init(void)
+{
+	int i;
+
+	for_each_online_cpu(i) {
+		topology_cpu_callback(&topology_cpu_notifier, CPU_ONLINE,
+				(void *)(long)i);
+	}
+
+	register_cpu_notifier(&topology_cpu_notifier);
+
+	return 0;
+}
+
+device_initcall(topology_sysfs_init);
+
diff -Nraup linux-2.6.15_rc3/include/asm-i386/topology.h linux-2.6.15_rc3_t=
opology/include/asm-i386/topology.h
--- linux-2.6.15_rc3/include/asm-i386/topology.h	2001-06-06 08:57:20.000000=
000 +0800
+++ linux-2.6.15_rc3_topology/include/asm-i386/topology.h	2001-06-06 08:55:=
35.000000000 +0800
@@ -27,6 +27,14 @@
 #ifndef _ASM_I386_TOPOLOGY_H
 #define _ASM_I386_TOPOLOGY_H
=20
+#ifdef CONFIG_SMP
+#define topology_physical_package_id(cpu)	phys_proc_id[cpu]
+#define topology_core_id(cpu)			cpu_core_id[cpu]
+#define topology_thread_id(cpu)			cpu_thread_id[cpu]
+#define topology_core_siblings(cpu)		cpu_core_map[cpu]
+#define topology_thread_siblings(cpu)		cpu_sibling_map[cpu]
+#endif
+
 #ifdef CONFIG_NUMA
=20
 #include <asm/mpspec.h>
diff -Nraup linux-2.6.15_rc3/include/asm-ia64/topology.h linux-2.6.15_rc3_t=
opology/include/asm-ia64/topology.h
--- linux-2.6.15_rc3/include/asm-ia64/topology.h	2001-06-06 08:57:20.000000=
000 +0800
+++ linux-2.6.15_rc3_topology/include/asm-ia64/topology.h	2001-06-06 08:55:=
35.000000000 +0800
@@ -100,6 +100,14 @@ void build_cpu_to_node_map(void);
=20
 #endif /* CONFIG_NUMA */
=20
+#ifdef CONFIG_SMP
+#define topology_physical_package_id(cpu)	cpu_data(cpu)->socket_id
+#define topology_core_id(cpu)		cpu_data(cpu)->core_id
+#define topology_thread_id(cpu)		cpu_data(cpu)->thread_id
+#define topology_core_siblings(cpu)		cpu_core_map[cpu]
+#define topology_thread_siblings(cpu)	cpu_sibling_map[cpu]
+#endif
+
 #include <asm-generic/topology.h>
=20
 #endif /* _ASM_IA64_TOPOLOGY_H */
diff -Nraup linux-2.6.15_rc3/include/asm-x86_64/topology.h linux-2.6.15_rc3=
_topology/include/asm-x86_64/topology.h
--- linux-2.6.15_rc3/include/asm-x86_64/topology.h	2001-06-06 08:57:20.0000=
00000 +0800
+++ linux-2.6.15_rc3_topology/include/asm-x86_64/topology.h	2001-06-06 08:5=
5:35.000000000 +0800
@@ -58,6 +58,14 @@ extern int __node_distance(int, int);
=20
 #endif
=20
+#ifdef CONFIG_SMP
+#define topology_physical_package_id(cpu)	phys_proc_id[cpu]
+#define topology_core_id(cpu)			cpu_core_id[cpu]
+#define topology_thread_id(cpu)			cpu_thread_id[cpu]
+#define topology_core_siblings(cpu)		cpu_core_map[cpu]
+#define topology_thread_siblings(cpu)		cpu_sibling_map[cpu]
+#endif
+
 #include <asm-generic/topology.h>
=20
 #endif
