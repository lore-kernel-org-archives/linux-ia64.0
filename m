From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 May 2004 22:49:57 +0000
Subject: Re: Error handling bug in fsys_rt_sigprocmask
Message-Id: <16555.58517.224849.871393@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeekplxvah.fsf@sykes.suse.de>
In-Reply-To: <jeekplxvah.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 May 2004 00:30:34 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> I did remove the second check.  But there is now an
  Andreas> additional bundle and I couldn't find any way to avoid
  Andreas> that.

Yeah, we may have to live with that.  It's not really a big deal (in
real life performance, it's not going to make any difference) but it
sure bugs me... ;-)

	--david
