From: Andreas Schwab <schwab@suse.de>
Date: Mon, 03 Sep 2001 10:15:55 +0000
Subject: [Linux-ia64] Booting problem with big memory
Message-Id: <marc-linux-ia64-105590698805114@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The kernel is unable to boot a Lion with 44GB unless I pass "mem=3D44G" to
the kernel.  The last kernel messages include (this is from memory, it
panics even before the serial console is up):

warning: skipping physical page 0xbfff6000
Initial ramdisk at: 0xffffffffffffffff (18446744073709551615 bytes)
.....
bootmem alloc of 50 bytes failed!
Kernel Panic: Out of memory

This is with 2.4.7 and 2.4.9.  Note that I booted without an initrd.
Looks like something is being overwritten.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

