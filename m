From: Jack Carter <jcarter@sgi.com>
Date: Sun, 15 May 2005 19:25:23 +0000
Subject: Re: [Fwd: RE: elf header bits for page migration support......]
Message-Id: <4287A223.6010804@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ray Bryant wrote:

> 2/2
>
> -------- Original Message --------
> Subject: RE: elf header bits for page migration support......
> Date: Fri, 13 May 2005 10:54:11 -0700
> From: Luck, Tony <tony.luck@intel.com>
> To: Ray Bryant <raybry@engr.sgi.com>
> CC: <linux-ia64@vger.kernel.org>
>
>> The alternative being suggested is to mark the elf header of object 
>> files
>> that should only have shared pages migrated, or that should not be 
>> migrated
>> (e. g. you don't want to migrate /bin/csh all the time.)
>
>
> No ... I'd like you to replicate shared pages (of /bin/bash ... I 
> personally don't
> care what happens to the pages of /bin/csh :-)
>
>> Can I use some bits (I need 2) of p_flags of Elf64_Phdr for this 
>> purpose?
>> If so, which bits?
>>
>> If not which other fields can I use?
>
>
> I think H.J's suggestion of an extra section makes sense ... then you 
> can go
> wild with as many bits as you can dream up uses for, rather than 
> constraining
> yourself to squeeze into just 2 bits.
>
> -Tony
>
>
The fun part of  this is that if you introduce a new section and
a new segment to point to it (only segments exist at load time)
then you need to really muck with the bits because you will be
growing the program header (segment table) and the section header
as well as putting in a new section.

If this information is to be used by rld it will need to be in some
element of the bits that will be loadable and that means the new
section needs to be either contiguous to a currently marked (PT_LOAD)
segment with it's size increase due to the new section or the new section
needs to be in it's own segment which means increasing the number
of PT_LOAD segment entries.

In either case whether you have a virtual segment pointing to the
new section (remember rld can't see it if it isn't pointed to from
somewhere in a loadable segment) or a new loadable segment,
you will need to grow the program header (segment table) and there
may not be enough space for that without overlapping other elements
of the executable.

Of course this doesn't go into the subtleties like whether or not
linux kernels and rlds can handle more than 2 loadable segments
and if they will melt down when encountering new unknown virtual
segments.

You could move the program header and grow it, but some kernels
and rlds assume that the program header is in the text segment right
after the ELF header. They shouldn't, but they do.

None of this is not very hard if we do it at link time. It gets
messy only after because much of the relocation information
is lost and people seem to like to be clever in their knowlege
of where things begin and end and write code based on those
assumptions whether or not those positions have been garaunteed
by the ABI.

Just wanted to add the joy of sunshine to this discussion.

Jack

