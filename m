From: Dave Young <dyoung@redhat.com>
Date: Fri, 06 Jan 2017 02:02:03 +0000
Subject: Re: [PATCH v4 1/5] crash: move crashkernel parsing and vmcore related code under CONFIG_CRASH_CORE
Message-Id: <20170106020203.GA2863@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148363729327.11570.6244765717789390817.stgit@hbathini.in.ibm.com>
 <148363734065.11570.16982557619253687714.stgit@hbathini.in.ibm.com>
In-Reply-To: <148363734065.11570.16982557619253687714.stgit@hbathini.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, fenghua.yu@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, kexec@lists.infradead.org, Mahesh J Salgaonkar <mahesh@linux.vnet.ibm.com>, ebiederm@xmission.com, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, vgoyal@redhat.com

Hi Hari

Thanks for the update.

On 01/05/17 at 10:59pm, Hari Bathini wrote:
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
> Changes from v3:
> * Renamed log_buf_kexec_setup()to log_buf_vmcoreinfo_setup() instead of
>   log_buf_crash_setup().
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

Acked-by: Dave Young <dyoung@redhat.com>

Thanks
Dave
