From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 08 Aug 2002 03:38:03 +0000
Subject: [Linux-ia64] A comment on the 2.5.29 patch
Message-Id: <marc-linux-ia64-105590701905922@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

The change to drivers/char/mem.c doesn't look right --- it forces a
successful system call even when there's been an error.

--- a/drivers/char/mem.c	Thu Aug  1 01:08:13 2002
+++ b/drivers/char/mem.c	Thu Aug  1 01:08:13 2002
@@ -518,6 +518,7 @@
 		default:
 			ret = -EINVAL;
 	}
+	force_successful_syscall_return();
 	unlock_kernel();
 	return ret;
 }

Surely that should only be when ret != -EINVAL ???  You could move it
inside the switch, although that's ugly.


I can't see the point of moving the declaration of extern irq_desc_t
irq_desc [NR_IRQS]; from include/linux/irq.h into asm-i386/hw_irq.,
and adding the struct tag to irq_desc_t.  There maybe somthing I've
misunderstood here, but couldn't the SN1 code just populate the global
irq_desc[] array correctly, rather than using its own?  (It probably
need to be replicated to each NUMA group)

And my remaining comment is that I'm not sure why the changes to the
softirq() names were made.  A rose by any name would smell as sweet...

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

