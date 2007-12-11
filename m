From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 11 Dec 2007 00:09:09 +0000
Subject: Re: Linux on Intel "Big Sur"
Message-Id: <200712101709.09816.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <475C2CF3.9010206@netbynet.ru>
In-Reply-To: <475C2CF3.9010206@netbynet.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 10 December 2007 03:03:42 pm Alexei Gerasimov wrote:
> Bjorn Helgaas wrote:
> > I've only used the HP i2000 version, and even that's been a long time,
> > but my guess is that the firmware upgrade would be safe, and that the
> > appropriate HP-UX version would probably run on it.
> >   
> I've discovered a small detail about updates: the firmware update seems
> to be safe, but the BIOS update (to the version 1.30) available from the
> HP website is marked as for CPU's with C2 stepping. According to my
> CPUID, my Itanium's are C0 stepping, therefore an update to the version
> dedicated for CPU's with different stepping might be fatal. Personally,
> I don't know what stepping is, thus cannot be sure to make any
> conclusions. What do you think about this?

CPU steppings are minor changes to the processor, usually to fix
problems.  The CPU comes with a piece of firmware called PAL that
is specific to the CPU model.  The PAL is packaged up as part of
the firmware update from HP, but the PAL itself comes from Intel,
and we really don't have much visibility into it.

Normally, a new PAL would work on all previous steppings of a given
processor model, but sometimes there are exceptions, especially for
early prototype CPUs.

If this were my machine, and I really, really wanted to get it
working (it's ancient and slow by today's standards), I would leave
the firmware alone and try to debug it as a Linux problem.  If it
turns out to be a firmware issue, you could try the upgrade.  But
I'd hate to brick the box if it failed.

Bjorn
