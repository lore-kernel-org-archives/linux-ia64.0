From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 31 Aug 2006 17:38:30 +0000
Subject: Re: [RFC][PATCH 4/9] ia64 generic PAGE_SIZE
Message-Id: <1157045910.31295.23.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221607.1DB81421@localhost.localdomain>
	 <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2006-08-30 at 16:57 -0700, Christoph Lameter wrote:
> On Wed, 30 Aug 2006, Dave Hansen wrote:
> 
> > @@ -64,11 +64,11 @@
> >   * Base-2 logarithm of number of pages to allocate per task structure
> >   * (including register backing store and memory stack):
> >   */
> > -#if defined(CONFIG_IA64_PAGE_SIZE_4KB)
> > +#if defined(CONFIG_PAGE_SIZE_4KB)
> >  # define KERNEL_STACK_SIZE_ORDER		3
> > -#elif defined(CONFIG_IA64_PAGE_SIZE_8KB)
> > +#elif defined(CONFIG_PAGE_SIZE_8KB)
> >  # define KERNEL_STACK_SIZE_ORDER		2
> > -#elif defined(CONFIG_IA64_PAGE_SIZE_16KB)
> > +#elif defined(CONFIG_PAGE_SIZE_16KB)
> >  # define KERNEL_STACK_SIZE_ORDER		1
> >  #else
> >  # define KERNEL_STACK_SIZE_ORDER		0
> 
> Could we replace these lines with
> 
> #define KERNEL_STACK_SIZE_ORDER (max(0, 15 - PAGE_SHIFT)) 

My next series will be to clean up stack size handling.  Do you mind if
it waits until then?

-- Dave

