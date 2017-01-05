From: Dave Young <dyoung@redhat.com>
Date: Thu, 05 Jan 2017 06:17:45 +0000
Subject: Re: [PATCH v3 1/5] crash: move crashkernel parsing and vmcore related code under CONFIG_CRASH_CORE
Message-Id: <20170105061745.GA9679@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148336637462.25358.5151364413645288219.stgit@hbathini.in.ibm.com>
 <148336641471.25358.1234744226675502511.stgit@hbathini.in.ibm.com>
In-Reply-To: <148336641471.25358.1234744226675502511.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, kexec@lists.infradead.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

Hi, Hari

On 01/02/17 at 07:43pm, Hari Bathini wrote:
> Traditionally, kdump is used to save vmcore in case of a crash. Some
> architectures like powerpc can save vmcore using architecture specific
> support instead of kexec/kdump mechanism. Such architecture specific
> support also needs to reserve memory, to be used by dump capture kernel.
> crashkernel parameter can be a reused, for memory reservation, by such
> architecture specific infrastructure.
> 
> But currently, code related to vmcoreinfo and parsing of crashkernel
> parameter is built under CONFIG_KEXEC_CORE. This patch introduces
> CONFIG_CRASH_CORE and moves the above mentioned code under this config,
> allowing code reuse without dependency on CONFIG_KEXEC. There is no
> functional change with this patch.
> 
> Signed-off-by: Hari Bathini <hbathini@linux.vnet.ibm.com>
> ---
> 
> Changes from v2:
> * Used CONFIG_CRASH_CORE instead of CONFIG_KEXEC_CORE at
>   appropriate places in printk and ksysfs.
> 
> 
>  arch/Kconfig               |    4 
>  include/linux/crash_core.h |   65 ++++++
>  include/linux/kexec.h      |   57 ------
>  include/linux/printk.h     |    4 
>  kernel/Makefile            |    1 
>  kernel/crash_core.c        |  445 ++++++++++++++++++++++++++++++++++++++++++++
>  kernel/kexec_core.c        |  404 ----------------------------------------
>  kernel/ksysfs.c            |    8 +
>  kernel/printk/printk.c     |    6 -
>  9 files changed, 531 insertions(+), 463 deletions(-)
>  create mode 100644 include/linux/crash_core.h
>  create mode 100644 kernel/crash_core.c
> 

[snip]

>  #ifndef CONFIG_TINY_RCU
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 8b26964..d0dfebd 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -32,7 +32,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/memblock.h>
>  #include <linux/syscalls.h>
> -#include <linux/kexec.h>
> +#include <linux/crash_core.h>
>  #include <linux/kdb.h>
>  #include <linux/ratelimit.h>
>  #include <linux/kmsg_dump.h>
> @@ -951,7 +951,7 @@ const struct file_operations kmsg_fops = {
>  	.release = devkmsg_release,
>  };
>  
> -#ifdef CONFIG_KEXEC_CORE
> +#ifdef CONFIG_CRASH_CORE
>  /*
>   * This appends the listed symbols to /proc/vmcore
>   *
> @@ -960,7 +960,7 @@ const struct file_operations kmsg_fops = {
>   * symbols are specifically used so that utilities can access and extract the
>   * dmesg log from a vmcore file after a crash.
>   */
> -void log_buf_kexec_setup(void)
> +void log_buf_crash_setup(void)

I can not think of any better name about the CONFIG_CRASH_CORE though I
feel it is not excellent so personally I can live with it.

But for this function name log_buf_crash_setup is too general, I can not get
what it is doing from the name, how about change it to log_buf_vmcoreinfo_setup

>  {
>  	VMCOREINFO_SYMBOL(log_buf);
>  	VMCOREINFO_SYMBOL(log_buf_len);
> 

Thanks
Dave
