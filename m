From: Rich Altmaier <richa@engr.sgi.com>
Date: Mon, 20 Oct 2003 15:58:59 +0000
Subject: fielding PCI bus timeouts - was: prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106666582210383@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a note to mention experience with handling hardware failures.

For the case of user mappings to IO buses there are important
classes of aps, usually realtime or data acquisition, that
benefit from nice error handling of bus timeouts at user level.

These aps tend to be using old or prototype hardware, which can
fail (cause a bus timeout) during "normal" operation.
Or at least the user view is that the machine should not crash
due to "one flaky board".   Hence there is merit in being
able to translate a PIO-read bus timeout to say a SIGBUS.

More interesting is the case of PIO-write failure, as the writes
can be asynchronous.  Meaning by the time the hardware recognizes
a failure, the CPU's store instruction has graduated and the
CPU has moved on.  Perhaps gone through a context switch or
even exitted the user process.  In this case something more
than a SIGBUS is needed (IRIX has several options to deal with
this).  

On the thread about dd if=/dev/mem, I don't know of any legitmate
reason that user code needs to successfully recover from reading
non-existant phys memory.  I would suggest the princple that
bad user code should not cause a crash, and bad user code that
does a lot of reads would be thought harmless by many dangerous
users.  So some kind of error to the user process is probably
reasonable, perhaps SIGBUS.
Silently returning 0 doesn't sound right, as if there were any 
legitimate reason for this code in the first place, it probably
relates to some search of the physical address space.  Perhaps
a diagnostic.

FYI, Rich
