From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 30 Apr 2001 22:31:04 +0000
Subject: Re: [Linux-ia64] Cleanup include/asm-ia64/offsets.h - take 2
Message-Id: <marc-linux-ia64-105590693005491@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 30 Apr 2001 08:00:57 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Mon, 30 Apr 2001 14:57:45 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> Second version of offsets.h cleanup patch.  Instead of
>  Keith> changing lots of C code, define just the 11 IA64_*_OFFSET
>  Keith> fields used by C in ptrace.h.
>
>This is better, but still no cigar: print_tools knows all the symbols
>that we might want to use in assembly or C code so I'd rather have it
>generate all definitions.  I'm OK with using different definitions for
>C and asm, _provided_ they have the same name and they are
>automatically generated (to ensure consistency).  Ideally, I'd like
>these #defines to live in the same place (header file).

The kernel build system copes reasonably well with shipped files, using
implicit dependencies which take config changes into account.  kbuild
has problems with generated files because they require explicit
dependency information to ensure that they are built before any file
that uses a generated file is read.

A single version of offsets.h is a problem because it needs to be
included in several .c files, each of those .c files requires an
explicit dependency on the build of offsets.h.  Because offsets.h
depends on config changes, on header changes and possibly on command
line parameters to make, it is impractible to work out if any of the
inputs to offsets.h have changed.  Instead it must be generated every
time and checked to see if has changed.  That is acceptable for 5
assembler files, it is not acceptable to regenerate offsets.h for every
.c file that might include offsets.h.

There are only 11 IA64_*_OFFSET fields used by .c files.  The cleanest
solution is to define those 11 fields in the headers that also define
the structure, which is what I did.  There is no justification for
complicating the kernel build system any more than it already is, just
to avoid 11 #defines.


