From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 May 2003 18:59:39 +0000
Subject: Re: [Linux-ia64] [PATCH] fix timer interrupts getting lost
Message-Id: <marc-linux-ia64-105590723705644@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705596@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705596@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 23 Apr 2003 22:16:43 -0600, Alex Williamson <alex_williamson@attbi.com> said:

  Alex> This patch fixes the issue of some CPUs not showing timer
  Alex> interrupts going off.  Seems during the process of sync'ing
  Alex> the itc, we jumped over the next timer value.  This patch is
  Alex> against 2.5.67 + ia64.  I haven't seen the problem on 2.4, but
  Alex> a quick looks seems like it's potentially an issue there too.
  Alex> Thanks,

Good catch.  I applied this patch now.

The reason it started to show up on 2.5 now is mostly likely because I
had to move the ITC syncing to a point where interrupts are enabled.

	--david

