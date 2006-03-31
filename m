From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 21:15:17 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603311313530.8003@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603311940.k2VJeRg05420@unix-os.sc.intel.com>
In-Reply-To: <200603311940.k2VJeRg05420@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 31 Mar 2006, Chen, Kenneth W wrote:

> > They are not. They provide equivalent barrier when performed
> > before/after a clear_bit, there is a big difference.
> 
> Just to give another blunt brutal example, what is said here is equivalent
> to say kernel requires:
> 
>    <end of critical section>
>    smp_mb_before_spin_unlock
>    spin_unlock
> 
> Because it is undesirable to have spin_unlock to leak into the critical
> Section and allow critical section to leak after spin_unlock.  This is
> just plain brain dead.

I think we could say that lock semantics are different from barriers. They 
are more like acquire and release on IA64. The problem with smb_mb_*** is 
that the coder *explicitly* requested a barrier operation and we do not 
give it to him.

