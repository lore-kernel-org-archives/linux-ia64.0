From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 01 Aug 2002 06:00:39 +0000
Subject: Re: [Linux-ia64] [patch] Assign __gp to middle of short data sections
Message-Id: <marc-linux-ia64-105590701905874@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Jul 2002 21:10:40 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Thu, 01 Aug 2002 13:17:25 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> I was getting '__gp does not cover short data segment'.
>  Keith> arch/ia64/vmlinus.lds.S assigns __gp well away from the short
>  Keith> data sections, for no good reason that I can see.  A kernel
>  Keith> with more than 2^21 bytes between __gp and the end of sbss
>  Keith> cannot link.
>
>  Keith> This patch (against 2.4.18) puts __gp right in the middle of
>  Keith> the short data sections.
>
>Umh, the got must be covered by the __gp too!

@gprel() maps to instruction immediate22 which is a signed offset.  My
patch puts gp in the middle of the set { got, sdata, sbss }.  ld is
quite happy with that, it even tries to put gp in the middle of these
sections if you have not already defined __gp.

>The real problem that you were seeing is that the (old) linker script
>aligned __gp, but not the section it was pointing to.  If the previous
>section ended on an address that was not 16-byte aligned, this would
>have the effect of putting the first word in the got out of reach.  I
>fixed this bug a while ago (about two 2.4.18 patches ago, IIRC).  The
>corrected version reads like this:
>
>  . = ALIGN(16);
>  __gp = . + 0x200000;	/* gp must be 16-byte aligned for exc. table */

I tried that, same error, it is definitely a size problem.  With my
build, _data + 0x200000 (where __gp used to be) is e0000000049b7490,
got starts at e000000004ced170, a difference from gp of 0x335ce0 bytes.
imm22 can only do +/- 0x200000.

>  Keith> The comment 'gp must be 16-byte
>  Keith> aligned for exc. table' puzzles me, AFAICT the exception
>  Keith> tables are not accessed via gp.
>
>The addresses in the exception table are currently gp-relative (so
>they fit in 32 bits), with the least-significant four bits reserved to
>encode extra info (such as slot number).  If someone cares, this table
>probably could be converted to use IP-relative addresses, in which
>case this constraint could be dropped.

In that case __ex_table should be moved to the same place as got,
sdata, sbss.  As it stands, the gprel data is split with all the read
only data plus init code between them.  ld does not detect errors for
gprel in ex_table because __ex_table is not marked as short.


