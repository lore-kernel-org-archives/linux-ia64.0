From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 23:09:38 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <16442.34866.503015.101297@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Feb 2004 13:47:40 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  >>> Sorry, but I just don't see why there should be KDB-stuff in unwind.c
  >>> when KDB isn't part of the official Linux tree.

  Keith> You took the same patch for unwind.c in the 2.4 kernel.

  David> Well, that was 2.4.  I don't recall the details, but like I said, I
  David> don't see a good reason for including KDB patches in the default
  David> kernel when KDB isn't part of it.

In case it wasn't clear: if you want things to be in sync, I'd rather
ask Bjorn to remove the KDB portions in unwind.c.

	--david
