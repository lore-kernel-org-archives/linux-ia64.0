From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 22 Jun 2002 19:11:13 +0000
Subject: Re: [Linux-ia64] Compiler warnings.
Message-Id: <marc-linux-ia64-105590701905710@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905704@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905704@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 22 Jun 2002 11:53:40 +0200 (CEST), Steffen Persvold <sp@scali.com> said:

  Steffen> For some time I've been compiling applications and kernels
  Steffen> on IA64.  Sometimes the assembler gives me warnings about
  Steffen> "RAW dependencies" which makes me wonder about the quality
  Steffen> of the gcc compiler. Is this something that should be paid
  Steffen> attention to ?

I don't think you need to worry much here.  I keep a fairly close eye
on them and they tend to be all spurious messages due to the fact that
the assembler has an incomplete understanding of the code (and its
invariants).  The compiler should generate more directives to help the
assembler, but the code itself is generally correct.

I think gcc3.1 may be a bit better.  I only get 2 or 3 spurious
messages with it (apart from some that are due to inline asm, which
are harder to avoid).

	--david

