From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 13 Mar 2002 02:07:59 +0000
Subject: RE: [Linux-ia64] Linux-IA64 execution of ILP32 binaries
Message-Id: <marc-linux-ia64-105590701905249@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905245@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905245@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Mar 2002 18:00:55 -0800, "Smith, Phil" <APhil.Smith@compaq.com> said:

  Phil> My primary question wasn't as much about supporting ILP32
  Phil> development under Linux-IA64, but just executing binaries
  Phil> created under such an environment. The biggest question should
  Phil> surround the VM address space, which could be a subset of the
  Phil> Linux-IA64 map.

Oh, that's easy: you can set the maximum virtual address space size of
a task and its map-base to any value in the Linux kernel.  That's what
we use to enforce VM < 4GB for IA-32 tasks.

  Phil> If pointers are sign-extended, a single region
  Phil> in a 61-bit address area can accommodate the 32-bit range for
  Phil> x86. Obviously, things like big files could not be accessed
  Phil> without special APIs for the 32-bit developers.  Commercial
  Phil> UNIX vendors (i.e., HP and Sun) have taken great pains to
  Phil> provide a migration path. It seems that not accommodating this
  Phil> creates GREATER market fragmentation, especially with more
  Phil> commercial products being available on Linux. It seems ironic
  Phil> that 16-bit DOS, Windows and 32-bit Windows will still run
  Phil> under Wine or Win64, but 32-bit Linux software on the market
  Phil> today won't run on Linux-IA64...

You *can* run IA-32 binaries on IA-64 Linux.  Just try realplay or
some other x86-only application and I think you'll find it works just
fine.

	--david

