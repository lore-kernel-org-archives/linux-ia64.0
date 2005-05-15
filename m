From: "H. J. Lu" <hjl@lucon.org>
Date: Sun, 15 May 2005 20:33:52 +0000
Subject: Re: [Fwd: RE: elf header bits for page migration support......]
Message-Id: <20050515203352.GA18283@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4287A223.6010804@sgi.com>
In-Reply-To: <4287A223.6010804@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 15, 2005 at 01:08:21PM -0700, Jack Carter wrote:
> H. J. Lu wrote:
> 
> >On Sun, May 15, 2005 at 12:25:23PM -0700, Jack Carter wrote:
> > 
> >
> >>Ray Bryant wrote:
> >>
> >>   
> >>
> >>>2/2
> >>>
> >>>-------- Original Message --------
> >>>Subject: RE: elf header bits for page migration support......
> >>>Date: Fri, 13 May 2005 10:54:11 -0700
> >>>From: Luck, Tony <tony.luck@intel.com>
> >>>To: Ray Bryant <raybry@engr.sgi.com>
> >>>CC: <linux-ia64@vger.kernel.org>
> >>>
> >>>     
> >>>
> >>>>The alternative being suggested is to mark the elf header of object 
> >>>>files
> >>>>that should only have shared pages migrated, or that should not be 
> >>>>migrated
> >>>>(e. g. you don't want to migrate /bin/csh all the time.)
> >>>>       
> >>>>
> >>>No ... I'd like you to replicate shared pages (of /bin/bash ... I 
> >>>personally don't
> >>>care what happens to the pages of /bin/csh :-)
> >>>
> >>>     
> >>>
> >>>>Can I use some bits (I need 2) of p_flags of Elf64_Phdr for this 
> >>>>purpose?
> >>>>If so, which bits?
> >>>>
> >>>>If not which other fields can I use?
> >>>>       
> >>>>
> >>>I think H.J's suggestion of an extra section makes sense ... then you 
> >>>can go
> >>>wild with as many bits as you can dream up uses for, rather than 
> >>>constraining
> >>>yourself to squeeze into just 2 bits.
> >>>
> >>>-Tony
> >>>
> >>>
> >>>     
> >>>
> >>The fun part of  this is that if you introduce a new section and
> >>a new segment to point to it (only segments exist at load time)
> >>then you need to really muck with the bits because you will be
> >>growing the program header (segment table) and the section header
> >>as well as putting in a new section.
> >>
> >>If this information is to be used by rld it will need to be in some
> >>element of the bits that will be loadable and that means the new
> >>section needs to be either contiguous to a currently marked (PT_LOAD)
> >>segment with it's size increase due to the new section or the new section
> >>needs to be in it's own segment which means increasing the number
> >>of PT_LOAD segment entries.
> >>   
> >>
> >
> >I am not sure I understand what you are saying. As far as I know,
> >you don't need PT_LOAD for it. The dynamic linker will handle it in
> >program header just fine.
> >
> >
> >H.J.
> > 
> >
> I was trying to give a number of scenarios, one of which
> was that the new "section"  that was suggested, would be
> in it's own segment because that way it could be put at the
> end of the file and not perturb the rest of the executable.
> 
> In any case, the situation where you create a new area of data
> that rld needs to read has to be pointed to. Whether this is a
> new virtual segment or a new entry in the .dynamic section which
> by the way would probably be a better place for it.
> 
> In either case you will be growing things that may not have
> room to grow and that's where the problems start to happen.
> 
> This not to say it's impossible to do. I did this and much more
> with pixie on IRIX executables and dsos. It is just that there
> are a lot of gottchas to contend with and I'm not sure how you
> content with them in the open source world unless you get it
> firmly established in the ABI.

I didn't follow the whole thread very closely. But I can say

1. We should use a dummy segement instead of bits in ELF header.
2. ld.so has no problems with more than one PT_LOAD segment. Most
of binaries/DSOs have 2: one is readonly and executable, the other
is read and write.

If you want to modify ld.so to support your scheme, you can mark it
any PT_XXX you want. If you don't need/want to modify ld.so, you can
use a new PT_XXX and deal it in the user code. Ld.so will ignore the
unknow PT_XXX. The static linker can provide _start/_end symbols for
the new PT_XXX segment.


H.J.
