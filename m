From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 20 Jul 2005 05:31:39 +0000
Subject: Simulator bootloader fails with gcc 4
Message-Id: <20050720053139.GC13188@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

After building a fresh tree with gcc 4 I can't boot the simulator as
the bootloader loader dies with 

loading /home/ianw/kerntest/kerncomp//build/sim_defconfig/vmlinux...
failed to read phdr

After some investigation I believe this is do with differences between
the alignment of variables on the stack between gcc 3 and 4 and the
ski simulator.  If you trace through with the simulator you can see
that the disk_stat structure value returned from the
SSC_WAIT_COMPLETION call seems to be only half loaded.  I guess it
doesn't like the alignment of the input.  I confirmed that things do
get aligned differently thusly :

ianw@lime:/tmp$ cat test.c
#include <stdio.h>

struct disk_stat {
        int fd;
        unsigned count;
};

int main(void)
{
        int blah;
        struct disk_stat test;

        printf("%p\n", &test);
}
ianw@lime:/tmp$ gcc-3.4 -o test test.c
ianw@lime:/tmp$ ./test
0x60000fffffc2f480
ianw@lime:/tmp$ gcc-4.0 -o test test.c
ianw@lime:/tmp$ ./test
0x60000fffff813484

The patch below at least fixes it for me.

Thanks,

-i

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

--

diff --git a/arch/ia64/hp/sim/boot/bootloader.c b/arch/ia64/hp/sim/boot/bootloader.c
--- a/arch/ia64/hp/sim/boot/bootloader.c
+++ b/arch/ia64/hp/sim/boot/bootloader.c
@@ -33,7 +33,7 @@ struct disk_req {
 struct disk_stat {
 	int fd;
 	unsigned count;
-};
+} __attribute__ ((aligned (16)));
 
 extern void jmp_to_kernel (unsigned long bp, unsigned long e_entry);
 extern struct ia64_boot_param *sys_fw_init (const char *args, int arglen);
