From: Matt_Domsch@Dell.com
Date: Sun, 23 Sep 2001 20:40:59 +0000
Subject: [Linux-ia64] [PATCH] efivars.c spinlock fix
Message-Id: <marc-linux-ia64-105590698805240@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, below and posted at
http://domsch.com/linux/patches/efivars-spinlock-20010718.patch is a patch
to prevent efivars.c from holding a spinlock while allocating memory.  Also
frees an allocation in the event of an error.  This applies against your
latest 2.4.9 patch.  Please include this in your 2.4.10 patch.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

$ more efivars-spinlock-20010718.patch
--- linux/arch/ia64/kernel/efivars.c.orig       Wed Jul 18 22:09:12 2001
+++ linux/arch/ia64/kernel/efivars.c    Wed Jul 18 22:13:36 2001
@@ -276,21 +276,20 @@
        if (!capable(CAP_SYS_ADMIN))
                return -EACCES;

-       spin_lock(&efivars_lock);
        MOD_INC_USE_COUNT;

        var_data = kmalloc(size, GFP_KERNEL);
        if (!var_data) {
                MOD_DEC_USE_COUNT;
-               spin_unlock(&efivars_lock);
                return -ENOMEM;
        }
        if (copy_from_user(var_data, buffer, size)) {
                MOD_DEC_USE_COUNT;
-               spin_unlock(&efivars_lock);
+               kfree(var_data);
                return -EFAULT;
        }


+       spin_lock(&efivars_lock);

        /* Since the data ptr we've currently got is probably for
           a different variable find the right variable.

