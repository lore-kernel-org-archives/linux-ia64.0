From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 28 Feb 2001 23:23:45 +0000
Subject: Re: [Linux-ia64] Solid hangs with 2.4.1 + 010131 patch + timer bug patchlet...
Message-Id: <marc-linux-ia64-105590693005225@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005220@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005220@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 Feb 2001 17:29:07 +0100 (CET), 
Francis Galiegue <fg@mandrakesoft.com> wrote:
>First result at kdb: with no breakpoint, when the hangs occur, I cannot even
>enter kdb anymore...

Spinning with interrupts disabled.  The problem with kdb on ia64 is
that the ia64 kernel has no equivalent of the i386 NMI watchdog.
Without the NMI watchdog, there is no way to interrupt a disabled spin
loop so you cannot get into kdb.

Does anybody have any ideas for an ia64 NMI watchdog?  I could use a
performance counter, which is what I did on i386 UP machines.  But I
prefer a mechanism that does not need a dedicated performance counter.


