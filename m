From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 14 Sep 2004 09:55:22 +0000
Subject: IA64 probe instruction
Message-Id: <4146C00A.8060505@hob.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000503030201070605090903"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000503030201070605090903
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

there is  behavior of the probe instruction that confuses me a little 
bit. Testing of the attached module shows differences whether executed 
with interrupts enabled or not.

# cat cpuinfo
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 0
revision   : 7
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 900.000000
itc MHz    : 900.000000
BogoMIPS   : 1346.37

#dmesg
init_module called ...
init_module result 0x0000000000000001
init_module done
cleanup_module called ...
Unable to handle kernel paging request at virtual address e00000404391fe30
...

Of course the reported address has nothing to do with the (nested!) 
fault of the second
probe instruction since interrupt resources are not written. But why 
does the second
probe interrupt instead of returning 0 or 1? The reference manual does 
not distinct between
psr.ic 0 or 1.

Although this is not really linux related maybe someone from Intel can 
comment on this.

Christian

--------------000503030201070605090903
Content-Type: text/plain;
 name="probe.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="probe.c"

#include <linux/kernel.h>
#include <linux/module.h>

MODULE_DESCRIPTION("Probe test");
MODULE_AUTHOR("Christian Hildner");
MODULE_LICENSE("GPL");

int init_module(void)
{
    unsigned long addr;
    unsigned long res;

    printk("init_module called ...\n");
    asm volatile ("\n\n"
        "movl %0=0xe000100000000000\n\n"
        ";;\n\n"
        "probe.r %1=%0,0\n\n"
        ";;\n\n"
        : "=r"(addr), "=r"(res)
        :);
    printk("init_module result 0x%016lx\n", res);
    printk("init_module done\n");
    return(0);
}

void cleanup_module(void)
{
    unsigned long addr;
    unsigned long res;

    printk("cleanup_module called ...\n");
    asm volatile ("\n\n"
        "rsm psr.i | psr.ic\n\n"
        "movl %0=0xe000100000000000\n\n"
        ";;\n\n"
        "srlz.i\n\n"
        ";;\n\n"
        "probe.r %1=%0,0\n\n"
        ";;\n\n"
        "ssm psr.ic\n\n"
        ";;\n\n"
        "srlz.d\n\n"
        "ssm psr.i\n\n"
        ";;\n\n"
        "srlz.i\n\n"
        ";;\n\n"
        : "=r"(addr), "=r"(res)
        :);
    printk("cleanup_module result 0x%016lx\n", res);
    printk("cleanup_module done\n");
    return;
}


--------------000503030201070605090903--

