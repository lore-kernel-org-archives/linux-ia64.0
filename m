From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 19:53:42 +0000
Subject: Re: 2.6.3 _raw_write_trylock and __down_write_trylock
Message-Id: <16442.23110.704083.5403@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2402.1077498957@kao2.melbourne.sgi.com>
In-Reply-To: <2402.1077498957@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Feb 2004 12:15:57 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> 2.6.3 defines include/asm-ia64/spinlock.h::_raw_write_trylock
  Keith> (both asm and C versions) and
  Keith> include/asm-ia64/rwsem.h::__down_write_trylock.

  Keith> The C version of _raw_write_trylock is functionally identical
  Keith> to __down_write_trylock, but the code is completely
  Keith> different.  Why have two implementations with such radically
  Keith> different code for the same feature?  Why have both a C and
  Keith> asm version of _raw_write_trylock when the C version will
  Keith> work everywhere?

rwsem.h implements read-write semaphores, spinlock.h implements
read-write spinlocks.

GCC doesn't schedule the C code for _raw_write_lock() well, hence the
explicit ASM-version.

	--david
