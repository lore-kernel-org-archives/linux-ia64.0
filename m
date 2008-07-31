From: Simon Horman <horms@verge.net.au>
Date: Thu, 31 Jul 2008 00:48:43 +0000
Subject: Re: [patch 3/3] kdump: use is_vmcore_usable() and
Message-Id: <20080731004842.GA1657@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729081235.293361145@vergenet.net> <20080729081629.715923799@vergenet.net> <20080730130131.GB16373@redhat.com>
In-Reply-To: <20080730130131.GB16373@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vivek Goyal <vgoyal@redhat.com>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 30, 2008 at 09:01:31AM -0400, Vivek Goyal wrote:
> On Tue, Jul 29, 2008 at 06:12:38PM +1000, Simon Horman wrote:
> > After recent changes setting elfcorehdr_addr to ELFCORE_ADDR_MAX
> > will cause is_kdump_kernel() to return 0 when it should return 1.
> > Instead use vmcore_unusable(), which has been added for this purpose.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > Index: linux-2.6/arch/ia64/kernel/setup.c
> > =================================> > --- linux-2.6.orig/arch/ia64/kernel/setup.c	2008-07-29 17:27:43.000000000 +1000
> > +++ linux-2.6/arch/ia64/kernel/setup.c	2008-07-29 17:50:50.000000000 +1000
> > @@ -502,11 +502,11 @@ int __init reserve_elfcorehdr(unsigned l
> >  	 * to work properly.
> >  	 */
> >  
> > -	if (elfcorehdr_addr >= ELFCORE_ADDR_MAX)
> > +	if (!is_vmcore_usable())
> >  		return -EINVAL;
> >  
> >  	if ((length = vmcore_find_descriptor_size(elfcorehdr_addr)) = 0) {
> > -		elfcorehdr_addr = ELFCORE_ADDR_MAX;
> > +		vmcore_unusable();
> >  		return -EINVAL;
> >  	}
> >  
> 
> Hi Simon,
> 
> I had a question. I am not very sure what reserve_elfcorehdr is doing
> but doing something similar to reserving some memory area where
> elfcoreheaders are.

Yes, that is my understanding of what it does.

> I see that reserve_elfcorehdr is under CONFIG_PROC_VMCORE. Will it work
> if CONFIG_PROC_VMCORE=n and somebody wants to use /dev/oldmem?
> Or reserve_elfcorehdr should be under CONFIG_CRASH_DUMP?

I'm not that familiar with /dev/oldmem, but as far as I can see,
read_oldmem doesn't do anything with ELF headers, so reservation
by vmcore_find_descriptor_size() should not be neccessary.

On a related note, I wonder if some consolitation of
read_oldmem() (used by /dev/oldmem) and read_from_oldmem()
(used by /proc/vmcore) can be done.

-- 
Horms

