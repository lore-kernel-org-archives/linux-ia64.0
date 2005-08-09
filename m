From: dann frazier <dannf@hp.com>
Date: Tue, 09 Aug 2005 17:59:11 +0000
Subject: Re: Debian kernel and /proc/pal
Message-Id: <1123610477.16997.50.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
In-Reply-To: <1123241814.30015.5.camel@uluru.grenoble.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-08-09 at 10:43 -0700, Stephane Eranian wrote:
> Dann,
> 
> On Tue, Aug 09, 2005 at 10:40:16AM -0600, dann frazier wrote:
> > On Mon, 2005-08-08 at 10:17 +1000, Ian Wienand wrote:
> > > On Fri, Aug 05, 2005 at 01:36:54PM +0200, Stephane Eranian wrote:
> > > > I recently used an Itanium machine booted with a 2.6 Linux kernel.
> > > > The exact package is:
> > > >         kernel-image-2.6.11-1-mckinley-smp_2.6.11-6_ia64.deb
> > > > 
> > > > It does appear that this kernel is compiled without CONFIG_PALINFO
> > > > which means there is no /proc/pal/cpu* entries.
> > > 
> > > I filed this under
> > > 
> > > http://bugs.debian.org/cgi-bin/bugreport.cgi?bug21885
> > > 
> > > for the latest 2.6.12 packages which have the same thing.
> > > 
> > 
> > Note that CONFIG_PALINFO was set to m - most things in Debian kernels
> > are set to build as a module, if possible.
> > 
> 
> What's the value of having PALINFO as module?

(cc'ing debian-ia64, since this is really a debian issue not a kernel
one)

We don't examine all the bits of code that can be built as modules and
make a decision based on potential performance impact, security risks,
etc - its easier/more consistent to just build as a module if possible.

I don't know of any significant reason to leave palinfo as a module,
which is why I changed it :)  However, users who build their own kernels
may still build it as a module.  If they do, it'd be good if userspace
utilities either attempted to load it or complained that it wasn't
available.  (I've no idea if pfmon already does this or not)

> The firmware interface does not evolve very often.
> 
> If module is preferred then, some rc scripts should load it automatically
> somehow. 

If a user has a made a conscious choice to build it as a module, then it
probably means that they don't want the code loaded all the time.  In
such a situation, its probably better to load on demand or tell the user
to run modprobe themselves instead of auto-loading at boot.


