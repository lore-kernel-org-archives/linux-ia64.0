From: Zoltan MENYHART <Zoltan.Menyhart@m6net.fr>
Date: Thu, 15 Jan 2004 22:31:50 +0000
Subject: Mapping addresses 0xe000... and 0xc000...
Message-Id: <400714D6.2080609@m6net.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I guess most of my problems with "IA64_LOG_NEXT_BUFFER()", 
"salinfo_log_wakeup()", the KDB, unwinding the interrupted CPU's stack, 
etc. are related to the mapping of the addresses 0xe000... and 0xc000...

As far as I can see, when I touch such an address that is not mapped
by any TR or TC entry (the walker is off for these address ranges), then
the low level translation fault handler automatically inserts a new TC
entry that maps the address in the usual way.

Yet an alternate translation fault vector is used if the PSR.ic is off
(interrupts are disabled), and this handler does not map automatically
the addresses 0xe000... and 0xc000...

We are obliged to take locks and to disable interrupts, see e.g.
"IA64_LOG_NEXT_BUFFER()", the KDB.

Is it a VMM design issue not to allow automatic address mapping
if the PSR.ic is off ? Should not we revise it :-) ?

Zoltan Menyhart


