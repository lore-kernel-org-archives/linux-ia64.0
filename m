From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 25 Apr 2003 01:05:37 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705605@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 24, 2003 at 06:44:41PM -0600, Bjorn Helgaas wrote:
> I think we're talking about two different things.

Maybe, but either way there's something I don't understand.

> If I understand it correctly, the reason for the patch you mentioned
> is to take a device (VGA) that appears at a fixed IO port address,
> and tweak the driver so it can talk to the device at a different
> IO port address.

Right.

> It doesn't expand the size of the IO port space, it just gives
> you a hook to say "this hard-coded region of IO port space
> really corresponds to this other region on my platform".

Couldn't it be used to do that though?  If drivers are required to
call request_legacy_region and pass in a pci_bus, they'll get back a
new io_base that they need to make use of.  Isn't that similar to the
way you create multiple legacy I/O port spaces?

> On the other hand, my patch is completely platform-specific and
> allows us to address new IO port space that was previously not
> accessible at all.  For example, on HP machines, the ia64 64K
> "legacy IO port space" all gets routed to a single IO controller.
> Here's a sample /proc/ioports:

I must be missing something.  I understand that you've effectively
created legacy I/O port spaces for each pci controller, but I don't
see how that helps you with a driver that does e.g. inb(0x3e8).  What
do you anticipate that your stuff will be used for?  That would help
out a bit...

Thanks,
Jesse

