From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Mar 2003 21:52:53 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64 mca rendezvous
Message-Id: <marc-linux-ia64-105590723705304@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 22 Mar 2003 14:57:58 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> We are not setting the 'always rendezvous for mca' flag.  kdb
  Keith> needs it set to get decent mca debugging on all cpus but I do
  Keith> not want kdb to change sal behaviour.  Since we do not
  Keith> recover from mca without a debugger, I see no reason why this
  Keith> flag should not be on for all kernels.

  Keith> The rendezvous timeout was set to 100 * HZ, but SAL expects
  Keith> the timeout to be in milliseconds, HZ may not be 1
  Keith> millisecond.  The patch makes the timeout an explicit 20
  Keith> seconds, semi-arbitrary value.

Applied for 2.5.

Thanks,

	--david

