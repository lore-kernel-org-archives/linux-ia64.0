From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 May 2004 22:01:52 +0000
Subject: Re: Error handling bug in fsys_rt_sigprocmask
Message-Id: <16555.55632.823294.525092@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeekplxvah.fsf@sykes.suse.de>
In-Reply-To: <jeekplxvah.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 15 May 2004 22:57:58 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> When sigprocmask is called with an invalid first argument
  Andreas> it still modifies the signal mask of the process.

Indeed!  Thanks for catching this.

There already is a check for a bad HOW value, but it comes too late.
Your patch should be safe, but I'd like to fix it in a way that avoids
the second (now unnecessary check).  Let me see what I can come up with.

Thanks,

	--david
