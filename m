From: Jack Steiner <steiner@sgi.com>
Date: Thu, 03 Jun 2004 02:38:01 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <20040603023800.GA14520@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 02, 2004 at 03:58:26PM -0500, John Hesterberg wrote:
> On Wed, Jun 02, 2004 at 10:33:39AM -0700, David Mosberger wrote:
> >   Christoph> Also the fast system call handler for sys_gettimeofday()
> >   Christoph> can only improve scalability if the ITC is the basis for
> >   Christoph> gettimeofday which is also never the case on Altix SN2
> >   Christoph> systems.
> > 
> > Does this really make a substantial difference?  My guess is no and,
> > if so, I'd rather not add any more #ifdefs.
> 
> It also only helps SN2 kernels and not generic kernels.
> I don't think this is they key part of the patch,
> so unless we see some compelling performance evidence,
> I'd agree it seems better to leave out the #ifdef.
> 
> John

What is the limitation in gettimeofday that prevents us from using a
fast system call handler to access the RTC on SN2. I realize that fsys.S
does not currently support this, but is there any fundamental
restriction that makes this impossible to add? 

If not, it would seem preferable to support SN2 rather add the #ifdefs.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


