From: "Olivier, JeffreyX" <jeffreyx.olivier@intel.com>
Date: Mon, 05 Aug 2002 15:40:17 +0000
Subject: RE: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905906@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Yes, normally there is one entry per mapped file.  If you use munmap()
>and mmap() a lot, the merging-logic in the kernel may not be able to
>keep up and then you'd get fragmented maps, even when they could be
>merged in theory.  However, from what you have described so far, I do
>not think this is something you'd be running into.  So something seems
>strange here.

Your suggestion that munmap() might fragment the map reminded me of
something else.  Upon receiving a write notice from another node for a page,
our system uses mprotect on the page so that we can't write to it without
causing a segmentation fault.  Since we do this on a per-page basis, this is
likely the cause of the multiple mappings and since we are doing this over
such a large address space, it is likely that the linux default of 65536
memory maps is the problem.  Does that seem reasonable?  

I can see two possible solutions:

1.  Develop an algorithm to efficiently combine memory mappings with the
same protections.  This would be fairly straight forward for my program but
for more sporadic memory accesses, it might not work very well.
2.  Change the default maximum number of mappings.  I noticed a
/proc/sys/vm/max_map_count variable.  Can this be increased safely?

Thanks for the help!

-Jeff

