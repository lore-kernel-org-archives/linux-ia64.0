From: "Randall G Chan/Fremont/IBM" <chanr@us.ibm.com>
Date: Thu, 21 Sep 2000 21:03:51 +0000
Subject: [Linux-ia64] unregister_rebbot_notifier()
Message-Id: <marc-linux-ia64-105590678205511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a small snippet of code that will make the kernel hang on a
reboot.  It hangs in the call to unregister_reboot_notifier() [on a reboot
when the module is loaded].  It seems that it hangs in this function while
trying to call write_lock(&notifier_lock).  Looks like something that
grabbed the long before never set the lock back to unlocked.  I've tried
this on 2.4.0-test7 on  a BigSur A3, 1 GB mem, BIOS 70 and a Lion B0, 1 GB
mem, BIOS 55.  This code works fine if you remove the module (rmmod), but
if you insert it and reboot the machine using reboot, shutdown,
three-finger-salute, it'll hang.

Also, I can't seem to get this module to load on 2.4.0-test8.  This system
just seems to hang after trying to insert the module.  I've seen this
happen on the same two machines listed above.  Are there any known problems
in test8 in relation to module loading?

Thanks,
Randy Chan
chanr@us.ibm.com

--------------------------------------------------------------------------

#define MODULE
#define __KERNEL__
#include <linux/version.h>
#include <linux/module.h>
#include <linux/types.h>
#include <linux/notifier.h>

static int mod_finalize(struct notifier_block *, unsigned long, void *);
static struct notifier_block NBlk = { mod_finalize, NULL, 0 };

int init_module(void)
{
    printk("<1>Inserted!\n");
    register_reboot_notifier(&NBlk);
    return 0;
}

void cleanup_module(void)
{
    mod_finalize(&NBlk, SYS_RESTART, NULL);
    printk("<1>Removed!\n");
}

static int mod_finalize(struct notifier_block *nb, unsigned long event,
void *buf)
{
    printk("Finalizing!\n");
    unregister_reboot_notifier(&NBlk);
}


