From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 25 Aug 2005 00:29:05 +0000
Subject: Allow /proc/pal/cpu0/vm_info under the simulator
Message-Id: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Currently the palinfo code aborts without printing anything on the
first pal call that fails.

The appended patch makes it a little more tolerant... if a call fails,
then it'll display what it already has.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -323,8 +323,10 @@ vm_info(char *page)
 		     vm_info_1.pal_vm_info_1_s.key_size, vm_info_1.pal_vm_info_1_s.hash_tag_id,
 		     vm_info_2.pal_vm_info_2_s.rid_size);
 
-	if (ia64_pal_mem_attrib(&attrib) != 0)
-		return 0;
+	if (ia64_pal_mem_attrib(&attrib) != 0){
+		*p++ = '\n';
+		return p-page;
+	}
 
 	p += sprintf(p, "Supported memory attributes    : ");
 	sep = "";
@@ -338,7 +340,7 @@ vm_info(char *page)
 
 	if ((status = ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk(KERN_ERR "ia64_pal_vm_page_size=%ld\n", status);
-		return 0;
+		return p-page;
 	}
 
 	p += sprintf(p,
@@ -359,7 +361,7 @@ vm_info(char *page)
 
 	if ((status=ia64_get_ptce(&ptce)) != 0) {
 		printk(KERN_ERR "ia64_get_ptce=%ld\n", status);
-		return 0;
+		return p-page;
 	}
 
 	p += sprintf(p,
