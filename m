From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 May 2003 23:43:36 +0000
Subject: [Linux-ia64] RE: /proc/kcore - how to fix it
Message-Id: <marc-linux-ia64-105590723706023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705961@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705961@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I suspect the easiest thing may be to arrange for the discontig direct
> mapped memory blocks to appear on the vmlist and then remove 
> the special
> case for the direct mapped RAM.  I don't see why architecture support
> needs to come into the picture really.

I did experiment with adding the architectural weird stuff to the vmlist.
But I wasn't entirely happy with it.  There were two choices:

1) Add any random thing to vmlist and fixup /proc/kcore code to check
   for other stuff outside the VMALLOC_START,VMALLOC_END range (as you
   suggested last year, an implemented in the patch you showed today).

This feels like it is abusing the vmlist.  Only one piece of code would
actually break (get_vmalloc_info() in fs/proc/proc_misc.c, and it could
easily be fixed).  But it just feels kludgy.

2) Force the random things to be allocated in the VMALLOC_START,VMALLOC_END
   address range.

I tried this, and David complained about esoteric features like kcore
dictating important stuff like kernel layout decisions.  Probably isn't
even an option for most architecture.

> I don't believe any races here are that important (except of course
> ensuring that we produce consistent data for a particular read() and
> not oopsing the kernel) - take a moment to think where the information
> /proc/kcore provides ends up and realise that as soon as it hits
> userspace, you can't rely on it.  eg, Today, if you're using it and
> you insert a module, the structure of the file changes, and gdb's
> idea of offsets of data into the "core" becomes invalid.

Actually inserting/deleting modules won't change the offsets
of other objects inside /proc/kcore (unless you add enough modules
to bump the elf_buflen size of the header to consume an extra page).
The offsets in /proc/kcore are all based on the virtual address
of the object ... not on the number/size of any preceeding objects,
so the /proc/kcore file is full of holes in the spots where things
are not currently mapped.
If gdb went back and re-read the elf headers it might be surprised
to find the elf_phdrs were appearing and disappearing ... but offsets
into the rest of the file won't (generally) change.

-Tony

