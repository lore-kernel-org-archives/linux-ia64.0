From: Takanori Kawano <t-kawano@ebina.hitachi.co.jp>
Date: Tue, 24 Jul 2001 05:29:18 +0000
Subject: [Linux-ia64] free_initrd_mem fix
Message-Id: <marc-linux-ia64-105590693005893@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello, 

Let me do some bug report of your code.

I found that free_initrd_mem() may free the area reserved for 
platform hardware/firmware if initrd_end is not PAGE_SIZE aligned.
When this happened, kernel will use the hw/fw area and will corrupt 
data in it.

For this data corupption, our ia64 SMP box have crashed when kernel 
calls EFI runtime services. 
My case is as follows:

 1) EFI memory map:

    Type       Start            End               # Pages          Attributes
       .
       .
       .
   available  0000000000100000-000000007F932FFF  000000000007F833 0000000000000009
   RT_data    000000007F933000-000000007F933FFF  0000000000000001 8000000000000009
       .
       .
       .

 2) initrd_end = 0xe00000007f933000
 3) PAGE_SIZE is 16KB


I checked the following patch correct this problem.


--- arch/ia64/mm/init.c.orig	Tue Jul 24 01:07:27 2001
+++ arch/ia64/mm/init.c	Tue Jul 24 01:08:59 2001
@@ -111,7 +111,7 @@
 	 *
 	 * To avoid freeing/using the wrong page (kernel sized) we:
 	 *	- align up the beginning of initrd
-	 *	- keep the end untouched
+	 *	- align down the end of initrd
 	 *
 	 *  |             |
 	 *  |=======| a000
@@ -135,6 +135,7 @@
 	 * initrd_start and keep initrd_end as is.
 	 */
 	start = PAGE_ALIGN(start);
+	end = end & PAGE_MASK;
 
 	if (start < end)
 		printk ("Freeing initrd memory: %ldkB freed\n", (end - start) >> 10);



Please take the fix in, and also consider the patch I sent to linux-ia64-ML 
few weeks ago(Subject:  [Linux-ia64] [PATCH] free_initrd_mem() need to be correct).

regards,

---
Takanori Kawano
Hitachi Ltd,
Internet Systems Platform Division
t-kawano@ebina.hitachi.co.jp





