From: Paul Jackson <pj@sgi.com>
Date: Thu, 27 Nov 2003 11:51:49 +0000
Subject: Re: [PATCH] check user access ok writing
Message-Id: <marc-linux-ia64-106993397321074@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106991103102490@msgid-missing>
In-Reply-To: <marc-linux-ia64-106991103102490@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

Here is a new improved patch for verifying user access to string
passed in to kernel on write to /proc/irq/<pid>/smp_affinity.

The access_ok() but missing __get_user() on each byte earlier patch
has been replaced with a copy_from_user().

I have built it and verified that it handles write requests
as before, on an ia64 system (well - you can no longer pass
more than 14 spaces after the 'R' - tough).

Could you kindly apply the following patch?

In arch/ia64/kernel/irq.c:irq_affinity_write_proc() there
is an unchecked user access that examines writes to files
/proc/irq/<pid>/smp_affinity for a leading character 'R',
in order to trigger some interrupt redirect feature.

You can oops the kernel easily, by issuing a write() system
call to these files with a bogus address.

Here's a patch against test10 to fix it:

# --------------------------------------------
# 03/11/27	pj@sgi.com	1.1486
# Check for user access to 'R' prefix of ia64 smp_affinity writes.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Thu Nov 27 03:18:41 2003
+++ b/arch/ia64/kernel/irq.c	Thu Nov 27 03:18:41 2003
@@ -27,6 +27,7 @@
 #include <linux/timex.h>
 #include <linux/slab.h>
 #include <linux/random.h>
+#include <linux/ctype.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
 #include <linux/kernel_stat.h>
@@ -997,21 +998,37 @@
 	unsigned int irq = (unsigned long) data;
 	int full_count = count, err;
 	cpumask_t new_value, tmp;
-	const char *buf = buffer;
+	#define R_PREFIX_LEN 16
+	char rbuf[R_PREFIX_LEN];
+	int rlen;
+	int prelen;
 	irq_desc_t *desc = irq_descp(irq);
-	int redir;
 
 	if (!desc->handler->set_affinity)
 		return -EIO;
 
-	if (buf[0] = 'r' || buf[0] = 'R') {
-		++buf;
-		while (*buf = ' ') ++buf;
-		redir = 1;
-	} else
-		redir = 0;
+	/*
+	 * If string being written starts with a prefix of 'r' or 'R'
+	 * and some limited number of spaces, set IA64_IRQ_REDIRECTED.
+	 * If more than (R_PREFIX_LEN - 2) spaces are passed, they won't
+	 * all be trimmed as part of prelen, the untrimmed spaces will
+	 * cause the hex parsing to fail, and this write() syscall will
+	 * fail with EINVAL.
+	 */
+
+	if (!count)
+		return -EINVAL;
+	rlen = min(sizeof(rbuf)-1, count);
+	if (copy_from_user(rbuf, buffer, rlen))
+		return -EFAULT;
+	rbuf[rlen] = 0;
+	prelen = 0;
+	if (tolower(*rbuf) = 'r') {
+		prelen = strspn(rbuf, "Rr ");
+		irq |= IA64_IRQ_REDIRECTED;
+	}
 
-	err = parse_hex_value(buf, count, &new_value);
+	err = parse_hex_value(buffer+prelen, count-prelen, &new_value);
 	if (err)
 		return err;
 
@@ -1024,7 +1041,7 @@
 	if (cpus_empty(tmp))
 		return -EINVAL;
 
-	desc->handler->set_affinity(irq | (redir? IA64_IRQ_REDIRECTED : 0), new_value);
+	desc->handler->set_affinity(irq, new_value);
 	return full_count;
 }
 


-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
