From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 27 Nov 2001 05:24:55 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.16)
Message-Id: <marc-linux-ia64-105590698805548@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated ia64 patch for 2.4.16 is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in file:

        linux-2.4.16-ia64-011126.diff*

change log:

	- update for 2.4.15/2.4.16:
		- add show_trace_task()
		- lots of SGI SN updates (most in "sn" subdirectories)
		- IA-32 brk() fix by Don Dugger
	- drop some of the more cosmetic fixes (they will be in the 2.5 tree
	  instead)
	- fix EARLY_PRINTK (Tony Luck, I think)
	- in iosapic.c, move RTE programming to a saner place (Alex Williamson)
	- fix alignment of bootmap
	- move machvec_init() a little earlier and call platform_cpu_init() at
	  end of cpu_init() (Jack Steiner)
	- swiotlb.c: support "page" member in scatterlist
	- fix asm clobbers in spinlock.h
	- add more ACPI tables to asm-ia64/acpi-ext.h

This kernel has been tested with gcc-3.0 on Big Sur and HP Ski
simulator.  As usual, your mileage may vary.

Enjoy,

	--david

