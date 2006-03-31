From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 31 Mar 2006 07:34:48 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <442CDB98.80803@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310614.k2V6Ehg30012@unix-os.sc.intel.com>
In-Reply-To: <200603310614.k2V6Ehg30012@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> Nick Piggin wrote on Thursday, March 30, 2006 6:53 PM

>>The memory ordering that above combination should produce is a
>>Linux style smp_mb before the clear_bit. Not a release.
> 
> 
> Whoever designed the smp_mb_before/after_* clearly understand the
> difference between a bidirectional smp_mb() and a one-way memory
> ordering.  If smp_mb_before/after are equivalent to smp_mb, what's
> the point of introducing another interface?
> 

They are not. They provide equivalent barrier when performed
before/after a clear_bit, there is a big difference.

You guys (ia64) are the ones who want to introduce a new
interface, because you think conforming to the kernel's current
interfaces will be too costly. I simply suggested a way you
could do this that would have a chance of being merged.

If you want to change the semantics of smp_mb__*, then good
luck auditing all that well documented code that uses it.
I just happen to think your best bet is to stick with the
obvious full barrier semantics (which is what other
architectures, eg powerpc do), and introduce something new
if you want more performance.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
