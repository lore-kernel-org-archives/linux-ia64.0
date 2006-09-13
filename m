From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 13 Sep 2006 07:10:04 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <4508.1158131404@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou Nan hai (on 11 Sep 2006 14:12:13 +0800) wrote:
>	For 2.6 kernel, I think GP is a region 5 address when inside kernel.
>The entire kernel image is resided in region 5 without relocate to
>region 7. 

You are right, I have only three excuses.

(1) Having too much fun skiing to think about computers.
(2) The kernel _used_ to be in region 7.
(3) The kernel addresses in region 5 can always be accessed via the
    identity map in region 7 and sometimes we do just that, see below.

>	Another issue I can see from calculate GP from physical address passed
>from OS_INIT is,
>	I am not quite sure though, if OS_INIT is happened during a module
>execution, or happened when system is in user space, what GP value will
>be passed from SAL/PAL? If the gp value is the physical address of the
>modules 's gp, we can't set GP value according to that, because
>ia64_init_handler is inside kernel.

It does not matter where the kernel was when the INIT was delivered,
even if the INIT ws delivered while a module was in control.  r1 must
be loaded with the correct gp for the kernel, because ia64_init_handler
is a kernel routine, not a module routine.  The sequence goes :-

* Kernel boots

* ia64_mca_init() -> ia64_sal_set_vectors(), passing the _physical_
  value of the kernel's gp. This physical address is derived from the
  region 5 virtual gp by tpa().

* Kernel runs.
  INIT is delivered.  It does not matter what state the machine is in,
  in kernel, a module or PAL/SAL is irrelevant.

* ia64_os_init_dispatch() -> ia64_set_kernel_registers() which converts
  the physical gp to a region 7 identity mapped virtual gp.

* ia64_os_init_dispatch() -> ia64_init_handler().

* ia64_init_handler() runs using a region 7 virtual gp.  This is a
  different virtual address than the original region 5 gp that the
  kernel booted with, but both the region 5 and region 7 gp values map
  the same physical pages.


>	Kexec kernel used in kdump is usually exactly the same kernel with the
>host kernel, except they are located in different physical address
>ranges. The first kernel will never touch the RAM belongs to the crash
>kernel at run time. The crash kernel will not touch the RAM belongs to
>the first kernel unless you read it via /proc/vmcore.

Which means that the region 7 gp used by MCA/INIT is no good for the
kexec kernel.  You either need the original region 5 gp or you need to
adjust r1 by the difference between the physical start of the real
kernel and the physical start of the kexec kernel.

Note: When I did the code in ia64_set_kernel_registers(), it was too
messy to work out what the original region 5 gp value was, so I just
did 'DATA_PA_TO_VA(r1,temp1)' and relied on the identity mapping in
region 7.  Perhaps the correct fix is for ia64_set_kernel_registers()
to set the correct region 5 gp and not rely on the identity mapping.
That should easy enough to do, define a global variable that contains
the region 5 value of gp and load that value in
ia64_set_kernel_registers instead of using DATA_PA_TO_VA.

