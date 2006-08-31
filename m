From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 31 Aug 2006 21:03:12 +0000
Subject: Re: [RFC][PATCH 0/9] generic PAGE_SIZE infrastructure (v4)
Message-Id: <1157058192.28577.33.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <17654.11889.933070.539839@cargo.ozlabs.ibm.com>
In-Reply-To: <17654.11889.933070.539839@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Mackerras <paulus@samba.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 2006-08-31 at 10:33 +1000, Paul Mackerras wrote:
> Dave Hansen writes:
> > Why am I doing this?  The OpenVZ beancounter patch hooks into the
> > alloc_thread_info() path, but only in two architectures.  It is silly
> > to patch each and every architecture when they all just do the same
> > thing.  This is the first step to have a single place in which to
> > do alloc_thread_info().  Oh, and this series removes about 300 lines
> > of code.
> 
> ... at the price of making the Kconfig help text more generic and
> therefore possibly confusing on some platforms.
> 
> I really don't see much value in doing all this.

The value for me is that this makes it much easier to add generic kernel
features.  There have been way too many times that I've made some
arch-independent change which required going and fixing up the *same*
code in every single architecture.

-- Dave

