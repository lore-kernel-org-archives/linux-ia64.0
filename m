From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Fri, 17 Jan 2003 06:41:29 +0000
Subject: [Linux-ia64] skip _PRT entry for non-existent IOSAPICs
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Fri_Jan_17_15:41:29_2003_801)--"
Message-Id: <marc-linux-ia64-105590709805710@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

----Next_Part(Fri_Jan_17_15:41:29_2003_801)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

On some machines that support I/O hot-plugging,
it happens that after boottime one or more IO SAPICs appear
after hot-plug event.  Even in that case, ACPI _PRT entries
can exist for devices behind those IO SAPICs at boottime
for future use.

Currently iosapic.c will give up parsing _PRT entries
once one of them hits such a non-existent IO SAPIC.

This patch fixes the problem on 2.5 ia64 bk tree.
For 2.4, we don't have this problem now.

Thanks,
---
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>

----Next_Part(Fri_Jan_17_15:41:29_2003_801)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="iosapic.c.diff"

--- ia64-2.5/arch/ia64/kernel/iosapic.c	Fri Dec 27 16:27:23 2002
+++ ia64-2.5.mod/arch/ia64/kernel/iosapic.c	Fri Jan 17 15:31:50 2003
@@ -752,7 +752,7 @@
 
 			if (index < 0) {
 				printk(KERN_WARNING"IOSAPIC: GSI 0x%x has no IOSAPIC!\n", gsi);
-				return;
+				continue;
 			}
 			addr = iosapic_lists[index].addr;
 			gsi_base = iosapic_lists[index].gsi_base;

----Next_Part(Fri_Jan_17_15:41:29_2003_801)----

