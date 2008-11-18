From: Robin Holt <holt@sgi.com>
Date: Tue, 18 Nov 2008 11:58:12 +0000
Subject: Re: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <20081118115812.GA8778@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 18, 2008 at 12:12:55AM -0700, Matthew Wilcox wrote:
> On Tue, Nov 18, 2008 at 08:06:53AM +0100, Petr Tesarik wrote:
> > Well, then let's make it a boot option (or a sysctl). The default must
> > be psr.ac = 1, but if the admin sees "unaligned access" messages and
> > knows that there is no way of getting a (timely) fix for that particular
> > production system, s/he should be able to turn them off.
> 
> Or how about ia64 does what every other Linux port does and turn off
> alignment warnings altogether?  Are they *particularly* expensive
> on Itanium?  I bet they aren't.

They are expensive enough that our customers complain.  Many of SGI's
customers are concerned about that last 1% of performance.

Having a way to quickly track down the customer's issue without having to
recreate their exact setup is helpful.  The last three kernel unaligned
access issues I can recall being reported by our customers were in the
IDE(1) and IPv4(2) areas.  Neither of these areas is SGI specific and
the three reports were customer workload specific.

I doubt we would have gotten these isolated without frustrating the
customer with cycles of try this, try this, oh and try this, now try
this kernel with different options and you need to rebuild all those
other things now too.

As it was, we merely took their console log and /proc/kallsyms and lined
up the source of the problem, scratched our heads for a bit, and isolated
the issue.

On a kernel modules note, we are seeing more and more of our customers
running stuff like panasys, lustre, etc which have external kernel
modules built either by the customer's support staff or other vendors.
Putting custom kernels on a site is becoming much more difficult.  If we
have a choice, please consider failing on the side of easily isolating
problems using a standard config.

I like Petr's suggestion of making it a sysctl/boot option with the
default being on.

Thanks,
Robin
