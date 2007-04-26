From: Simon Horman <horms@verge.net.au>
Date: Thu, 26 Apr 2007 01:52:36 +0000
Subject: Re: kexec/kdump: Use generic elf code on ia64
Message-Id: <20070426015233.GB13085@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070425090903.GA26412@verge.net.au>
In-Reply-To: <20070425090903.GA26412@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fastboot@lists.osdl.org, kexec@lists.infradead.org, linux-ia64@vger.kernel.org
Cc: Nanhai Zou <nanhai.zou@intel.com>, Vivek Goyal <vgoyal@in.ibm.com>, Tony Luck <tony.luck@intel.com>

On Wed, Apr 25, 2007 at 06:09:05PM +0900, Simon Horman wrote:
> Make use of the generic implementation of crash_save_cpu().
> 
> On ia64 the registers are saved by a kdump-specific function
> ia64_dump_cpu_regs() rather than elf_core_copy_regs() which
> is used by other architectures via crash_save_cpu(). It seems
> that ia64_dump_cpu_regs() and elf_core_copy_regs() are indeed
> quite different
> 
> In order to facilitate this kdump_elf_core_copy_regs()
> has been created, and it is called by crash_save_cpu().
> By default kdump_elf_core_copy_regs() is just defined to be
> elf_core_copy_regs() and ia64 defines its own implementation,
> which calls ia64_dump_cpu_regs().  The ia64 version also sets
> register 47 in accordance with the code that it replaces.
> 
> crash_save_cpu() has also been modifued to use a pre-alocated,
> per-cpu variable for saving the cpu registers, as per the
> IA64 specific code that this patch removes. This is
> in order to reduce possible stack contention at crash-time.

There are a couple of areas of the kexec code that allocate
per-cpu variables either staticly or at boot time. I wonder
if a more lazy approach of initialising them when they are first
accessed would be better. I am thinking of cases such as this one
where the first access will occur at kexec load time, so there
shouldn't be any chance of contention occuring at the time when
kexec executes the new kernel, or in the case of kdump, crash-time.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

