From: Keith Owens <kaos@sgi.com>
Date: Mon, 23 Feb 2004 01:15:57 +0000
Subject: 2.6.3 _raw_write_trylock and __down_write_trylock
Message-Id: <2402.1077498957@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.6.3 defines include/asm-ia64/spinlock.h::_raw_write_trylock (both asm
and C versions) and include/asm-ia64/rwsem.h::__down_write_trylock.

The C version of _raw_write_trylock is functionally identical to
__down_write_trylock, but the code is completely different.  Why have
two implementations with such radically different code for the same
feature?  Why have both a C and asm version of _raw_write_trylock when
the C version will work everywhere?

