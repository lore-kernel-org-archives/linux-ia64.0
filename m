From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 May 2003 00:29:30 +0000
Subject: Re: [Linux-ia64] Re: new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705722@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705722@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 May 2003 09:38:15 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Not just exponential backoff.  Also kdb, checking for hung
  Keith> spinlocks, calculating spinlock hold time plus any other
  Keith> debugging or performance monitoring code that we can add now
  Keith> that there is only one copy of the spinlock contention code.
  Keith> They all need additional and separate sets of registers.

Why do they need separate sets of registers?

Please show some real code that justifies the number of registers you
want to add.  The cost may be small, but it's certainly not zero.

	--david

