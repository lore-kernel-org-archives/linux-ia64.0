From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Fri, 07 Sep 2001 19:36:12 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805140@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 07, 2001, Krishnakumar B <kitty@cs.wustl.edu> wrote:
> On Friday, 7 September 2001, KOCHI Takayoshi wrote:
> > Recently I noticed
> > 
> > keyboard: Timeout - AT keyboard not present?
> 
> I guess this happens because you are using a USB keyboard and the kernel
> looks for a PS/2 keyboard. New machines from Dell ship with a USB keyboard
> by default. Till the USB modules are loaded, I see this error (once or
> twice). Once the USB modules are loaded, this message disappears. Is there
> any way to prevent this happening ? I saw that when using RedHat's kernel,
> this message doesn't show up. What do I need to suppress this message if I
> have a USB keyboard ?

The only way to supress the message is to hack it out of the kernel.

The message comes from the fact the BIOS does legacy device emulation
for USB keyboards and mice. I think the ia64 BIOS supports this as well.
However, the emulation isn't perfect and will cause messages like this.

When the HC driver loads, it turns this off and natively handles the USB
keyboard.

The real fix is to use USB drivers as early as possible. The emulation
wasn't designed to be perfect.

JE


