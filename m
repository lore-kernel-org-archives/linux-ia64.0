From: Krishnakumar B <kitty@cs.wustl.edu>
Date: Fri, 07 Sep 2001 19:55:36 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, 7 September 2001, Johannes Erdfelt wrote:
> 
> The only way to supress the message is to hack it out of the kernel.
> 
> The message comes from the fact the BIOS does legacy device emulation
> for USB keyboards and mice. I think the ia64 BIOS supports this as well.
> However, the emulation isn't perfect and will cause messages like this.
> 
> When the HC driver loads, it turns this off and natively handles the USB
> keyboard.
> 
> The real fix is to use USB drivers as early as possible.

How does one do this ? Can it be loaded via initrd ? I got some symbol
referencing errors while doing this. Then the uhci module was loaded as
usual when booting and this time there were no symbol referencing errors.

-kitty.

-- 
Krishnakumar B <kitty at cs dot wustl dot edu>
Distributed Object Computing Laboratory, Washington University in St.Louis

