From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 25 Feb 2008 13:33:12 +0000
Subject: Re: [kvm-ia64-devel] [PATCH 0/4] ia64/xen: paravirtualization of hand written assembly code
Message-Id: <25065.1203946392@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <12039094061834-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12039094061834-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

tgingold@free.fr (on Mon, 25 Feb 2008 13:54:48 +0100) wrote:
>Quoting Keith Owens <kaos@ocs.com.au>:
>{...}
>> A combination of options (2) and (3) would work.  Have a single source
>> file for the IVT, using conditional macros.  Use that source file to
>> build (at least) two copies of the IVT, for native and any virtualized
>> modes.  The native copy of the IVT starts at label ia64_ivt in section
>> .text.ivt, as it does now.  Any IVT versions for virtualized mode are
>> defined as __cpuinitdata, so they are discarded after boot, unless
>> CONFIG_HOTPLUG_CPU=y.  arch/ia64/kernel/head.S copies the relevant
>> virtualized version over ia64_ivt when necessary, before initializing
>> cr.iva.
>>
>> Single source for maintenance.  No indirect function overhead at run
>> time.  Binary patching at boot time for the right mode.  No wasted
>> space in the kernel.
>
>Good idea.  The linker script will be slightly more complex however...

Don't see why the linker script needs to change at all.  The existing
native IVT is at label ia64_ivt in section .text.ivt, as it is now.
arch/ia64/kernel/head.S simply overwrites ia64_ivt with 32K of data for
the virtualized IVT, copying from another data area.  AFAICT, nothing
in that process requires linker changes.

