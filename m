From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 30 Apr 2001 15:00:57 +0000
Subject: Re: [Linux-ia64] Cleanup include/asm-ia64/offsets.h - take 2
Message-Id: <marc-linux-ia64-105590693005490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005486@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005486@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 30 Apr 2001 14:57:45 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Second version of offsets.h cleanup patch.  Instead of
  Keith> changing lots of C code, define just the 11 IA64_*_OFFSET
  Keith> fields used by C in ptrace.h.

This is better, but still no cigar: print_tools knows all the symbols
that we might want to use in assembly or C code so I'd rather have it
generate all definitions.  I'm OK with using different definitions for
C and asm, _provided_ they have the same name and they are
automatically generated (to ensure consistency).  Ideally, I'd like
these #defines to live in the same place (header file).

	--david

