From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 Aug 2002 05:42:23 +0000
Subject: [Linux-ia64] kernel update (relative to v2.5.32)
Message-Id: <marc-linux-ia64-105590701906002@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, the latest ia64 patch should show up shortly at:

	ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5

in file: linux-2.5.32-ia64-020829.diff.gz

Please see http://lia64.bkbits.net:8080/to-linus-2.5
for change log entries.

Note: I cobbled together a version of 8250_hcdp.c which ought to work,
but I don't have firmware to test it with, so it's quite possible it
doesn't work quite right.  At the moment, this should affect only hp
zx1-based machines.

Note 2: You may have heard that Linus took out the big stick once
again and replaced the new & sort-of-improved IDE subsystem with the
old (and reliable?) one.  I haven't done much testing, but this kernel
at least can read from an IDE CD-ROM again.

Oh, PS/2 keyboards & mice don't seem to work too well at the moment.
USB seems to work fine, though.

Enjoy,

	--david

