From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Apr 2003 18:16:09 +0000
Subject: [Linux-ia64] Re: USB deadlock in v2.5.67
Message-Id: <marc-linux-ia64-105590723705567@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705560@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705560@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 18 Apr 2003 08:46:56 -0700, David Brownell <david-b@pacbell.net> said:

  David> Seems to be a different problem.  The patch below should
  David> resolve the keyboard problem -- just reorders two lines so
  David> the lock isn't held after the device's records get deleted,
  David> so the order is what it should always have been.

With the patch applied, I can now add/remove USB keyboards without
crashing the kernel.

Thanks!

	--david


