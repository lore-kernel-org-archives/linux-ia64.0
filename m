From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Fri, 07 Sep 2001 20:02:52 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805142@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 07, 2001, Krishnakumar B <kitty@cs.wustl.edu> wrote:
> On Friday, 7 September 2001, Johannes Erdfelt wrote:
> > 
> > The only way to supress the message is to hack it out of the kernel.
> > 
> > The message comes from the fact the BIOS does legacy device emulation
> > for USB keyboards and mice. I think the ia64 BIOS supports this as well.
> > However, the emulation isn't perfect and will cause messages like this.
> > 
> > When the HC driver loads, it turns this off and natively handles the USB
> > keyboard.
> > 
> > The real fix is to use USB drivers as early as possible.
> 
> How does one do this ? Can it be loaded via initrd ? I got some symbol
> referencing errors while doing this. Then the uhci module was loaded as
> usual when booting and this time there were no symbol referencing errors.

There should be no reason it can't be loaded via initrd.

Any symbol problems would most likely be a problem with the distribution
you are using.

JE


