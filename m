From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 20 May 2003 20:05:15 +0000
Subject: [Linux-ia64] /proc/kcore - how to fix it
Message-Id: <marc-linux-ia64-105590723705960@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This conversation started over on the ia64 kernel list, but it needs a
wider audience.

The story so far for new readers:
/proc/kcore has been broken on some architectures for a long time. Problems
surround the fact that some architectures allocate memory for vmalloc()
and thus modules at addresses below PAGE_OFFSET, which results in negative
file offsets in the virtual core file image provided by /proc/kcore. There
are also pending problems for discontig memory systems as /proc/kcore just
pretends that there are no holes between "PAGE_OFFSET" and "high_memory",
so an unwary user (ok super-user) can read non-existant memory which may
do bad things. There may also be kernel objects that would be nice to
view in /proc/kcore, but do not show up there.

A pending change on ia64 to allow booting on machines that don't have
physical memory in any convenient pre-determined place will make things
even worse, because the kernel itself won't show up in the current
implementation of /proc/kcore!

I tried to fix this by taking a suggestion made by Andi Kleen in one of
the previous threads on this topic, and added an entry to "vmlist" for
the kernel ...

 Tony> I've juggled the addresses around again, moving the kernel up to
 Tony> 0xA000004000000000 and VMALLOC_START back down to 0xA000000000030000
 Tony> so that the entry for the kernel goes on the *end* of the vmlist,
 Tony> so we don't have to uselessly step over it on every call to vmalloc().

 David> I don't want the kernel layout to be constrained by something as
 David> esoteric as kcore.  Let's fix kcore for good.

So I'm looking at what it might take to "fix kcore for good", and the first
issue I hit was I'm not exactly sure what the requirements are, since I
never use /proc/kcore except when people complain that my kernel address
shuffling has broken things.

Presumably people expect to see kernel code/data in /proc/kcore.
On x86 they can also see every piece of vmalloc() memory. Do they really
need them all, or just the ones that are being used for modules? Do we
really want to have separate elf_phdrs for every one of them, or could
we just have one section that covers addresses from VMALLOC_START to
VMALLOC_END, and then test whether pages have been mapped in that range
before accessing them?

What about discontiguous memory.  Since /proc/kcore is super-user only
we could continue with the attitude that the user should be careful not
to touch memory that doesn't exist, or we could be kind and provide an
API so that the architecture specific code that finds the memory can tell
/proc/kcore what exists.

What about other random architecture specific blobs of kernel address
space memory (e.g. ia64 percpu memory).  Should they get a elf_phdr too?

What about the "negative file offset" problem.  Current 2.5 code has
KCORE_BASE which is part of a solution for this ... a simple change
so that kcore.c reads:
	#ifndef KCORE_BASE
	#define KCORE_BASE PAGE_OFFSET
	#endif
so that architectures could define their own KCORE_BASE value would
help for ia64 (since all kernel addresses are in the top 3/8 of the
address space ... we can avoid negative offsets by picking KCORE_BASE
low enough that all offsets are positive).  This won't help you if your
architecture spreads kernel objects across your full address space.

-Tony

