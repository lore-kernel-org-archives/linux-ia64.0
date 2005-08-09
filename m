From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 09 Aug 2005 17:43:06 +0000
Subject: Re: Debian kernel and /proc/pal
Message-Id: <20050809174306.GA14415@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
In-Reply-To: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dann,

On Tue, Aug 09, 2005 at 10:40:16AM -0600, dann frazier wrote:
> On Mon, 2005-08-08 at 10:17 +1000, Ian Wienand wrote:
> > On Fri, Aug 05, 2005 at 01:36:54PM +0200, Stephane Eranian wrote:
> > > I recently used an Itanium machine booted with a 2.6 Linux kernel.
> > > The exact package is:
> > >         kernel-image-2.6.11-1-mckinley-smp_2.6.11-6_ia64.deb
> > > 
> > > It does appear that this kernel is compiled without CONFIG_PALINFO
> > > which means there is no /proc/pal/cpu* entries.
> > 
> > I filed this under
> > 
> > http://bugs.debian.org/cgi-bin/bugreport.cgi?bug21885
> > 
> > for the latest 2.6.12 packages which have the same thing.
> > 
> 
> Note that CONFIG_PALINFO was set to m - most things in Debian kernels
> are set to build as a module, if possible.
> 

What's the value of having PALINFO as module?
The firmware interface does not evolve very often.

If module is preferred then, some rc scripts should load it automatically
somehow. 

> I've made 2.6.12-2 link it statically.  However, it'd probably be good
> to have user apps load this module, if needed.

-- 
-Stephane
