From: Marc Aurele La France <tsi@ualberta.ca>
Date: Thu, 26 Jul 2001 20:39:30 +0000
Subject: [Linux-ia64] Re: [Xpert]XFree86 4.1.0, Linux/ia64, and various video cards
Message-Id: <marc-linux-ia64-105590693005933@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 26 Jul 2001, Branden Robinson wrote:

> Here's a report on some hardware testing we've been doing at Progeny:

> The tests were conducted using a patched version of 4.1.0 for Debian and
> Progeny that works around a problem with PIC symbols being absent in static
> libraries, which powerpc, ia64, and hppa (among possible others) do not
> tolerate.  At the same time, PIC symbols in X server modules cause the X
> server to segfault.  I'll be submitting this patch to XFree86 shortly.

> The tests were run on an HP Workstation i2000.

> 5) ATI Rage Pro Turbo AGP
> 	The server crashed on startup with a SIGILL; a log file is
> 	attached.  I presume the atimisc driver has not yet been ported to
> 	ia64.

Err.  The ATI driver was one of the ones used to do the port.

No attachment present.

Marc.

+----------------------------------+-----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310           |
|  Computing and Network Services  |  fax:    1-780-492-1729           |
|  352 General Services Building   |  email:  tsi@ualberta.ca          |
|  University of Alberta           +-----------------------------------+
|  Edmonton, Alberta               |                                   |
|  T6G 2H1                         |     Standard disclaimers apply    |
|  CANADA                          |                                   |
+----------------------------------+-----------------------------------+
XFree86 Core Team member.  ATI driver and X server internals.


