From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 08 Dec 2004 18:33:24 +0000
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-Id: <200412081033.24367.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <200412080933.13396.jbarnes@engr.sgi.com> <Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wednesday, December 8, 2004 9:56 am, Christoph Lameter wrote:
> > And again, I'm not sure how important that is, maybe this approach will
> > work well in the majority of cases (obviously it's a big win in
> > faults/sec for your benchmark, but I wonder about subsequent references
> > from other CPUs to those pages).  You can look at
> > /sys/devices/platform/nodeN/meminfo to see where the pages are coming
> > from.
>
> The origin of the pages has not changed and the existing locality
> constraints are observed.
>
> A patch like this is important for applications that allocate and preset
> large amounts of memory on startup. It will drastically reduce the startup
> times.

Ok, that sounds good.  My case was probably a bit contrived, but I'm glad to 
see that you had already thought of it anyway.

Jesse
