From: Keith Owens <kaos@sgi.com>
Date: Fri, 19 Aug 2005 07:08:14 +0000
Subject: Understanding XIP, XPSR, XFS registers
Message-Id: <8491.1124435294@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Resuming after MCA/INIT when psr.ic = 1 is relatively easy and it
appears to work with the new MCA/INIT handlers.  Resuming after
MCA/INIT when psr.ic = 0 (i.e. the event occurred in an interrupt
handler) is proving to be a problem.

When MCA/INIT occurs and psr.ic = 0, what is in X{IP,PSR,FS} in PAL
minstate?  Is it the original values of I{IP,PSR,FS}, with I{IP,PSR,FS}
replaced by the values when MCA/INIT was delivered?  Or is I{IP,PSR,FS}
left alone (i.e. they still contain the values delivered to the
interrupt handler), with X{IP,PSR,FS} set to the values when MCA/INIT
was delivered?

Common sense says that I{IP,PSR,FS} is left alone when psr.ic = 0, with
the new values being stored in X{IP,PSR,FS}.  However Intel Itanium
Architecture Software Developer's Manual Volume 2: System Architecture
(24531804.pdf), 11.3.3 Returning to the Interrupted Process, implies
the reverse.

