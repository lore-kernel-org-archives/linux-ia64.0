From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 26 Feb 2008 02:35:48 +0000
Subject: Re: [kvm-ia64-devel] [PATCH 0/4] ia64/xen: paravirtualization of hand written assembly code
Message-Id: <28263.1203993348@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <12039094061834-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12039094061834-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

tgingold@free.fr (on Mon, 25 Feb 2008 16:04:29 +0100) wrote:
>Quoting Keith Owens <kaos@ocs.com.au>:
>
>> tgingold@free.fr (on Mon, 25 Feb 2008 13:54:48 +0100) wrote:
>> >Quoting Keith Owens <kaos@ocs.com.au>:
>> >{...}
>> >> A combination of options (2) and (3) would work.  Have a single source
>> >> file for the IVT, using conditional macros.  Use that source file to
>> >> build (at least) two copies of the IVT, for native and any virtualized
>> >> modes.  The native copy of the IVT starts at label ia64_ivt in section
>> >> .text.ivt, as it does now.  Any IVT versions for virtualized mode are
>> >> defined as __cpuinitdata, so they are discarded after boot, unless
>> >> CONFIG_HOTPLUG_CPU=y.  arch/ia64/kernel/head.S copies the relevant
>> >> virtualized version over ia64_ivt when necessary, before initializing
>> >> cr.iva.
>> >>
>> >> Single source for maintenance.  No indirect function overhead at run
>> >> time.  Binary patching at boot time for the right mode.  No wasted
>> >> space in the kernel.
>> >
>> >Good idea.  The linker script will be slightly more complex however...
>>
>> Don't see why the linker script needs to change at all.  The existing
>> native IVT is at label ia64_ivt in section .text.ivt, as it is now.
>> arch/ia64/kernel/head.S simply overwrites ia64_ivt with 32K of data for
>> the virtualized IVT, copying from another data area.  AFAICT, nothing
>> in that process requires linker changes.
>
>Humm, what about relative jumps ?  The object code must be linked as if it were
>at .text.ivt.  I suppose this is doable with OVERLAY in linker script.

Looking into this in more detail, it is a little trickier than I thought.

Relative jumps need to be fixed up after the copy.  Scan the
virtualized IVT, identify relative addresses that refer outside the
IVT, adjust them by the difference between ia64_ivt and the original
start of the virtualized IVT.  It should only be branch class
instructions that need adjusting.

Using OVERLAY tricks in the linker would fix the relative jumps but
then LOAD_PHYSICAL becomes a problem, the .xdata4 ".data.patch.vtop"
entries would be wrong.

Come to think of it, LOAD_PHYSICAL is a problem in either case.  If the
native and virtualized IVT's both use LOAD_PHYSICAL then the
.data.patch.vtop entries will need fixing.  There are only two
LOAD_PHYSICAL references in ivt.S, maybe they can be replaced?

