From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 09 May 2005 13:34:38 +0000
Subject: Re: MINSTATE_START_SAVE_MIN_PHYS looking very confused
Message-Id: <17023.26350.53037.896158@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17019.24133.738017.806202@napali.hpl.hp.com>
In-Reply-To: <17019.24133.738017.806202@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 6 May 2005 11:15:48 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> David Mosberger wrote:

  >>  However, the bigger issue to me is: given that we have a
  >> separate INIT stack, why bother distinguishing between an INIT
  >> that hits user-level vs. one that hits the kernel.  It's not
  >> possible to handle nested INITs anyhow, so why not just simplify
  >> that code to always switch to the INIT stack?

  Russ> I don't know the historical reason for the user/kernel
  Russ> differences in the code.  Maybe concerns about saving the
  Russ> right state information depending on the context?

I don't know the history there either.  At least in today's
environment with per-CPU INIT stacks, the code makes little sense,
though.

Keith, are your MCA cleanups close to being ready for prime-time?

	--david
