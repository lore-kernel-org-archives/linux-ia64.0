From: Matt_Domsch@Dell.com
Date: Mon, 23 Jul 2001 14:53:37 +0000
Subject: [Linux-ia64] [PATCH] efivars spinlock fix
Message-Id: <marc-linux-ia64-105590693005873@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below fixes a couple potential failures in the efivars module.
First, it was calling kmalloc, which could sleep, while holding a spinlock.
Second, it would fail to free allocated memory if copy_from_user() failed.

David, please apply.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!


--- linux/arch/ia64/kernel/efivars.c.orig	Wed Jul 18 22:09:12 2001
+++ linux/arch/ia64/kernel/efivars.c	Wed Jul 18 22:13:36 2001
@@ -276,21 +276,20 @@
 	if (!capable(CAP_SYS_ADMIN))
 		return -EACCES;
 
-	spin_lock(&efivars_lock);
 	MOD_INC_USE_COUNT;
 
 	var_data = kmalloc(size, GFP_KERNEL);
 	if (!var_data) {
 		MOD_DEC_USE_COUNT;
-		spin_unlock(&efivars_lock);
 		return -ENOMEM;
 	}
 	if (copy_from_user(var_data, buffer, size)) {
 		MOD_DEC_USE_COUNT;
-		spin_unlock(&efivars_lock);
+		kfree(var_data);
 		return -EFAULT;
 	}
 
+	spin_lock(&efivars_lock);
 
 	/* Since the data ptr we've currently got is probably for
 	   a different variable find the right variable.


