From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 07 Dec 2001 22:43:55 +0000
Subject: [Linux-ia64] 2.4.16 and truncating a file on open()
Message-Id: <marc-linux-ia64-105590698805652@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 

I am struggling with a problem with open() on 2.4.16-011128. I don't 
think that the bug is IA-64 specific but I post it here in case someone
has seen this one before. I'll post it to lkm later.

--------------------------------------------------------------------------
I am running a multithreaded program in which each of the to "slave" 
thread opens a different file via a fopen(myfile, "w"). Because I run 
this program several times in a row, the file is almost always in the buffer
cache. The open will truncate the content of the file. 

Now I get a kernel panic due to a failed sanity check in __free_pages_ok() 
because the page that the kernel tries to free is still locked. Using KDB 
I captured the following stack trace. This is with kernel-2.4.16 release + 
IA-64 patche (011128). I do not think that this problem is IA-64 related 
however. 

I looked at the code path and sure enough, by the time the free_pages_ok() 
routine is called, the page will always be locked due to the TryLockPage() 
that is in truncate_list_pages(). This seems to be required to perform the 
remove_inode_page() operation but this is treated as a failure by 
free_pages_ok() which immedialely follows in this case.

My question is: Is there a missing UnlockPage() somewhere on this code path?
	        If not then, how did I get into this situation?

Here is the stack trace obtained with KDB/ia64:

	sys_open+0xa0
        args (0x20000000008077c0, 0x241, 0x1b6, 0xc000000000000690, 0xc000000000000308)

	filp_open+0x60
        args (0xe000000004293000, 0x8241, 0x1b6, 0xe00000000453cfe0, 0x813)

	open_namei+0xb90
        args (0xe00000003dfbc248, 0x8242, 0x1b6, 0xe00000003e88fe40, 0x0)

	do_truncate+0x90
        args (0xe00000003c5d89c0, 0x0, 0xe00000003b6ae578, 0xe00000000455c470, 0x711)

	notify_change+0x2a0
        args (0xe00000003c5d89c0, 0xe00000003e88fdf0, 0x0, 0xe00000003b6ae4c0, 0x48)

	inode_setattr+0x50
        args (0xe00000003b6ae4c0, 0xe00000003e88fdf0, 0x48, 0x0, 0xe0000000045774e0)

	vmtruncate+0x160
        args (0xe00000003b6ae4c0, 0x0, 0xe00000003b6ae648, 0xe00000003b6ae650, 0xe00000003b6ae5f8)

	truncate_inode_pages+0xc0
        args (0xe00000003b6ae5f8, 0x0, 0xe0000000044971e0, 0x0, 0xe00000003b6ae618)

	truncate_list_pages+0x2e0
        args (0xe00000003b6ae5f8, 0x0, 0xe00000003e88fde0, 0xe00000000085ca00, 0x0)

	truncate_complete_page+0x110
       args (0xe00000000085ca00, 0xe000000004518f40, 0x60f)

	page_cache_release+0x80
        args (0xe00000000085ca00, 0xe000000004518c30, 0x185)

	__free_pages_ok+0x1e0
        args (0xe00000000085ca00, 0x0, 0xe00000000085ca30, 0xe00000000085ca30, 0x0)

Failed in __free_pages_ok() (mm/page_alloc.c): if (PageLocked(page)) BUG()

	ia64_leave_kernel
        args (0xe00000003e88fc30, 0x80200000000, 0xe00000003e88fc40)

	ia64_do_page_fault+0x810
        args (0xe00000003e88fc30, 0x80200000000, 0xe00000003e88fc40, 0x0, 0xe00000003d6bcc00)

	die+0x220
        args (0xe0000000049ddab8, 0xe00000003e88fc40, 0x80200000000, 0xe0000000044c59f0, 0x58f)
-- 
-Stephane

