From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 May 2002 17:49:56 +0000
Subject: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905553@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated ia64 patch for 2.4.18 is now at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4 in file:

	linux-2.4.18-ia64-020508.diff.gz

Most of the changes are backports of 2.5 changes.  For those, see the
changelog entries at

 http://lia64.bkbits.net:8080/to-linus-2.5/ChangeSet@-7d?nav=index.html

Summary of other changes:

	o Rename "McKinley" to "Itanium 2" (only for user-level
	  visible stuff, CONFIG_MCKINLEY will stay).
	o Offer 64KB page size only for Itanium 2.
	o Change local_irq_restore() to restore ONLY the psr.i bit.
	o Add ia64_set_psr() as the new way for setting psr.l.
	o Perfmon-update from Stephane (sans McKinley support, until
	  the necessary info gets released publically).
	o Updated Fusion driver (needed for some of HP's zx1 platforms)
	o Fixed scsi_dma.c to support 64KB page size

Some notes/caveats: the 64KB page size seems to work fine on
McKinley/Itanium 2 except that "swapon" still hangs for me.  I haven't
had time to look into this.  If you look at the patch, you'll also see
that I started merging the "mem_map in virtual memory" patch
(CONFIG_VIRTUAL_MEM_MAP), which is currently needed on zx1 platforms
with >1GB of memory.  However, the merge isn't complete and the new
code isn't working yet.  If you are one of those lucky folks with such
a machine, you'll have to do the following for now:

	o configure for generic DIG platform (this means you won't get
	  support for the zx1 hardware I/O TLB)
	o boot with kernel command line option mem=1G (will ignore all
	  memory above 1GB)

These issues will get fixed over time, but for now the above should at
least give you a working kernel.

A slightly earlier version of this patch (without the perfmon update)
has been tested on the Ski simulator, Big Sur, and the HP zx1
platform.

Enjoy,

	--david

