From: Andi Kleen <ak@suse.de>
Date: Fri, 23 May 2003 19:41:31 +0000
Subject: [Linux-ia64] Re: /proc/kcore - how to fix it
Message-Id: <marc-linux-ia64-105590723706015@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705961@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705961@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 23 May 2003 12:13:04 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:


> Here's how it works.  The default code in fs/proc/kcore.c doesn't
> set up any "elf_phdr" sections ... it is left to each architecture
> to make appropriate calls to "kclist_add()" to specify a base
> address and size for each piece of kernel virtual address space
> that needs to be made accessible through /proc/kcore.  To get the
> old functionality, you'll need two calls that look something like:
> 
>  kclist_add(&kcore_mem, __va(0),
>              max_low_pfn * PAGE_SIZE);
>  kclist_add(&kcore_vmem, (void *)VMALLOC_START,
>              VMALLOC_END-VMALLOC_START);

Looks good to me.

/dev/mem / dev/kmem has the same problem, it could use that too.

> 
> The first makes all of memory visible (__i386__, __mc68000__ and
> __x86_64__ should use __va(PAGE_SIZE) to duplicate the original
> lack of access to page 0).  The second provides a single map for
> all "vmalloc" space (the code still searches the vmlist to see
> what actually exists before accessing it).
> 
> Other blocks of kernel virtual space can be added as needed, and
> removed again (with kclist_del()).  E.g. discontiguous memory

Remove could get racy - /proc/kcore can sleep while accessing such
a block. You would need a sleeping lock hold all the time.

What would you need remove for?

> The second piece of abstraction is the kc_vaddr_to_offset() and
> kc_offset_to_vaddr() macros.  These provide mappings from kernel
> virtual addresses to offsets in the virtual file that /proc/kcore
> instantiates.  I hope they are sufficient to avoid negative offset
> problems that plagued the old /proc/kcore.  Default versions are
> provided for the old behaviour (mapping simply adds/subtracts
> PAGE_OFFSET).  For ia64 I just need to use a different offset
> as all kernel virtual allocations are in the high 37.5% of the
> 64-bit virtual address space.

I'm not sure it is a good idea from the interface standpoint, especially
for /dev/kmem.  It would surely be confusing for the user. Yes, a few applications and even some kernel code has signedness problems, but I would
better fix them instead of adding such a weird interface. 1:1 mapping would 
be a lot cleaner. It should not be that bad because on i386 the kernel
is also in negative space.

[i still have some 2.4 patches to fix a few 64bit signedness problems in /proc,
perhaps I should dust them off and port to 2.5]


> But if you have interesting stuff scattered across *every* part of
> the unsigned address range, then you won't be able to squeeze it all
> into a signed file offset.

The memory map on x86-64 is rather clean, that's no problem

Thanks for doing this work,
-Andi

