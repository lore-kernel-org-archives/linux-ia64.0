From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:24:11 +0000
Subject: Re: [PATCH v7 09/14] jump_label: port __jump_table to linker tables
Message-Id: <20170119112411.GN28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-10-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-10-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: gnomes@lxorguk.ukuu.org.uk, dalias@libc.org, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, mpe@ellerman.id.au, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, wangnan0@huawei.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, dsahern@gmail.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, bp@suse.de, linux@roeck-us.net, david.vrabel@citrix.com, linux-xtensa@linux

On Sun, Jan 15, 2017 at 01:10:52PM -0800, Luis R. Rodriguez wrote:
> Move the __jump_table from the a custom section solution
> to a generic solution, this avoiding extra vmlinux.lds.h
> customizations.
> 
> This also demos the use of the .data linker table and of
> the shared asm call push_section_tbl().
> 
> Built-in kernel functionality was tested with CONFIG_STATIC_KEYS_SELFTEST.
> Moduler  kernel functionality was tested with CONFIG_TEST_STATIC_KEYS.
> Both work as expected.
> 
> Since __jump_table sections are also supported per
> module this also required expanding module-common.lds.S
> to capture and fold all .data.tlb.__jump_table.* onto
> the the section __jump_table -- in this case for modules
> need to keep a reference in place, given the alternative
> is to use DEFINE_LINKTABLE(struct jump_entry, __jump_table)
> per module -- and later through macro hacks instantiate
> the jump entries per module upon init. This is doable but
> we'd loose out on the sorting of the table using the
> linker, to sort we'd always still need to expand the
> module common linker script. An alternative mechanism
> is possible which would make these custom module sections
> extensions dynamic without requiring manual changes, this
> however is best done later through a separate evolution
> once linker tables are in place.
> 
> A careful reviewer may note that some architectures use
> "\n\t" to separate asm code, while others just use a new line.
> Upon review last time it was deemed reasonable to for all
> architectures to just use "\n", this is defined as ASM_CMD_SEP,
> and if an architecture needs to override they can do so on their
> architecture sections.h prior to including asm-generic/sections.h
> 
> v6: rename table macro as suggested by Andy Shevchenko
> 
> v5:
> 
> o Use ..tbl instead of .tbl as suggested by Nicholas Piggin.
>   This is the typical way to avoid clash with compiler generated
>   section.
> 
> o Replace section macros with section names
> 
> o Use LINKTABLE_START() and LINKTABLE_END()
> 
> o fixed tile jump label port -- tile got jump label support as of
>   commit 65a792e84f25d1 ("tile/jump_label: add jump label support
>   for TILE-Gx"), as such we just needed to adjust the asm to account
>   for the new linker table API use. This commit was merged as of v4.5-rc1.
> 
> v4:
> 
> o Some architectures allow linker scripts to follow including header
>   files, some others do not, so if you need a helper on a linker script
>   you need to explicitly include it. So for instance although
>   scripts/module-common.lds.S includes <asm/tables.h> and this file
>   includes <asm/section-core.h>, you still need to explicitly
>   include it on the linker script. This issue is present on ARM.
> 
> o as per Josh Poimboeuf open code the section table name instead
>   of including the kernel section headers, the simplicity and
>   independence from the kernel is preferred.
> 
> v3:
> 
> o More elaborate tests performed
> o first modular support use case, module tested was
>   CONFIG_TEST_STATIC_KEYS (lib/test_static_keys.ko), this
>   required us to extend module-common.lds.S
> o use generic push_section_tbl_any() for all architectures
> o Makes use of ASM_CMD_SEP to enable architectures to override later
>   if needed
> o guard tables.h inclusion and table definition with __KERNEL__
> 
> v2: introduced in this series
> 
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
> ---
>  arch/arm/include/asm/jump_label.h     |  6 ++++--
>  arch/arm64/include/asm/jump_label.h   |  6 ++++--
>  arch/mips/include/asm/jump_label.h    |  6 ++++--
>  arch/powerpc/include/asm/jump_label.h |  8 +++++---
>  arch/s390/include/asm/jump_label.h    |  6 ++++--
>  arch/sparc/include/asm/jump_label.h   |  6 ++++--
>  arch/tile/include/asm/jump_label.h    |  5 +++--
>  arch/x86/include/asm/jump_label.h     | 10 ++++++----
>  include/asm-generic/vmlinux.lds.h     |  5 -----
>  include/linux/jump_label.h            |  4 ++--
>  kernel/jump_label.c                   | 17 ++++++++++-------
>  scripts/module-common.lds             |  1 +
>  tools/objtool/special.c               |  2 +-
>  13 files changed, 48 insertions(+), 34 deletions(-)

meta-comment.  This new infrastructure doesn't seem to save any code
when you need to have a new "link table".  Yes, the macros seem a bit
nicer, but it feels like unneeded churn.  I haven't seen any patches in
this series that makes me go "oh yeah, now I see why he did this work,
it's so much simpler and easy to understand now!"

What am I missing?  What wonderful new things are going to happen, or
where is the code savings going to come from with this series to justify
all of the work to create and review this?

thanks,

greg k-h
