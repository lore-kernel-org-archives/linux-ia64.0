From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 Jan 2004 19:16:50 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <16392.14498.812148.896936@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Bjorn> arch/ia64/Kconfig has accumulated a lot of cruft.  Here's a
  Bjorn> fairly straightforward 2.6 patch that corrects some typos,
  Bjorn> makes the style a little more consistent, and moves a couple
  Bjorn> items under the options they're dependent on (NR_CPUS goes
  Bjorn> under SMP, for instance).

  Bjorn> I'd really like to do a more extensive cleanup along the
  Bjorn> lines of Matthew Wilcox's patch:

  Bjorn>     http://linux.bkbits.net:8080/linux-2.5/cset@1.1296.78.7

  Bjorn> but I'm not sure how people feel about this during 2.6.

If it results in better/working help text and makes it easier to
configure a working kernel, it makes a lot of sense for 2.6.

I don't suppose I could interest you in making "allmodconfig" work on
ia64?  That's useful for testing purposes.  "allyesconfig" is probably
rather hopeless, because the resulting kernel would be too big to link
(and doesn't really make sense anyhow).

	--david
