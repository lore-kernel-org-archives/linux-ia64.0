From: Jim Wilson <wilson@redhat.com>
Date: Sat, 30 Mar 2002 20:41:34 +0000
Subject: Re: [Linux-ia64] debuggers - ia64 gdb stubs?
Message-Id: <marc-linux-ia64-105590701905347@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905345@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905345@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>HP has an exceptional version of GDB, KWDB, that can do src debugging
>over the internet and it appears to have been ported to ia64.

Standard gdb can do this.  It is called gdbserver, and it has been a part of
gdb since 1993.

Before we had hardware, initial gdb work was done by running gdbserver under
linux on the simulator, and then connecting to it via tcp/ip from a cross-gdb
running on an x86-linux machine.  This was much faster than trying to run an
interactive gdb session under linux on the simulator.

The IA-64 gdbserver support is still there, but I don't know if anyone has
used it since we got hardware.  See the src/gdb/gdbserver directory in the
FSF GDB source tree.

Jim

