From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 01 Aug 2002 04:10:40 +0000
Subject: Re: [Linux-ia64] [patch] Assign __gp to middle of short data sections
Message-Id: <marc-linux-ia64-105590701905872@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 01 Aug 2002 13:17:25 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> I was getting '__gp does not cover short data segment'.
  Keith> arch/ia64/vmlinus.lds.S assigns __gp well away from the short
  Keith> data sections, for no good reason that I can see.  A kernel
  Keith> with more than 2^21 bytes between __gp and the end of sbss
  Keith> cannot link.

  Keith> This patch (against 2.4.18) puts __gp right in the middle of
  Keith> the short data sections.

Umh, the got must be covered by the __gp too!

The real problem that you were seeing is that the (old) linker script
aligned __gp, but not the section it was pointing to.  If the previous
section ended on an address that was not 16-byte aligned, this would
have the effect of putting the first word in the got out of reach.  I
fixed this bug a while ago (about two 2.4.18 patches ago, IIRC).  The
corrected version reads like this:

  . = ALIGN(16);
  __gp = . + 0x200000;	/* gp must be 16-byte aligned for exc. table */

  Keith> The comment 'gp must be 16-byte
  Keith> aligned for exc. table' puzzles me, AFAICT the exception
  Keith> tables are not accessed via gp.

The addresses in the exception table are currently gp-relative (so
they fit in 32 bits), with the least-significant four bits reserved to
encode extra info (such as slot number).  If someone cares, this table
probably could be converted to use IP-relative addresses, in which
case this constraint could be dropped.

	--david

