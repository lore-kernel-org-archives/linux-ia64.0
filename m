From: Matt_Domsch@Dell.com
Date: Mon, 26 Feb 2001 23:21:43 +0000
Subject: [Linux-ia64] [RFC][PATCH] /proc access to EFI variables
Message-Id: <marc-linux-ia64-105590693005209@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've created a kernel patch which makes all the EFI variables available
under /proc/efi.  Support for reading, writing, creating, and destroying
variables is present.  This patch is at version 0.01.  I've tested it
myself, and am making it available for comment.  It should not be included
in David's kernel port yet, nor in any distributions.

Other changes include:
- exporting struct efi in kernel/ia64_ksyms.c so efivars can be a module
- setting the high bit on EFI error status codes in include/asm-ia64/efi.h
(per spec)

The patch is available at
http://domsch.com/linux/ia64/linux-2.4.1-010131-efivars-010226.patch.

I welcome any feedback people may have.  In particular, if you know of a
better way to handle the naming of files, I'm happy to find something
better.  File names like Boot0000-8be4df61-93ca-11d2-aa0d-00e098032b8c are
ugly, but required to uniquely distinguish between vendor variables.  Also,
I've made the assumption that the variable names are in UTF8, and that I can
ignore the top 8 bits of each unicode character to create a char* file name.

Thanks,
Matt

--
Matt Domsch
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux


