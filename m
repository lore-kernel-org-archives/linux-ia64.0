From: "Scott Murray" <scottm@somanetworks.com>
Date: Fri, 25 Oct 2002 22:02:31 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805253@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805235@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805235@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 25 Oct 2002, Ivan Kokshaysky wrote:

> On Thu, Oct 24, 2002 at 06:22:44PM -0400, Scott Murray wrote:
> > I hopefully will have something working against 2.5.44 tomorrow.  I think
> > the only potentially contentious piece that I'd like to get reviewed and
> > maybe integrated before the feature freeze is the resource reservation
> > stuff.  There seemed to be no serious objections to the 2.4.x version I
> > posted a while back, so maybe this won't be a big deal.  Everything else
> > is either __devinit/export tweaks or driver code.
>
> The setup-bus code already does resource reservation, but only for
> cardbus. It can be easily extended for any type of hotplug
> controller though. Other enhancements (like configurable amount
> of reserved IO/memory) also shouldn't be a problem.

Unfortunately, my take on the scheme used to reserve space for CardBus
bridges was that it only works on platforms that use the setup-*.c code
to do their complete PCI subsystem initialization.  On platforms like
x86, where the BIOS configures all the devices, something like my patch
is needed to fixup things to handle the desired reservation.  I'm not
finished getting things ported to 2.5 yet, I'll post a patch ASAP once
I've got everything workin.  If you're keen on devising an alternative
method, check put my old patch against 2.4.19 at:

http://marc.theaimsgroup.com/?l=linux-kernel&m2866931731553&w=2

[snip]
> BTW, 2.5 setup-* stuff went into 2.4 recently. :-)

Cool, that definitely will make my life easier.

Thanks,

Scott


-- 
Scott Murray
SOMA Networks, Inc.
Toronto, Ontario
e-mail: scottm@somanetworks.com


