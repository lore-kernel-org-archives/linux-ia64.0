From: Tom Rini <trini@kernel.crashing.org>
Date: Mon, 11 Feb 2002 19:54:58 +0000
Subject: [Linux-ia64] Re: driver location for platform-specific drivers
Message-Id: <marc-linux-ia64-105590698806032@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 11, 2002 at 01:17:44PM -0600, John Hesterberg wrote:

>     3) New platform directory.
>        Create a platform directory for SN, probably drivers/sn.
>        There is precedence for this with the drivers/macintosh


Being a PPC person, I sometimes wonder if this wsn't a horrible idea
sometimes.  Much of whats in thereshould be in a 'drivers/adb' or so,
ince it's all specific to the ADB bus, with the exception of things like
'rtc.c' (which works on all PPC except APUS).  Keep in mind other
'macintosh' specific drivers, like network ones, are in drivers/net/.

Wer also have an arch/ppc/{8xx,8260}_io/ directories for other
platform-specific drivers, which I want to kill in 2.5.x timeframe.

> I'm happy with whatever you'll accept.  To give you something to
> either agree with or shoot down, I'll suggest #3.  SGI's Scalable
> Node product will be different enough, with enough platform specific
> drivers, that it justifies it's own subdirectory, and that this
> should be called drivers/sn.

What excelty are the specific to tho?  Are these all for a new bus?
If these are just variopus network, io, whatnot drivers, just put them
in drivers/whatever.

--
Tom Rini (TR1265)
http://gate.crashing.org/~trini/

