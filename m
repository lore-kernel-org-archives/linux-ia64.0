From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Jul 2004 23:32:42 +0000
Subject: Re: clean up comments in arch/ia64/mm/init.c
Message-Id: <16629.49818.617626.773531@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F5AE74.10308@sgi.com>
In-Reply-To: <40F5AE74.10308@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 Jul 2004 17:06:44 -0500, Joshua Aas <josha@sgi.com> said:

  Joshua> While working on another patch in arch/ia64/mm/init.c, I
  Joshua> found a comment that doesn't seem to make sense and one that
  Joshua> just has a minor whitespace problem. The problem with the
  Joshua> comment after setup_gate() is that boot memory seems to have
  Joshua> already been freed a few lines earlier in the function and
  Joshua> nothing else happens in mem_init() after the call to
  Joshua> setup_gate() (unless compiling for IA32).  If there aren't
  Joshua> any objections, it would be nice to have this patch applied
  Joshua> so as not to confuse people in the future.

-EPATCHDOESNTAPPLY.

I think your mailer mangles whitespace.  Try sending it as a MIME
attachement.

	--david
