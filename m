From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 May 2003 04:10:34 +0000
Subject: Re: [Linux-ia64] High fpu register corruption (PATCH)
Message-Id: <marc-linux-ia64-105590723706066@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705679@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705679@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 May 2003 21:53:13 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> I'm comparing 2.4 (including your patch) and David's current
  Bjorn> 2.5 BK tree.  I'd like to keep them as close as possible, but
  Bjorn> I see several clearly gratuitous differences (like
  Bjorn> whitespace) and some that aren't obvious to me.

  Bjorn> arch/ia64/kernel/ptrace.c: 2.4 calls ia64_drop_fpu() from
  Bjorn> ia64_sync_fph().  2.5 calls ia64_drop_fpu() from
  Bjorn> ia64_flush_fph().  Is there a reason for the difference?

Which tree are you looking at? to-linus-2.5 or linux-ia64-2.5?  I have
gotten quite lazy in pushing the former, since the only reason now to
do a push there is when I want Linus to do a pull.  The latter tree is
much more active.

	--david

