From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 May 2003 23:51:43 +0000
Subject: [Linux-ia64] RE: /proc/kcore - how to fix it
Message-Id: <marc-linux-ia64-105590723706022@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705961@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705961@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> One alternative I considered was to use just do a page table lookup.
> But I fear that some architectures use direct mapping registers etc.
> with mappings not in the page tables for the direct mapping, so it 
> probably won't work for everybody.

You are right.  IA64 maps the kernel with some locked registers, so
there are no pagetables to show that the mapping exists.
 
> What I'm worrying about is that the kernel will oops when accessing
> unmapped memory. That certainly should not happen.

Agreed.  Oops is always a bad thing.

> > /proc/kcore is a bit different because it's trying to present
> > a regular file view, rather than a char-special file view to
> > any tool that wants to use it.  If someone fixes up gdb, objdump,
> > readelf, etc. then the macros can be easily removed to provide 1:1
> > (though even then it isn't quite 1:1 ... offset in file would be
> > "vaddr + elf_buflen" to allow space for the elf headers at the start
> > of the file.
> 
> You're doing this to handle tools that have signedness bugs while
> parsing core files? iirc gdb is clean. What other tools have the 
> problem? 

I don't know ... you'll have to dust off those fixes for /proc to let
the negative file offsets get as far as the kcore.c code so we can
see what utilities work.  In practice we probably don't care about
anything other than gdb.

-Tony

