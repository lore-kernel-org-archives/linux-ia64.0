From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 06 Nov 2001 23:22:19 +0000
Subject: Re: [Linux-ia64] cpuinfo family changed in 2.4.7
Message-Id: <marc-linux-ia64-105590698805452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805447@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805447@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Hasn't Intel officially renamed it IPF?

No.  IA-32 is to Pentium as IA-64 is to Itanium.  The first one is the
architecture name, the second one is Intel's proprietary implementation of
that architecture.

Intel marketing will tell you that only the terms Pentium and Itanium (IPF)
are acceptable, but you have to consider the source.  Intel doesn't make
money when someone buys a generic IA-32 chip, like the AMD Athlon.  They
only make money if someone buys an Intel branded chip like the Pentium.
So Intel wants you to use the term Pentium always, so that more people will
be encouraged to buy Pentiums.  Likewise for Itanium.

GNU/Linux however supports all IA-32 chips, whether Intel makes them or not,
so we want to use generic architecture names like x86 and IA-32 instead of
Pentium.  Likewise, we will support all IA-64 chips, whether Intel makes them
or not, so IA-64 is preferable to Itanium and IPF when talking about the
architecture.

Jim

