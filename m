From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 May 2003 19:34:49 +0000
Subject: Re: [Linux-ia64] janitor patch for _PAGE_SIZE_*
Message-Id: <marc-linux-ia64-105590723705645@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705627@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705627@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 2 May 2003 15:45:09 +1000, Martin Pool <mbp@samba.org> said:

  Martin> I was looking at the ia64 port and noticed the _PAGE_SIZE*
  Martin> definitions are inconsistent with other uses of this term in
  Martin> the kernel.

  Martin> This patch just renames them to _PAGE_SHIFT.  It only touches ia64
  Martin> code.

I'm not going to apply this one for the following reason: those macros
actually are page-size _codes_ for the PTEs.  Yes, the codes happen to
be equal to the log2() of the page-size, but this isn't necessarily
so.  It's probably unlikely this will ever change, but unless it's
nailed down by the architecture somewhere (I don't think it is), I'd
like to leave that distinction.  Subtle as it may be.

	--david

