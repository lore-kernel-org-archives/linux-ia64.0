From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 07 Jul 2005 22:27:18 +0000
Subject: Re: [PATCH 2.6.13-rc1 01/10] IOCHK interface for I/O error
Message-Id: <1120775239.31924.262.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com>
	 <20050707184102.GC14726@kroah.com>
In-Reply-To: <20050707184102.GC14726@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Linas Vepstas <linas@austin.ibm.com>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On Thu, 2005-07-07 at 11:41 -0700, Greg KH wrote:
> On Wed, Jul 06, 2005 at 01:53:06PM +0900, Hidetoshi Seto wrote:
> > Hi all,
> > 
> > The followings are updated version of patches I've posted to
> > implement IOCHK interface for I/O error handling/detecting.
> > 
> > The abstraction of patches hasn't changed, so please refer
> > archives if you need, e.g.: http://lwn.net/Articles/139240/
> 
> How about the issue of tying this into the other pci error reporting
> infrastructure that is being worked on?

The other infrastructure is for asynchronous reporting and recovery. We
still need synchronous detection & reporting. So this is a bit
different.

However, it would be nice if Hidetoshi's work could be adapted a bit so
that 1) naming is a bit more consistent with the other stuff (pcierr_*
maybe) and 2) the error "token" is the same. The later is especially
important if we start adding ways to query the error token to know what
the error precisely was etc... There is no reason to have 2 different
ways of representing error details.

Ben


