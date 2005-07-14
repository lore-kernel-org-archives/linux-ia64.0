From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Thu, 14 Jul 2005 22:07:56 +0000
Subject: RE: autocompilation hosed?
Message-Id: <516F50407E01324991DD6D07B0531AD54FA830@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Very educational.  Thanks! 

> -----Original Message-----
> From: James E Wilson [mailto:wilson@tuliptree.org] 
> Sent: Thursday, July 14, 2005 4:02 PM
> To: Magenheimer, Dan (HP Labs Fort Collins)
> Cc: David Mosberger; Tony Luck; Ian Wienand; 
> linux-ia64@vger.kernel.org
> Subject: RE: autocompilation hosed?
> 
> On Thu, 2005-07-14 at 08:23, Magenheimer, Dan (HP Labs Fort Collins)
> wrote:
> > IIRC as of gcc3.2, attribute(packed) on ia64 meant roughly the
> > equivalent of specifying "generate the worst case possible
> > code even for things that are aligned".  Is that still the
> > case in gcc-4?
> 
> attribute((packed)) means that the type has alignment of 1 byte.  Thus
> we must use unaligned/bit-field load/store instructions.  Some targets
> have efficient instructions for that, some don't.  Some ports can use
> those instructions efficiently, some can't.
> 
> If a variable has greater alignment than its type, then we 
> can make use
> of that info to generate better code.  For instance, if a variable is
> allocated on the stack, then we know that it must have a certain
> alignment which may be greater than the alignment of its type.
> 
> You can also specify alignment by using __attribute__((aligned(X))).
> This can be added either to a type or to a variable, to specify an
> alignment greater than the default alignment for the type or variable.
> 
> Consider the attached testcase.  Compile with -O -S.  The code emitted
> for loading the variable "tmp" is good, because we know it has stack
> alignment.  The code for loading "bar" is bad, because it inherits
> 1-byte alignment from its type.  The code for loading "baz" is good,
> because we explicitly aligned it via an attribute.
> 
> We don't emit run time checks for alignment, so if something has a
> default alignment of 1 byte, but accidentally happens to have 8-byte
> alignment at runtime, then you still have to execute the slow code for
> it.
> 
