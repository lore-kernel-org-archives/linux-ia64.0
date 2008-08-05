From: Simon Horman <horms@verge.net.au>
Date: Tue, 05 Aug 2008 07:19:36 +0000
Subject: Re: [patch 3/3] kdump: use is_vmcore_usable() and
Message-Id: <20080805071934.GA7824@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729081235.293361145@vergenet.net> <20080729081629.715923799@vergenet.net> <20080730130131.GB16373@redhat.com> <20080731004842.GA1657@verge.net.au> <20080731132152.GB26782@redhat.com> <20080801040759.GG27241@verge.net.au>
In-Reply-To: <20080801040759.GG27241@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vivek Goyal <vgoyal@redhat.com>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 01, 2008 at 02:08:01PM +1000, Simon Horman wrote:
> On Thu, Jul 31, 2008 at 09:21:52AM -0400, Vivek Goyal wrote:
> > On Thu, Jul 31, 2008 at 10:48:43AM +1000, Simon Horman wrote:
> > > On Wed, Jul 30, 2008 at 09:01:31AM -0400, Vivek Goyal wrote:
> > > > On Tue, Jul 29, 2008 at 06:12:38PM +1000, Simon Horman wrote:
> > > > > After recent changes setting elfcorehdr_addr to ELFCORE_ADDR_MAX
> > > > > will cause is_kdump_kernel() to return 0 when it should return 1.
> > > > > Instead use vmcore_unusable(), which has been added for this purpose.
> > > > > 
> > > > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > > > 
> > > > > Index: linux-2.6/arch/ia64/kernel/setup.c
> > > > > =================================> > > > > --- linux-2.6.orig/arch/ia64/kernel/setup.c	2008-07-29 17:27:43.000000000 +1000
> > > > > +++ linux-2.6/arch/ia64/kernel/setup.c	2008-07-29 17:50:50.000000000 +1000
> > > > > @@ -502,11 +502,11 @@ int __init reserve_elfcorehdr(unsigned l
> > > > >  	 * to work properly.
> > > > >  	 */
> > > > >  
> > > > > -	if (elfcorehdr_addr >= ELFCORE_ADDR_MAX)
> > > > > +	if (!is_vmcore_usable())
> > > > >  		return -EINVAL;
> > > > >  
> > > > >  	if ((length = vmcore_find_descriptor_size(elfcorehdr_addr)) = 0) {
> > > > > -		elfcorehdr_addr = ELFCORE_ADDR_MAX;
> > > > > +		vmcore_unusable();
> > > > >  		return -EINVAL;
> > > > >  	}
> > > > >  
> > > > 
> > > > Hi Simon,
> > > > 
> > > > I had a question. I am not very sure what reserve_elfcorehdr is doing
> > > > but doing something similar to reserving some memory area where
> > > > elfcoreheaders are.
> > > 
> > > Yes, that is my understanding of what it does.
> > > 
> > 
> > In x86 we never have to reserve that elf header area as we know that
> > booting kernel will never overwrite in that area. (Previous kernel has
> > modified the memory map in such a way so that elf header memory area
> > is not even part of memory range second kernel can use. 
> > 
> > Any idea, why do we need to reserve this area in IA64.
> > 
> > > > I see that reserve_elfcorehdr is under CONFIG_PROC_VMCORE. Will it work
> > > > if CONFIG_PROC_VMCORE=n and somebody wants to use /dev/oldmem?
> > > > Or reserve_elfcorehdr should be under CONFIG_CRASH_DUMP?
> > > 
> > > I'm not that familiar with /dev/oldmem, but as far as I can see,
> > > read_oldmem doesn't do anything with ELF headers, so reservation
> > > by vmcore_find_descriptor_size() should not be neccessary.
> > > 
> > 
> > /dev/oldmem does not directly touch elfcorehdr. But it indirectly does in
> > the sense that it is reading all the previous kernel's memory and dumping
> > it to disk. That would include elfcorehdrs also.
> > 
> > Now if we need to do some kind of reservation for elf headers so that
> > fs/vmcore.c code can read it, then same should be true for /dev/oldmem
> > code also. Otherwise reserving elfcorehdr code should be redundant.
> > 
> > That's why I raised the question that why do we need to reserve that area
> > in case of IA64. And if there is a genuine reason then probably that
> > reason will hold valid in case of /dev/oldmem also and we might have
> > to put is_vmcore_usable() definition also under CONFIG_CRASH_DUMP.
> 
> Hi Vivek,
> 
> yes, I do think that the problem is a bit deeper than my original response.
> I'll investigate this further.

Hi Vivek,

sorry for not getting back to you sooner. I think that the short answer
to this question is that the code should be protected by
CONFIG_CRASH_DUMP instead of CONFIG_PROC_VMCORE. This should ensure
that the memory where the elfheader lies is not used by the crashkernel,
regardless of if CONFIG_PROC_VMCORE is in effect or not.

I will make a patch for this ASAP.
