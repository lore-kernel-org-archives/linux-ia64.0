From: Uros Prestor <uros@turbolinux.com>
Date: Wed, 10 Jan 2001 02:03:20 +0000
Subject: [Linux-ia64] Undefined symbols
Message-Id: <marc-linux-ia64-105590678205911@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Starting with 2.4.0-test11 kernels, I am getting a whole bunch of
undefined symbols when trying to load modules.  Strange thing is that
the undefined symbols are exported from the kernel.  For example, when
loading the BigSur sound driver I get:

     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol remap_page_range
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol schedule_timeout
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol __wake_up
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol kmalloc
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol free_irq
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol remove_wait_queue
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol del_timer
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol interruptible_sleep_on
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol __pollwait
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol kfree
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol request_irq
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol add_wait_queue
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol mem_map
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol jiffies
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol printk
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     unresolved symbol add_timer
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     insmod
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o
     failed
     /lib/modules/2.4.0-010109-59smp/kernel/drivers/sound/cs4281.o:
     insmod cs4281 failed

Symbols such as printk and jiffies are exported in /proc/ksyms:

     [root@borg linux]# egrep ' (jiffies|printk)' /proc/ksyms
     e000000000b44c58 jiffies_R__ver_jiffies
     e000000000a869f0 printk_R__ver_printk

However, cs4281.o references the symbols without the version string
attached:

     [root@borg linux]# nm cs4281.o | egrep ' (jiffies|printk)'
                      U jiffies
                      U printk

What am I missing here?  I am using modutils-2.4.1 and I enabled
CONFIG_MODULES, CONFIG_MODVERSIONS and CONFIG_KMOD.

Thanks,
Uros

--
Uros Prestor
uros@turbolinux.com




