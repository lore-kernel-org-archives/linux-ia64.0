From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 23:34:40 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <16442.36368.809480.85455@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Feb 2004 10:28:57 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> There are some 2.4 unwind patches in flight right now, once
  Keith> they are sorted I will move the kdb code from unwind.c to the
  Keith> kdb patch.

OK.  Note that I added an unwind.c fix recently.  There is at least
one more that needs to be backported from libunwind, but I want to
complete the libunwind-testing before doing that.

	--david
