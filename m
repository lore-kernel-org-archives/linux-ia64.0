From: Scott Murray <scottm@somanetworks.com>
Date: Sat, 26 Oct 2002 23:36:32 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805257@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805235@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805235@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 25 Oct 2002, Russell King wrote:

> On Fri, Oct 25, 2002 at 06:02:31PM -0400, Scott Murray wrote:
> > Unfortunately, my take on the scheme used to reserve space for CardBus
> > bridges was that it only works on platforms that use the setup-*.c code
> > to do their complete PCI subsystem initialization.  On platforms like
> > x86, where the BIOS configures all the devices, something like my patch
> > is needed to fixup things to handle the desired reservation.  I'm not
> > finished getting things ported to 2.5 yet, I'll post a patch ASAP once
> > I've got everything workin.  If you're keen on devising an alternative
> > method, check put my old patch against 2.4.19 at:
>
> I've been working on this in 2.5 this week - I've got something working,
> Alan's happy with the concept as far as the resource allocation goes.
>
> The cardbus reservation method is actually flawed in setup-*.c if you
> want to get rid of the stuff in yenta.c - again, I've fixed this lot
> in my 2.5 tree already, and the patch is pending an update to the x86
> code to do what yenta.c was doing (only setup bridge resources of the
> ones already programmed are bad/wrong.)

This sounds like it could remove the need for my manually specified
resource reservation scheme, does your code currently support arbitrary
bridges, i.e. non-CardBus?

Thanks,

Scott


-- 
Scott Murray
SOMA Networks, Inc.
Toronto, Ontario
e-mail: scottm@somanetworks.com


