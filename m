From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Fri, 06 Jan 2006 18:19:26 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <Pine.LNX.4.58.0601061017510.11324@shark.he.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
 <20060106174957.GF19769@parisc-linux.org> <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601060958110.17665@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, "Luck, Tony" <tony.luck@intel.com>, Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, 6 Jan 2006, Christoph Lameter wrote:

> On Fri, 6 Jan 2006, Matthew Wilcox wrote:
>
> > On Fri, Jan 06, 2006 at 09:45:20AM -0800, Luck, Tony wrote:
> > > I suppose that depends on your expectations from defconfig.  In my
> > > mind its the one that builds into a kernel that will boot and run
> > > on just about any box.  People who want to get a bit of extra performance
> > > will do the re-compilation to strip out the bits that they don't want
> > > and tune down limits that are set higher than they need.  I only
> >
> > You can use that argument to set the CPU limit low too -- since a kernel
> > with a CPU limit lower than the number of CPUs in the box will just ignore
> > the additional ones, people who want to get the additional performance
> > will tune limits that are set lower than they need ;-)
>
> The dicey thing in all of this is that the generic kernels will be used
> for the certification of applications. If the cpu limit is too low then
> applications will simply not be certified for these high processor counts.
> One may encounter problems if the app is then run with a higher processor
> count.

Do you equate a 'defconfig' kernel with a generic kernel?

I would expect certs to be done on vendor kernels, and as
Arjan has suggested, they will have their own configs,
not defconfig.

> > > There are quite a few >16 socket boxes out there, which will give
> > > you >64 cpus with Montecito ... so I don't think that the >64 cpu
> > > system is going to remain in the noise for long.
> >
> > I bet the number of 32-way+ boxes is lost in the noise compared to the
> > number of 1-, 2- and 4-way boxes sold.  Not that HP trust me with that
> > kind of sales data ;-)
>
> I think it is wrong to count the number of boxes. It is the number of
> users that is of major interest. These small boxes typically have one
> user. The larger boxes have whole communities working with them. The
> number of users of very large systems can potentially go into the 10
> thousands of users per installation.
>
> Moreover these larger boxes significantly impact the technological
> progress of humanity on the planet. These large boxes run hurricane
> simulations, do complex visualization necessary for bio technological
> advances, cosmological simulations, other physic stuff etc etc.

-- 
~Randy
