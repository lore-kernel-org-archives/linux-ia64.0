From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 14 Jul 2000 21:37:34 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0-test4)
Message-Id: <marc-linux-ia64-105590678205199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a long overdue kernel update.  There relative diff I usually
provide would have been too big (and hard to read) to include in this
mail, so I'm just providing a summary of changes and the full diff,
relative to the official 2.4.0-test4 kernel can be found at:

	ftp://ftp.kernel.org/pub/linux/kernel/linux/ports/ia64/

as usual.  The filename for the current patch is:

	linux-2.4.0-test4-ia64-000714.diff.gz

Summary of changes:

	- latest IA-32 fixes by Don Dugger (Don, can you check sys_ia32.c?  I
	  changed the way utime() is implemented.  Also, I still think it would
	  be a good idea to try to make the mmap emulation good enough so that
	  it can be used for loading IA-32 ELF binaries.  Some code for doing
	  that is there now, though it's probably not complete.)

	- clone2 system call is there now (works like clone, except that it
	  specifies the stack memory area explicitly via a starting address
	  and size)

	- simplified kernel configuration for HP Simulator (Ski) by removing
	  options that don't make sense

	- probably a couple of other things I already forgot about---check patch
	  for a complete reference... ;-)

Enjoy,

	--david


