From: John Hesterberg <jh@sgi.com>
Date: Mon, 11 Feb 2002 19:17:44 +0000
Subject: [Linux-ia64] driver location for platform-specific drivers
Message-Id: <marc-linux-ia64-105590698806031@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linus & Marcelo,

For SGI's upcoming Linux platform (nicknamed Scalable Node, or SN),
we have some platform specific device drivers.  Where should these go?
I see several precedents in the current kernels.

    1) Integrate in drivers/*.
       Integrate SN drivers into appropriate directories.
       Put them directly in char, net, misc, etc., as appropriate.

    2) Company (sgi) directory.
       There is already an sgi directory, strangely enough.
       I *think* this was meant to be a platform directory for the
       discontinued SGI 320/540 Visual Workstations.  However, maybe
       it was intended to be a new precedent of company specific
       directories.  In this case, we'd probably create a platform
       directory under the company directory, so there would likely
       be drivers/sgi/sn (some of our SN drivers are here today in
       our internal development tree).  However, there is no other
       precedent for "company" subdirectories under drivers.  Apple
       didn't do it.  IBM didn't do it.  HP hasn't done it.  Was the
       drivers/sgi directory really intended to start a new
       precedent of company specific directories under drivers?

    3) New platform directory.
       Create a platform directory for SN, probably drivers/sn.
       There is precedence for this with the drivers/macintosh
       and drivers/s390.  Also, as noted, the SGI Visual Workstation
       drivers are in drivers/sgi.  In this case, it might also make
       sense to rename drivers/sgi to drivers/visws to indicate
       these are drivers for the Visual Workstation platform, and
       not generic SGI drivers.

    4) New architecture directory.
       Another suggestion is to create an architecture directory,
       in this case drivers/ia64/{char,net,etc.}/.

I'm happy with whatever you'll accept.  To give you something to
either agree with or shoot down, I'll suggest #3.  SGI's Scalable
Node product will be different enough, with enough platform specific
drivers, that it justifies it's own subdirectory, and that this
should be called drivers/sn.

John Hesterberg
jh@sgi.com

