From: Matt Domsch <Matt_Domsch@dell.com>
Date: Wed, 18 Jan 2006 18:11:17 +0000
Subject: Re: [Openipmi-developer] Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <20060118181116.GA5537@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <200601131724.42054.bjorn.helgaas@hp.com> <200601171717.03192.bjorn.helgaas@hp.com> <200601181029.46352.bjorn.helgaas@hp.com>
In-Reply-To: <200601181029.46352.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

On Wed, Jan 18, 2006 at 10:29:46AM -0700, Bjorn Helgaas wrote:
> Matt, what's your opinion on proceeding?  I know you want to get
> the DMI stuff in distros.  I'm looking at reworking ioremap to
> hide all this stuff, but that'll be a bigger change and may be
> harder to get into distro releases.
> 
> For upstream, the ioremap rework sounds like the way to go, but
> I don't know which the distros would prefer for updates.

Existing distros (RHEL3, RHEL4, SLES9, ..) don't have a huge problem
because my target user - the ipmi driver - does its own DMI scanning
on those distros still.  Ugly, but works.  So the only concern is
SLES10 and RHEL5, both of which are still rebasing to upstream best as
I can tell from their publicly posted kernels.  So if it can be done
"right" in 2.6.16-rc, let's do that.  If it will be intrusive, and
after 2.6.16 is out, than a minimally intrusive but working patch for
2.6.16-rc would be preferred.

Thanks!
Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
