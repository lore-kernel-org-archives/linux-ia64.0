From: "LAKSHMIPATHY,ARUN (HP-India,ex2)" <arun_lakshmipathy@hp.com>
Date: Mon, 03 Jun 2002 12:39:47 +0000
Subject: [Linux-ia64] Integer to Pointer Cast Warnings when Building 2.4.17
Message-Id: <marc-linux-ia64-105590701905629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I Get an integer to pointer typecast warning from some of the sources when
building the 2.4.17 kernel, I am using the base 2.4.17 kernel and the ia64
patch with no other patches, the kernel builds fine and comes up fine.
Wanted to be sure that this is not a cause for concern. Enclosed below is
the excerpt of the build o/p.

make[1]: Entering directory `/kernel/linux/arch/ia64/ia32'
sys_ia32.c: In function `sys32_brk':
sys_ia32.c:3824: warning: passing arg 1 of `__do_clear_user' makes pointer
from integer without a cast

make[4]: Entering directory `/kernel/linux/drivers/acpi/dispatcher'
dswexec.c: In function `acpi_ds_exec_end_op':
dswexec.c:580: warning: cast from pointer to integer of different size 

make[4]: Entering directory `/kernel/linux/drivers/acpi/events'
evevent.c: In function `acpi_ev_asynch_execute_gpe_method':
evevent.c:686: warning: cast from pointer to integer of different size
evevent.c: In function `acpi_ev_gpe_dispatch':
evevent.c:802: warning: cast to pointer from integer of different size

make[3]: Entering directory `/kernel/linux/drivers/acpi'
os.c: In function `acpi_os_get_root_pointer':
os.c:206: warning: assignment makes integer from pointer without a cast

make[3]: Entering directory `/kernel/linux/drivers/scsi'
megaraid.c: In function `megaraid_queue':
megaraid.c:3805: warning: cast to pointer from integer of different size

Regards
Arun






