From: "Matthews, Robert" <Robert.Matthews@COMPAQ.com>
Date: Mon, 12 Mar 2001 21:31:27 +0000
Subject: [Linux-ia64] mmap issue
Message-Id: <marc-linux-ia64-105590693005274@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone tried using mmap to remap PCI device memory into user space?  I
have seen the following problem:  If I do the mmap, it returns successfully,
and I can indeed access the device memory.  Unfortunately, the system will
hang within about a minute after doing so.  I do not get an oops, or crash
of any kind, simply no further response form the machine.  If I just do the
mmap and then munmap the system will not hang.  But if I do one access to
the mmapped address, the system will hang.  I am using the remap_page_range
call in my mmap routine, and this same code works on x86 and Alpha
platforms.  I found it odd that it takes a while for the system to hang
after the access, is their something special I have to do for this to work
on IA64?  I am running 2.4.1 with the 1/31 patch, although this problem
occurs on all previous kernels I have tried.  Thanks in advance for any
insight anyone might have.

Robert Matthews
Evaluation Test Development
Compaq Computer Corp
Voice: (281)518-1950 Fax:(281)514-9541
robert.matthews@compaq.com 



