From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 03 Mar 2004 22:45:11 +0000
Subject: RE: [PATCH] more robust halt_light
Message-Id: <16454.24567.225535.582397@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 03 Mar 2004 14:08:00 -0700, Alex Williamson <alex.williamson@hp.com> said:

  Alex> I was curious about that myself, but I thought I remembered
  Alex> from Stephane that the perf counters didn't really recover
  Alex> from a PAL_HALT_LIGHT on McKinley.  If that's not the case,
  Alex> maybe we can move the PAL check into perfmon code, and it can
  Alex> selectively disable it as it needs via the disable_hlt API.  I
  Alex> assume there are some cases were perfmon wouldn't need to
  Alex> disable halt_light on working PAL, so the rev check might not
  Alex> go away.

Can we get rid of the CONFIG option too?  Or do folks who care (too?)
much about wake-up latency prefer to turn off a CONFIG option over
booting with nohlt?

	--david
