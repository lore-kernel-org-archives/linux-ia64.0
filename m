From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 30 Oct 2001 02:20:50 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805413@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 26 Oct 2001 16:36:22 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> David Mosberger <davidm@hpl.hp.com> writes: |> An updated
  Andreas> ia64 patch for 2.4.13 is now available at |>
  Andreas> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

  Andreas> The patch add a definition for bust_spinlocks in
  Andreas> arch/ia64/kernel/traps.c which is slightly different from
  Andreas> the implementation in lib/bust_spinlocks.c.  Does it make
  Andreas> sense to merge them?

Not unless you make them exactly the same. ;-)

The issue is global_irq_lock.  It's existence depends on the platform.
FYI, i386 does the same thing (just in a different place: mm/fault.c).

	--david

