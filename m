From: dann frazier <dannf@hp.com>
Date: Wed, 23 Feb 2005 01:41:59 +0000
Subject: Re: discontinued zx1 based machine: hp zx6000. problems
Message-Id: <1109122919.1302.84.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <200502230129.j1N1T5Ap007480@csd.cs.technion.ac.il>
In-Reply-To: <200502230129.j1N1T5Ap007480@csd.cs.technion.ac.il>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-23 at 03:29 +0200, Max Kovgan wrote:
> Hello, list!
> 
> Either my hands are skewed or something is wrong with this ia64 port, or even worse.
> 
> i am a debian user.
> hardware: zx6000, no ps/2, only usb keyboard ( this one has also 2 usb sockets, so it should also be a USB hub )
> 
> my woes:
> tried installing sarge: linux 2.4.21 (mckinley-smp).

Sounds like ancient boot media - current RC releases use 2.6.8 & 2.4.27.
Shouldn't matter though, you got it installed...

> during the installer keyboard worked.
> after the installation's 1st boot - everything worked.
> ok.. trying to upgrade....
> 
> tried 2.6.9-2 ( mckinley-smp ) - installer worked ok.
> after a reboot - cannot use neither keyboard nor mouse.

Try Debian's 2.6.10, 2.6.9 is no longer actively maintained and will be
dropped from the archive.

Make sure you have hotplug installed.

debian-ia64@lists.debian.org is a better venue for this discussion -
lets move this thread there.



