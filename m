From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 17 Oct 2003 16:56:44 +0000
Subject: loopback mount failing on 2.6.0-test7
Message-Id: <marc-linux-ia64-106641048226864@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Looks like some recent changes involving passing more errors up from
get_user_pages is making loopback mounting fail.  I've traced this down
to mount trying to do an mlockall (it probably shouldn't be doing this
for what it's attempting to do).  The test that's failing is:

!(flags & vma->vm_flags)

The values in question are:

flags: 0x1 VM_READ
vm_flags: 0x2070 VM_LOCKED, VM_MAY{READ,WRITE,EXEC}

I tested a 2.4 kernel, and the same test fails, but it's not propagated
out to the system call.  It appears that the failing region is the
"---p" mapping of libc.  x86 has no such mapping.  Is this a broken use
of mlockall, or does the error propagation change make it so mlockall
cannot work on ia64?  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

