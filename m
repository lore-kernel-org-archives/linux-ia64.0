From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 12 Feb 2002 21:51:22 +0000
Subject: [Linux-ia64] null pointer dereference patch
Message-Id: <marc-linux-ia64-105590698806040@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Without the attached patch, unaligned references before
init_modules() is called result in null pointer dereferences.
This is against 2.4.17-ia64-011226.
-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard


Index: arch/ia64/mm/extable.c
=================================RCS file: /var/cvs/linux/arch/ia64/mm/extable.c,v
retrieving revision 1.2
diff -u -p -r1.2 extable.c
--- arch/ia64/mm/extable.c	25 Jan 2002 20:14:42 -0000	1.2
+++ arch/ia64/mm/extable.c	12 Feb 2002 16:42:55 -0000
@@ -59,6 +59,8 @@ search_exception_table (unsigned long ad
 		if (!mp->ex_table_start)
 			continue;
 		archdata = (struct archdata *) mp->archdata_start;
+		if (!archdata)
+			continue;
 		entry = search_one_table(mp->ex_table_start, mp->ex_table_end - 1,
 					 addr, (unsigned long) archdata->gp);
 		if (entry) {


