From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 May 2005 16:55:42 +0000
Subject: Re: flush_icache_range
Message-Id: <17047.20750.664960.404087@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 27 May 2005 18:45:19 +0200, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> I think we cannot use per-CPU data

Why?  I didn't think it was used until per-CPU is initialized.

  Zoltan> and there is no need for using per-CPU data, because fc.i a
  Zoltan> global operation, the stride size is a common global value
  Zoltan> for a give machine.

Ugh, where that is say that?  I can easily imagine a processor where
your argument would not hold true.

  Zoltan> Shall we use the system wide minimum stride ?

Yes, that would be fine, too.

  Zoltan> Why does not the SAL calculate it ? :-)

BTW: instead of calculating the min log2 stride, I'd just export the
actual stride.  No point doing that in flush_cache over and over
again.

	--david
