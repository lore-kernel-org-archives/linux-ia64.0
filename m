From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 06 Mar 2003 00:12:49 +0000
Subject: [Linux-ia64] Yet another SN update
MIME-Version: 1
Content-Type: multipart/mixed; boundary="8GpibOaaTibBMecb"
Message-Id: <marc-linux-ia64-105590709805981@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--8GpibOaaTibBMecb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Sorry I didn't include this in my last set of patches David, but I
didn't get it done until just the other day.  This patch gives
arch/ia64/sn its own Makefile and adds another target to the toplevel
ia64 makefile.  Hopefully this means that we won't have to bother you
with Makefile updates in the future.  It also includes some other SN
specific fixes that I needed to get a kernel building, linking, and
booting in the simulator (almost there!).  Only a few, small pieces
missing now...

Thanks,
Jesse

--8GpibOaaTibBMecb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn-2.5.60-ia64.patch"

diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/Makefile work-sn2/arch/ia64/Makefile
--- linux-2.5.60-ia64-sn/arch/ia64/Makefile	Mon Feb 24 18:28:25 2003
+++ work-sn2/arch/ia64/Makefile	Sun Mar  2 10:21:35 2003
@@ -50,16 +50,14 @@
 core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/ arch/ia64/hp/common/ arch/ia64/hp/zx1/ \
 				   arch/ia64/hp/sim/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
-core-$(CONFIG_IA64_SGI_SN)	+= arch/ia64/sn/kernel/ \
-				   arch/ia64/sn/kernel/sn2/ \
-				   arch/ia64/sn/io/ \
-				   arch/ia64/sn/io/sn2/ \
-				   arch/ia64/sn/io/sn2/pcibr/
+core-$(CONFIG_IA64_SGI_SN)	+= arch/ia64/sn/
+
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
 
 boot := arch/ia64/boot
+fakeprom := arch/ia64/sn/fakeprom
 tools := arch/ia64/tools
 
 .PHONY: boot compressed include/asm-ia64/offsets.h
@@ -85,10 +83,14 @@
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
+fakeprom:
+	$(Q)$(MAKE) $(build)=$(fakeprom) $@
+
 include/asm-ia64/offsets.h: include/asm include/linux/version.h include/config/MARKER
 	$(Q)$(MAKE) $(build)=$(tools) $@
 
 define archhelp
   echo '  compressed	- Build compressed kernel image'
   echo '  boot		- Build vmlinux and bootloader for Ski simulator'
+  echo '  fakeprom	- Build fakeprom for Medusa simulator'
 endef
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/Makefile work-sn2/arch/ia64/sn/Makefile
--- linux-2.5.60-ia64-sn/arch/ia64/sn/Makefile	Wed Dec 31 16:00:00 1969
+++ work-sn2/arch/ia64/sn/Makefile	Mon Mar  3 14:54:03 2003
@@ -0,0 +1,9 @@
+# arch/ia64/sn/Makefile
+#
+# Copyright (C) 1999,2001-2002 Silicon Graphics, Inc.  All Rights Reserved.
+#
+
+EXTRA_CFLAGS    := -DLITTLE_ENDIAN
+
+obj-y += kernel/ io/
+
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/io/Makefile work-sn2/arch/ia64/sn/io/Makefile
--- linux-2.5.60-ia64-sn/arch/ia64/sn/io/Makefile	Mon Feb 24 16:33:48 2003
+++ work-sn2/arch/ia64/sn/io/Makefile	Mon Mar  3 14:54:44 2003
@@ -13,10 +13,13 @@
 EXTRA_CFLAGS    += -DSHUB_SWAP_WAR
 endif
 
-obj-$(CONFIG_IA64_SGI_SN) += stubs.o sgi_if.o xswitch.o klgraph_hack.o \
-		hcl.o labelcl.o invent.o sgi_io_sim.o \
-		klgraph_hack.o hcl_util.o cdl.o hubdev.o hubspc.o \
-		alenlist.o pci.o pci_dma.o ate_utils.o \
-		ifconfig_net.o io.o ioconfig_bus.o
+#obj-$(CONFIG_IA64_SGI_SN) += stubs.o sgi_if.o xswitch.o klgraph_hack.o \
+#		hcl.o labelcl.o invent.o sgi_io_sim.o \
+#		klgraph_hack.o hcl_util.o cdl.o hubdev.o hubspc.o \
+#		alenlist.o pci.o pci_dma.o ate_utils.o \
+#		ifconfig_net.o io.o ioconfig_bus.o
+
+obj-$(CONFIG_IA64_SGI_SN1) += sn1/
+obj-$(CONFIG_IA64_SGI_SN2) += sn2/
 
 obj-$(CONFIG_PCIBA)		+= pciba.o
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/io/sn2/Makefile work-sn2/arch/ia64/sn/io/sn2/Makefile
--- linux-2.5.60-ia64-sn/arch/ia64/sn/io/sn2/Makefile	Mon Feb 24 13:40:29 2003
+++ work-sn2/arch/ia64/sn/io/sn2/Makefile	Mon Mar  3 15:57:35 2003
@@ -9,10 +9,12 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
-obj-y += bte_error.o geo_op.o klconflib.o klgraph.o l1.o \
-	 l1_command.o ml_iograph.o ml_SN_init.o ml_SN_intr.o module.o \
-	 pci_bus_cvlink.o pciio.o pic.o sgi_io_init.o shub.o shuberror.o \
-	 shub_intr.o shubio.o xbow.o xtalk.o
+#obj-y += pcibr/ bte_error.o geo_op.o klconflib.o klgraph.o l1.o \
+#	 l1_command.o ml_iograph.o ml_SN_init.o ml_SN_intr.o module.o \
+#	 pci_bus_cvlink.o pciio.o pic.o sgi_io_init.o shub.o shuberror.o \
+#	 shub_intr.o shubio.o xbow.o xtalk.o
+
+obj-y += l1.o l1_command.o
 
 obj-$(CONFIG_KDB) += kdba_io.o 
 
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/io/sn2/l1_command.c work-sn2/arch/ia64/sn/io/sn2/l1_command.c
--- linux-2.5.60-ia64-sn/arch/ia64/sn/io/sn2/l1_command.c	Mon Feb 24 13:24:42 2003
+++ work-sn2/arch/ia64/sn/io/sn2/l1_command.c	Wed Mar  5 15:41:55 2003
@@ -154,7 +154,7 @@
 
     return ret;
 }
-
+#ifdef CONFIG_PCI
 /*
  * iobrick_module_get_nasid() returns a module_id which has the brick
  * type encoded in bits 15-12, but this is not the true brick type...
@@ -185,7 +185,7 @@
 
     return -1;    /* unknown brick */
 }
-
+#endif
 int iobrick_module_get_nasid(nasid_t nasid)
 {
     int io_moduleid;
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/kernel/Makefile work-sn2/arch/ia64/sn/kernel/Makefile
--- linux-2.5.60-ia64-sn/arch/ia64/sn/kernel/Makefile	Mon Feb 10 10:37:59 2003
+++ work-sn2/arch/ia64/sn/kernel/Makefile	Sun Mar  2 10:40:53 2003
@@ -33,14 +33,10 @@
 
 EXTRA_CFLAGS    := -DLITTLE_ENDIAN
 
-.S.s:
-	$(CPP) $(AFLAGS) $(AFLAGS_KERNEL) -o $*.s $<
-.S.o:
-	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -o $*.o $<
+obj-y				:= probe.o setup.o sn_asm.o sv.o bte.o iomv.o
 
-obj-y		= probe.o setup.o sn_asm.o sv.o bte.o iomv.o
-obj-$(CONFIG_IA64_SGI_SN1)      += irq.o mca.o
-obj-$(CONFIG_IA64_SGI_SN2)      += irq.o mca.o
+obj-$(CONFIG_IA64_SGI_SN1)      += sn1/ irq.o mca.o
+obj-$(CONFIG_IA64_SGI_SN2)      += sn2/ irq.o mca.o
 obj-$(CONFIG_IA64_SGI_AUTOTEST) += llsc4.o misctest.o
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_MODULES)           += sn_ksyms.o
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/kernel/setup.c work-sn2/arch/ia64/sn/kernel/setup.c
--- linux-2.5.60-ia64-sn/arch/ia64/sn/kernel/setup.c	Mon Feb 24 18:28:16 2003
+++ work-sn2/arch/ia64/sn/kernel/setup.c	Wed Mar  5 15:34:27 2003
@@ -237,7 +237,7 @@
 		       "%x.%02x\n", SN_SAL_MIN_MAJOR, SN_SAL_MIN_MINOR);
 		panic("PROM version too old\n");
 	}
-
+#ifdef CONFIG_PCI
 #ifdef CONFIG_IA64_SGI_SN2
 	{
 		extern void io_sh_swapper(int, int);
@@ -253,7 +253,7 @@
 		(void)get_master_baseio_nasid();
 	}
 #endif
-
+#endif /* CONFIG_PCI */
 	status = ia64_sal_freq_base(SAL_FREQ_BASE_REALTIME_CLOCK, &ticks_per_sec, &drift);
 	if (status != 0 || ticks_per_sec < 100000) {
 		printk(KERN_WARNING "unable to determine platform RTC clock frequency, guessing.\n");
@@ -349,7 +349,7 @@
         for (cnode=0; cnode < numnodes; cnode++)
 		memcpy(nodepdaindr[cnode]->pernode_pdaindr, nodepdaindr, sizeof(nodepdaindr));
 
-
+#ifdef CONFIG_PCI
 	/*
 	 * Set up IO related platform-dependent nodepda fields.
 	 * The following routine actually sets up the hubinfo struct
@@ -359,6 +359,7 @@
 		init_platform_nodepda(nodepdaindr[cnode], cnode);
 		bte_init_node (nodepdaindr[cnode], cnode);
 	}
+#endif
 }
 
 /**
diff -Naur -X /usr/people/jbarnes/dontdiff linux-2.5.60-ia64-sn/arch/ia64/sn/tools/make_textsym work-sn2/arch/ia64/sn/tools/make_textsym
--- linux-2.5.60-ia64-sn/arch/ia64/sn/tools/make_textsym	Mon Feb 10 10:37:55 2003
+++ work-sn2/arch/ia64/sn/tools/make_textsym	Wed Dec 31 16:00:00 1969
@@ -1,171 +0,0 @@
-#!/bin/sh
-#
-# Build a textsym file for use in the Arium ITP probe.
-#
-#
-# This file is subject to the terms and conditions of the GNU General Public
-# License.  See the file "COPYING" in the main directory of this archive
-# for more details.
-#
-# Copyright (c) 2001-2002 Silicon Graphics, Inc.  All rights reserved.
-#
-
-help() {
-cat <<END
-Build a WinDD "symtxt" file for use with the Arium ECM-30 probe.
-
-	Usage: $0 [<vmlinux file> [<output file>]]
-		If no input file is specified, it defaults to vmlinux.
-		If no output file name is specified, it defaults to "textsym".
-END
-exit 1
-}
-
-err () {
-	echo "ERROR - $*" >&2
-	exit 1
-}
-
-
-OPTS="H"
-while getopts "$OPTS" c ; do
-	case $c in
-		H)  help;;
-		\?) help;;
-	esac
-
-done
-shift `expr $OPTIND - 1`
-
-LINUX=${1:-vmlinux}
-TEXTSYM=${2:-${LINUX}.sym}
-TMPSYM=${2:-${LINUX}.sym.tmp}
-trap "/bin/rm -f $TMPSYM" 0
-
-[ -f $VMLINUX ] || help
-
-$OBJDUMP -t $LINUX | egrep -v '__ks' | sort > $TMPSYM
-SN1=`egrep "dig_setup|Synergy_da_indr" $TMPSYM|wc -l`
-
-# Dataprefix and textprefix correspond to the VGLOBAL_BASE and VPERNODE_BASE.
-# Eventually, these values should be:
-#	dataprefix	ffffffff
-#	textprefix	fffffffe
-# but right now they're still changing, so make them dynamic.
-dataprefix=`awk ' / \.data	/ { print substr($1, 0, 8) ; exit ; }' $TMPSYM`
-textprefix=`awk ' / \.text	/ { print substr($1, 0, 8) ; exit ; }' $TMPSYM`
-
-# pipe everything thru sort
-echo "TEXTSYM V1.0"
-(cat <<END 
-GLOBAL | ${textprefix}00000000 | CODE | VEC_VHPT_Translation_0000
-GLOBAL | ${textprefix}00000400 | CODE | VEC_ITLB_0400
-GLOBAL | ${textprefix}00000800 | CODE | VEC_DTLB_0800
-GLOBAL | ${textprefix}00000c00 | CODE | VEC_Alt_ITLB_0c00
-GLOBAL | ${textprefix}00001000 | CODE | VEC_Alt_DTLB_1000
-GLOBAL | ${textprefix}00001400 | CODE | VEC_Data_nested_TLB_1400
-GLOBAL | ${textprefix}00001800 | CODE | VEC_Instruction_Key_Miss_1800
-GLOBAL | ${textprefix}00001c00 | CODE | VEC_Data_Key_Miss_1c00
-GLOBAL | ${textprefix}00002000 | CODE | VEC_Dirty-bit_2000
-GLOBAL | ${textprefix}00002400 | CODE | VEC_Instruction_Access-bit_2400
-GLOBAL | ${textprefix}00002800 | CODE | VEC_Data_Access-bit_2800
-GLOBAL | ${textprefix}00002c00 | CODE | VEC_Break_instruction_2c00
-GLOBAL | ${textprefix}00003000 | CODE | VEC_External_Interrupt_3000
-GLOBAL | ${textprefix}00003400 | CODE | VEC_Reserved_3400
-GLOBAL | ${textprefix}00003800 | CODE | VEC_Reserved_3800
-GLOBAL | ${textprefix}00003c00 | CODE | VEC_Reserved_3c00
-GLOBAL | ${textprefix}00004000 | CODE | VEC_Reserved_4000
-GLOBAL | ${textprefix}00004400 | CODE | VEC_Reserved_4400
-GLOBAL | ${textprefix}00004800 | CODE | VEC_Reserved_4800
-GLOBAL | ${textprefix}00004c00 | CODE | VEC_Reserved_4c00
-GLOBAL | ${textprefix}00005000 | CODE | VEC_Page_Not_Present_5000
-GLOBAL | ${textprefix}00005100 | CODE | VEC_Key_Permission_5100
-GLOBAL | ${textprefix}00005200 | CODE | VEC_Instruction_Access_Rights_5200
-GLOBAL | ${textprefix}00005300 | CODE | VEC_Data_Access_Rights_5300
-GLOBAL | ${textprefix}00005400 | CODE | VEC_General_Exception_5400
-GLOBAL | ${textprefix}00005500 | CODE | VEC_Disabled_FP-Register_5500
-GLOBAL | ${textprefix}00005600 | CODE | VEC_Nat_Consumption_5600
-GLOBAL | ${textprefix}00005700 | CODE | VEC_Speculation_5700
-GLOBAL | ${textprefix}00005800 | CODE | VEC_Reserved_5800
-GLOBAL | ${textprefix}00005900 | CODE | VEC_Debug_5900
-GLOBAL | ${textprefix}00005a00 | CODE | VEC_Unaligned_Reference_5a00
-GLOBAL | ${textprefix}00005b00 | CODE | VEC_Unsupported_Data_Reference_5b00
-GLOBAL | ${textprefix}00005c00 | CODE | VEC_Floating-Point_Fault_5c00
-GLOBAL | ${textprefix}00005d00 | CODE | VEC_Floating_Point_Trap_5d00
-GLOBAL | ${textprefix}00005e00 | CODE | VEC_Lower_Privilege_Tranfer_Trap_5e00
-GLOBAL | ${textprefix}00005f00 | CODE | VEC_Taken_Branch_Trap_5f00
-GLOBAL | ${textprefix}00006000 | CODE | VEC_Single_Step_Trap_6000
-GLOBAL | ${textprefix}00006100 | CODE | VEC_Reserved_6100
-GLOBAL | ${textprefix}00006200 | CODE | VEC_Reserved_6200
-GLOBAL | ${textprefix}00006300 | CODE | VEC_Reserved_6300
-GLOBAL | ${textprefix}00006400 | CODE | VEC_Reserved_6400
-GLOBAL | ${textprefix}00006500 | CODE | VEC_Reserved_6500
-GLOBAL | ${textprefix}00006600 | CODE | VEC_Reserved_6600
-GLOBAL | ${textprefix}00006700 | CODE | VEC_Reserved_6700
-GLOBAL | ${textprefix}00006800 | CODE | VEC_Reserved_6800
-GLOBAL | ${textprefix}00006900 | CODE | VEC_IA-32_Exeception_6900
-GLOBAL | ${textprefix}00006a00 | CODE | VEC_IA-32_Intercept_6a00
-GLOBAL | ${textprefix}00006b00 | CODE | VEC_IA-32_Interrupt_6b00
-GLOBAL | ${textprefix}00006c00 | CODE | VEC_Reserved_6c00
-GLOBAL | ${textprefix}00006d00 | CODE | VEC_Reserved_6d00
-GLOBAL | ${textprefix}00006e00 | CODE | VEC_Reserved_6e00
-GLOBAL | ${textprefix}00006f00 | CODE | VEC_Reserved_6f00
-GLOBAL | ${textprefix}00007000 | CODE | VEC_Reserved_7000
-GLOBAL | ${textprefix}00007100 | CODE | VEC_Reserved_7100
-GLOBAL | ${textprefix}00007200 | CODE | VEC_Reserved_7200
-GLOBAL | ${textprefix}00007300 | CODE | VEC_Reserved_7300
-GLOBAL | ${textprefix}00007400 | CODE | VEC_Reserved_7400
-GLOBAL | ${textprefix}00007500 | CODE | VEC_Reserved_7500
-GLOBAL | ${textprefix}00007600 | CODE | VEC_Reserved_7600
-GLOBAL | ${textprefix}00007700 | CODE | VEC_Reserved_7700
-GLOBAL | ${textprefix}00007800 | CODE | VEC_Reserved_7800
-GLOBAL | ${textprefix}00007900 | CODE | VEC_Reserved_7900
-GLOBAL | ${textprefix}00007a00 | CODE | VEC_Reserved_7a00
-GLOBAL | ${textprefix}00007b00 | CODE | VEC_Reserved_7b00
-GLOBAL | ${textprefix}00007c00 | CODE | VEC_Reserved_7c00
-GLOBAL | ${textprefix}00007d00 | CODE | VEC_Reserved_7d00
-GLOBAL | ${textprefix}00007e00 | CODE | VEC_Reserved_7e00
-GLOBAL | ${textprefix}00007f00 | CODE | VEC_Reserved_7f00
-END
-
-
-awk '
-/__start_gate_section/ {start=1}
-/^'${dataprefix}\|${textprefix}'/ {
-	if ($4 == ".kdb")
-		next
-	if (start && substr($NF,1,1) != "0") {
-		type = substr($0,26,5)
-		if (type == ".text")
-			printf "GLOBAL | %s | CODE | %s\n", $1, $NF
-		else {
-			n = 0
-			s = $(NF-1)
-			while (length(s) > 0) {
-				n = n*16 + substr(s,1,1)
-				s = substr(s,2)
-			}
-			printf "GLOBAL | %s | DATA | %s | %d\n", $1, $NF, n
-		}
-	}
-	if($NF == "_end") 
-		exit
-
-}
-' $TMPSYM ) | egrep -v " __device| __vendor" | awk -v sn1="$SN1" '
-/GLOBAL/ {
-	print $0
-	if (sn1 != 0) {
-		/* 32 bits of sn1 physical addrs, */
-		print substr($0,1,9) "04" substr($0,20,16) "Phy_" substr($0,36)
-	} else {
-		/* 38 bits of sn2 physical addrs, need addr space bits */
-		print substr($0,1,9) "3004" substr($0,20,16) "Phy_" substr($0,36)
-	}
-
-} ' | sort -k3
-
-N=`wc -l $TEXTSYM|awk '{print $1}'`
-echo "Generated TEXTSYM file" >&2
-echo "  $LINUX --> $TEXTSYM" >&2
-echo "  Found $N symbols" >&2
diff -Naru linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/Makefile work-sn2/arch/ia64/sn/fakeprom/Makefile
--- linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/Makefile	Mon Feb 10 10:38:53 2003
+++ work-sn2/arch/ia64/sn/fakeprom/Makefile	Mon Mar  3 13:30:10 2003
@@ -3,18 +3,22 @@
 # License.  See the file "COPYING" in the main directory of this archive
 # for more details.
 #
-#  Copyright (c) 2000-2001 Silicon Graphics, Inc.  All rights reserved.
+#  Copyright (c) 2000-2003 Silicon Graphics, Inc.  All rights reserved.
 #
 
-obj-y=fpromasm.o main.o fw-emu.o fpmem.o klgraph_init.o
+targets-$(CONFIG_IA64_SGI_SN) := fakeprom
 
-fprom: $(OBJ)
-	$(LD) -static -Tfprom.lds -o fprom $(OBJ) $(LIB)
+OBJS := $(obj)/fpromasm.o $(obj)/main.o $(obj)/fw-emu.o $(obj)/fpmem.o \
+	$(obj)/klgraph_init.o
 
-.S.o:
-	$(CC)  -D__ASSEMBLY__ $(AFLAGS) $(AFLAGS_KERNEL) -c -o $*.o $<
-.c.o:
-	$(CC)  $(CFLAGS) $(CFLAGS_KERNEL) -c -o $*.o $<
+fakeprom: $(obj)/fakeprom $(obj)/vmlinux.sym
+	cp $(obj)/fakeprom $(obj)/fprom
 
-clean:
-	rm -f *.o fprom
+LDFLAGS_fakeprom = -static -T
+
+$(obj)/fakeprom: $(src)/fprom.lds $(OBJS) arch/ia64/lib/lib.a
+	$(call if_changed,ld)
+
+$(obj)/vmlinux.sym: $(src)/make_textsym System.map
+	$(src)/make_textsym vmlinux > vmlinux.sym
+	$(call cmd,cptotop)
diff -Naru linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/README work-sn2/arch/ia64/sn/fakeprom/README
--- linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/README	Mon Feb 10 10:39:16 2003
+++ work-sn2/arch/ia64/sn/fakeprom/README	Mon Mar  3 13:53:11 2003
@@ -1,3 +1,35 @@
+/*
+ * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify it 
+ * under the terms of version 2 of the GNU General Public License 
+ * as published by the Free Software Foundation.
+ * 
+ * This program is distributed in the hope that it would be useful, but 
+ * WITHOUT ANY WARRANTY; without even the implied warranty of 
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
+ * 
+ * Further, this software is distributed without any warranty that it is 
+ * free of the rightful claim of any third person regarding infringement 
+ * or the like.  Any license provided herein, whether implied or 
+ * otherwise, applies only to this software file.  Patent licenses, if 
+ * any, provided herein do not apply to combinations of this program with 
+ * other software, or any other product whatsoever.
+ * 
+ * You should have received a copy of the GNU General Public 
+ * License along with this program; if not, write the Free Software 
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ * 
+ * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
+ * Mountain View, CA  94043, or:
+ * 
+ * http://www.sgi.com 
+ * 
+ * For further information regarding this notice, see: 
+ * 
+ * http://oss.sgi.com/projects/GenInfo/NoticeExplan
+ */
+
 This directory contains the files required to build
 the fake PROM image that is currently being used to
 boot IA64 kernels running under the SGI Medusa kernel.
diff -Naru linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/fpmem.c work-sn2/arch/ia64/sn/fakeprom/fpmem.c
--- linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/fpmem.c	Mon Feb 10 10:38:20 2003
+++ work-sn2/arch/ia64/sn/fakeprom/fpmem.c	Mon Mar  3 13:53:59 2003
@@ -4,7 +4,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2002 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (C) 2000-2003 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -168,13 +168,13 @@
 #endif
 
 void
-build_mem_desc(efi_memory_desc_t *md, int type, long paddr, long numbytes)
+build_mem_desc(efi_memory_desc_t *md, int type, long paddr, long numbytes, long attr)
 {
         md->type = type;
         md->phys_addr = paddr;
         md->virt_addr = 0;
         md->num_pages = numbytes >> 12;
-        md->attribute = EFI_MEMORY_WB;
+        md->attribute = attr;
 }
 
 int
@@ -236,28 +236,40 @@
                                  */
                                 if (bank == 0) {
 					if (cnode == 0) {
+						hole = 2*1024*1024;
+						build_mem_desc(md, EFI_PAL_CODE, paddr, hole, EFI_MEMORY_WB|EFI_MEMORY_WB);
+						numbytes -= hole;
+                                        	paddr += hole;
+			        		count++ ;
+                                        	md += mdsize;
 						hole = 1*1024*1024;
-						build_mem_desc(md, EFI_PAL_CODE, paddr, hole);
+						build_mem_desc(md, EFI_CONVENTIONAL_MEMORY, paddr, hole, EFI_MEMORY_UC);
 						numbytes -= hole;
                                         	paddr += hole;
 			        		count++ ;
                                         	md += mdsize;
-						hole = 3*1024*1024;
-						build_mem_desc(md, EFI_RUNTIME_SERVICES_DATA, paddr, hole);
+						hole = 1*1024*1024;
+						build_mem_desc(md, EFI_RUNTIME_SERVICES_DATA, paddr, hole, EFI_MEMORY_WB|EFI_MEMORY_WB);
 						numbytes -= hole;
                                         	paddr += hole;
 			        		count++ ;
                                         	md += mdsize;
 					} else {
-						hole = PROMRESERVED_SIZE;
-                                        	build_mem_desc(md, EFI_RUNTIME_SERVICES_DATA, paddr, hole);
+						hole = 2*1024*1024;
+                                        	build_mem_desc(md, EFI_RUNTIME_SERVICES_DATA, paddr, hole, EFI_MEMORY_WB|EFI_MEMORY_WB);
+						numbytes -= hole;
+                                        	paddr += hole;
+			        		count++ ;
+                                        	md += mdsize;
+						hole = 2*1024*1024;
+                                        	build_mem_desc(md, EFI_RUNTIME_SERVICES_DATA, paddr, hole, EFI_MEMORY_UC);
 						numbytes -= hole;
                                         	paddr += hole;
 			        		count++ ;
                                         	md += mdsize;
 					}
                                 }
-                                build_mem_desc(md, EFI_CONVENTIONAL_MEMORY, paddr, numbytes);
+                                build_mem_desc(md, EFI_CONVENTIONAL_MEMORY, paddr, numbytes, EFI_MEMORY_WB|EFI_MEMORY_WB);
 
 			        md += mdsize ;
 			        count++ ;
diff -Naru linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/fprom.lds work-sn2/arch/ia64/sn/fakeprom/fprom.lds
--- linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/fprom.lds	Mon Feb 10 10:38:49 2003
+++ work-sn2/arch/ia64/sn/fakeprom/fprom.lds	Mon Mar  3 13:54:18 2003
@@ -1,3 +1,34 @@
+/*
+ * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify it 
+ * under the terms of version 2 of the GNU General Public License 
+ * as published by the Free Software Foundation.
+ * 
+ * This program is distributed in the hope that it would be useful, but 
+ * WITHOUT ANY WARRANTY; without even the implied warranty of 
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
+ * 
+ * Further, this software is distributed without any warranty that it is 
+ * free of the rightful claim of any third person regarding infringement 
+ * or the like.  Any license provided herein, whether implied or 
+ * otherwise, applies only to this software file.  Patent licenses, if 
+ * any, provided herein do not apply to combinations of this program with 
+ * other software, or any other product whatsoever.
+ * 
+ * You should have received a copy of the GNU General Public 
+ * License along with this program; if not, write the Free Software 
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
+ * 
+ * Contact information:  Silicon Graphics, Inc., 1600 Amphitheatre Pkwy, 
+ * Mountain View, CA  94043, or:
+ * 
+ * http://www.sgi.com 
+ * 
+ * For further information regarding this notice, see: 
+ * 
+ * http://oss.sgi.com/projects/GenInfo/NoticeExplan
+ */
 
 OUTPUT_FORMAT("elf64-ia64-little")
 OUTPUT_ARCH(ia64)
diff -Naru linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/make_textsym work-sn2/arch/ia64/sn/fakeprom/make_textsym
--- linux-2.5.60-ia64-sn/arch/ia64/sn/fakeprom/make_textsym	Wed Dec 31 16:00:00 1969
+++ work-sn2/arch/ia64/sn/fakeprom/make_textsym	Mon Feb 10 10:37:55 2003
@@ -0,0 +1,171 @@
+#!/bin/sh
+#
+# Build a textsym file for use in the Arium ITP probe.
+#
+#
+# This file is subject to the terms and conditions of the GNU General Public
+# License.  See the file "COPYING" in the main directory of this archive
+# for more details.
+#
+# Copyright (c) 2001-2002 Silicon Graphics, Inc.  All rights reserved.
+#
+
+help() {
+cat <<END
+Build a WinDD "symtxt" file for use with the Arium ECM-30 probe.
+
+	Usage: $0 [<vmlinux file> [<output file>]]
+		If no input file is specified, it defaults to vmlinux.
+		If no output file name is specified, it defaults to "textsym".
+END
+exit 1
+}
+
+err () {
+	echo "ERROR - $*" >&2
+	exit 1
+}
+
+
+OPTS="H"
+while getopts "$OPTS" c ; do
+	case $c in
+		H)  help;;
+		\?) help;;
+	esac
+
+done
+shift `expr $OPTIND - 1`
+
+LINUX=${1:-vmlinux}
+TEXTSYM=${2:-${LINUX}.sym}
+TMPSYM=${2:-${LINUX}.sym.tmp}
+trap "/bin/rm -f $TMPSYM" 0
+
+[ -f $VMLINUX ] || help
+
+$OBJDUMP -t $LINUX | egrep -v '__ks' | sort > $TMPSYM
+SN1=`egrep "dig_setup|Synergy_da_indr" $TMPSYM|wc -l`
+
+# Dataprefix and textprefix correspond to the VGLOBAL_BASE and VPERNODE_BASE.
+# Eventually, these values should be:
+#	dataprefix	ffffffff
+#	textprefix	fffffffe
+# but right now they're still changing, so make them dynamic.
+dataprefix=`awk ' / \.data	/ { print substr($1, 0, 8) ; exit ; }' $TMPSYM`
+textprefix=`awk ' / \.text	/ { print substr($1, 0, 8) ; exit ; }' $TMPSYM`
+
+# pipe everything thru sort
+echo "TEXTSYM V1.0"
+(cat <<END 
+GLOBAL | ${textprefix}00000000 | CODE | VEC_VHPT_Translation_0000
+GLOBAL | ${textprefix}00000400 | CODE | VEC_ITLB_0400
+GLOBAL | ${textprefix}00000800 | CODE | VEC_DTLB_0800
+GLOBAL | ${textprefix}00000c00 | CODE | VEC_Alt_ITLB_0c00
+GLOBAL | ${textprefix}00001000 | CODE | VEC_Alt_DTLB_1000
+GLOBAL | ${textprefix}00001400 | CODE | VEC_Data_nested_TLB_1400
+GLOBAL | ${textprefix}00001800 | CODE | VEC_Instruction_Key_Miss_1800
+GLOBAL | ${textprefix}00001c00 | CODE | VEC_Data_Key_Miss_1c00
+GLOBAL | ${textprefix}00002000 | CODE | VEC_Dirty-bit_2000
+GLOBAL | ${textprefix}00002400 | CODE | VEC_Instruction_Access-bit_2400
+GLOBAL | ${textprefix}00002800 | CODE | VEC_Data_Access-bit_2800
+GLOBAL | ${textprefix}00002c00 | CODE | VEC_Break_instruction_2c00
+GLOBAL | ${textprefix}00003000 | CODE | VEC_External_Interrupt_3000
+GLOBAL | ${textprefix}00003400 | CODE | VEC_Reserved_3400
+GLOBAL | ${textprefix}00003800 | CODE | VEC_Reserved_3800
+GLOBAL | ${textprefix}00003c00 | CODE | VEC_Reserved_3c00
+GLOBAL | ${textprefix}00004000 | CODE | VEC_Reserved_4000
+GLOBAL | ${textprefix}00004400 | CODE | VEC_Reserved_4400
+GLOBAL | ${textprefix}00004800 | CODE | VEC_Reserved_4800
+GLOBAL | ${textprefix}00004c00 | CODE | VEC_Reserved_4c00
+GLOBAL | ${textprefix}00005000 | CODE | VEC_Page_Not_Present_5000
+GLOBAL | ${textprefix}00005100 | CODE | VEC_Key_Permission_5100
+GLOBAL | ${textprefix}00005200 | CODE | VEC_Instruction_Access_Rights_5200
+GLOBAL | ${textprefix}00005300 | CODE | VEC_Data_Access_Rights_5300
+GLOBAL | ${textprefix}00005400 | CODE | VEC_General_Exception_5400
+GLOBAL | ${textprefix}00005500 | CODE | VEC_Disabled_FP-Register_5500
+GLOBAL | ${textprefix}00005600 | CODE | VEC_Nat_Consumption_5600
+GLOBAL | ${textprefix}00005700 | CODE | VEC_Speculation_5700
+GLOBAL | ${textprefix}00005800 | CODE | VEC_Reserved_5800
+GLOBAL | ${textprefix}00005900 | CODE | VEC_Debug_5900
+GLOBAL | ${textprefix}00005a00 | CODE | VEC_Unaligned_Reference_5a00
+GLOBAL | ${textprefix}00005b00 | CODE | VEC_Unsupported_Data_Reference_5b00
+GLOBAL | ${textprefix}00005c00 | CODE | VEC_Floating-Point_Fault_5c00
+GLOBAL | ${textprefix}00005d00 | CODE | VEC_Floating_Point_Trap_5d00
+GLOBAL | ${textprefix}00005e00 | CODE | VEC_Lower_Privilege_Tranfer_Trap_5e00
+GLOBAL | ${textprefix}00005f00 | CODE | VEC_Taken_Branch_Trap_5f00
+GLOBAL | ${textprefix}00006000 | CODE | VEC_Single_Step_Trap_6000
+GLOBAL | ${textprefix}00006100 | CODE | VEC_Reserved_6100
+GLOBAL | ${textprefix}00006200 | CODE | VEC_Reserved_6200
+GLOBAL | ${textprefix}00006300 | CODE | VEC_Reserved_6300
+GLOBAL | ${textprefix}00006400 | CODE | VEC_Reserved_6400
+GLOBAL | ${textprefix}00006500 | CODE | VEC_Reserved_6500
+GLOBAL | ${textprefix}00006600 | CODE | VEC_Reserved_6600
+GLOBAL | ${textprefix}00006700 | CODE | VEC_Reserved_6700
+GLOBAL | ${textprefix}00006800 | CODE | VEC_Reserved_6800
+GLOBAL | ${textprefix}00006900 | CODE | VEC_IA-32_Exeception_6900
+GLOBAL | ${textprefix}00006a00 | CODE | VEC_IA-32_Intercept_6a00
+GLOBAL | ${textprefix}00006b00 | CODE | VEC_IA-32_Interrupt_6b00
+GLOBAL | ${textprefix}00006c00 | CODE | VEC_Reserved_6c00
+GLOBAL | ${textprefix}00006d00 | CODE | VEC_Reserved_6d00
+GLOBAL | ${textprefix}00006e00 | CODE | VEC_Reserved_6e00
+GLOBAL | ${textprefix}00006f00 | CODE | VEC_Reserved_6f00
+GLOBAL | ${textprefix}00007000 | CODE | VEC_Reserved_7000
+GLOBAL | ${textprefix}00007100 | CODE | VEC_Reserved_7100
+GLOBAL | ${textprefix}00007200 | CODE | VEC_Reserved_7200
+GLOBAL | ${textprefix}00007300 | CODE | VEC_Reserved_7300
+GLOBAL | ${textprefix}00007400 | CODE | VEC_Reserved_7400
+GLOBAL | ${textprefix}00007500 | CODE | VEC_Reserved_7500
+GLOBAL | ${textprefix}00007600 | CODE | VEC_Reserved_7600
+GLOBAL | ${textprefix}00007700 | CODE | VEC_Reserved_7700
+GLOBAL | ${textprefix}00007800 | CODE | VEC_Reserved_7800
+GLOBAL | ${textprefix}00007900 | CODE | VEC_Reserved_7900
+GLOBAL | ${textprefix}00007a00 | CODE | VEC_Reserved_7a00
+GLOBAL | ${textprefix}00007b00 | CODE | VEC_Reserved_7b00
+GLOBAL | ${textprefix}00007c00 | CODE | VEC_Reserved_7c00
+GLOBAL | ${textprefix}00007d00 | CODE | VEC_Reserved_7d00
+GLOBAL | ${textprefix}00007e00 | CODE | VEC_Reserved_7e00
+GLOBAL | ${textprefix}00007f00 | CODE | VEC_Reserved_7f00
+END
+
+
+awk '
+/__start_gate_section/ {start=1}
+/^'${dataprefix}\|${textprefix}'/ {
+	if ($4 == ".kdb")
+		next
+	if (start && substr($NF,1,1) != "0") {
+		type = substr($0,26,5)
+		if (type == ".text")
+			printf "GLOBAL | %s | CODE | %s\n", $1, $NF
+		else {
+			n = 0
+			s = $(NF-1)
+			while (length(s) > 0) {
+				n = n*16 + substr(s,1,1)
+				s = substr(s,2)
+			}
+			printf "GLOBAL | %s | DATA | %s | %d\n", $1, $NF, n
+		}
+	}
+	if($NF == "_end") 
+		exit
+
+}
+' $TMPSYM ) | egrep -v " __device| __vendor" | awk -v sn1="$SN1" '
+/GLOBAL/ {
+	print $0
+	if (sn1 != 0) {
+		/* 32 bits of sn1 physical addrs, */
+		print substr($0,1,9) "04" substr($0,20,16) "Phy_" substr($0,36)
+	} else {
+		/* 38 bits of sn2 physical addrs, need addr space bits */
+		print substr($0,1,9) "3004" substr($0,20,16) "Phy_" substr($0,36)
+	}
+
+} ' | sort -k3
+
+N=`wc -l $TEXTSYM|awk '{print $1}'`
+echo "Generated TEXTSYM file" >&2
+echo "  $LINUX --> $TEXTSYM" >&2
+echo "  Found $N symbols" >&2

--8GpibOaaTibBMecb--

