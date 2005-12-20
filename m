From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 20 Dec 2005 18:05:11 +0000
Subject: Re: quick overview of the perfmon2 interface
Message-Id: <12c511ca0512201005k4d499b57v724815258f80322@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com>
	 <20051220025156.a86b418f.akpm@osdl.org>
In-Reply-To: <20051220025156.a86b418f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: eranian@hpl.hp.com, linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net

> >       The interface also supports automatic randomization of the reset value
> >       for a PMD after an overflow.
>
> Why would one want to randomise the PMD after an overflow?

To get better data.  Using a constant reload value may keep measuring the
same spot in the application if you are using a sample frequency that
matches some repeat pattern in the application (and Murphy's law says
that you'll hit this a lot).

-Tony
