From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 08 Oct 2003 14:42:00 +0000
Subject: user-space unaligned accesses
Message-Id: <marc-linux-ia64-106562414203331@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I got this from somebody at Red Hat.  Anybody want to comment on it?


-------------------------------------------------------
...
The ia64 architecture does a tty_write
on a userspace unaligned access. Not only is this extremenly annoying,
it's also very broken since the tty may well be suspended etc etc.
Doing a printk on such an access by default is very broken already,
lets not make it worse



--- linux/arch/ia64/kernel/unaligned.c~	2003-09-30 11:04:08.000000000 +0200
+++ linux/arch/ia64/kernel/unaligned.c	2003-09-30 11:04:08.000000000 +0200
@@ -1340,12 +1340,6 @@
 			len = sprintf(buf, "%s(%d): unaligned access to 0x%016lx, "
 				      "ip=0x%016lx\n\r", current->comm, current->pid,
 				      ifa, regs->cr_iip + ipsr->ri);
-			/*
-			 * Don't call tty_write_message() if we're in the kernel; we might
-			 * be holding locks...
-			 */
-			if (user_mode(regs))
-				tty_write_message(current->tty, buf);
 			buf[len-1] = '\0';	/* drop '\r' */
 			printk(KERN_WARNING "%s", buf);	/* watch for command names containing %s */
 		}





-------------------------------------------------------

