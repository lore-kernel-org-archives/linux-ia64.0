From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 21 Dec 2002 09:00:09 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.52)
Message-Id: <marc-linux-ia64-105590709805628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new ia64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5

in file linux-2.5.52-ia64-021221.diff.gz.

I wasted a fair amount of time figuring out why the kernel would
suddenly segv all other the place, just to find that, in the end, it
was due to a line that got left out of the main Makefile.  Oh, well, I
have had better weeks...

The good news is that this kernel actually seems to work pretty well
for me (modulo know issues: no kernel module loader yet, etc).
Hoewever, the MPT Fusion SCSI driver broke pretty badly in 2.5.50: it
just freezes the machine while it's probing for SCSI devices.  Someone
who actually knows something about this driver needs to take a good
look at this.

Oh, and I noticed one bug in the current patch already: in
/proc/pal/cpuN/vm_info, the memory-attributes are currently printed
with an extra newline.  Not a biggie, but for those who care, the
attached (untested) patch should fix the problem.

Enjoy & Happy Holidays,

	--david

PS: Pretty much all of HP will be closed next week.  I'll check in on
    mail from time to time, but I'm also looking forward to spend some
    quality R&R time with my family. ;-)

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.892   -> 1.893  
#	arch/ia64/kernel/palinfo.c	1.8     -> 1.9    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/12/21	davidm@tiger.hpl.hp.com	1.893
# ia64: Fix printing of memory attributes.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
--- a/arch/ia64/kernel/palinfo.c	Sat Dec 21 00:58:08 2002
+++ b/arch/ia64/kernel/palinfo.c	Sat Dec 21 00:58:08 2002
@@ -333,10 +333,11 @@
 	sep = "";
 	for (i = 0; i < 8; i++) {
 		if (attrib & (1 << i)) {
-			p += sprintf(p, "%s%s\n", sep, mem_attrib[i]);
+			p += sprintf(p, "%s%s", sep, mem_attrib[i]);
 			sep = ", ";
 		}
 	}
+	p += sprintf(p, "\n");
 
 	if ((status=ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk("ia64_pal_vm_page_size=%ld\n", status);

