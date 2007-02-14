From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Wed, 14 Feb 2007 11:46:49 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <aec7e5c30702140346k689a418aoc43143fc592ab757@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 2/14/07, Zou, Nanhai <nanhai.zou@intel.com> wrote:
> > From: Magnus Damm [mailto:magnus.damm@gmail.com]
> > On 2/8/07, Vivek Goyal <vgoyal@in.ibm.com> wrote:
> > > I think we should not remove this check because even to parse the info
> > > passed in ELF headers, you need to first read the ELF headers from crashed
> > > kernel's memory. So if some programming error has passed wrong location of
> > > ELF headers (elfcoreheader= invalid location) then we might try reading the
> > > elf header from a non-existing physical page frame.
> >
> > Are you saying that the ELF header is located in the memory space of
> > the first kernel?
> >
> > The way I read the code the ELF header is put into the reserved memory
> > space for the secondary kernel. At least on ia64 that is true, and I
> > think the same goes for i386.
> >
> > And the fact that the ELF header is put in to the secondary kernel
> > brings me memory setup problems on ia64.
> >
> > Basically the ELF header is marked as EFI_UNUSABLE_MEMORY by the EFI
> > mangling code in purgatory. The secondary kernel detects this while
> > parsing the EFI tables and refuses to use/map the other memory present
> > in the same 16M granule. And in my case the initramfs happens to be
> > located in the same granule... boom! No good. =)
> >
> > So I'm wondering about the reason why we put the ELF header in the
> > secondary kernel. Can't we just put it in the first kernel and be done
> > with it? We still point it out using the kernel command line, don't
> > we?
>
>   My first design is that putting data in second kernel is easy and safer. We could put it in the first kernel if we provide an interface to reserve this area at the time of kexec -p so that nobody will touch it even at the time of crash.

Maybe that's a good idea. But that would make ia64 a special case and
I'd like to avoid that as  long as possible.

>   Align that buffer to 16M will solve the issue but that seems to be a waste of the useful memory?

Right. We could require one granule per segment or something, but at
load time we don't really know if the secondary kernel is using 16M or
64M granules. A safe bet would be to always use 64M, but that would
require us to use quite a lot of memory for the secondary kernel.

>   Another way is append this elf header to command line in purgatory, like we append the ummy efi function, maybe this is too hacky?

Hm. I think that sounds a bit too hackish. =)

What about the option of marking the ELF headers as EFI_LOADER_DATA
and let the secondary kernel allocate new space and copy the data
early during boot?

Thanks!

/ magnus
