From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 May 2004 20:46:41 +0000
Subject: Re: [PATCH] don't udelay() in sn_mmiob
Message-Id: <16566.21425.129528.123469@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405261749.02254.jbarnes@engr.sgi.com>
In-Reply-To: <200405261749.02254.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 May 2004 17:49:02 -0400, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> sn_mmiob is a lightweight way to ensure PCI write ordering,
  Jesse> intended to be used as an alternative to doing a PIO read.
  Jesse> Unfortunately, with the udelay() in there, it ends up being
  Jesse> slower than a PCI read on small configurations, so remove it.

Wouldn't you want at least a cpu_relax() in that loop?

	--david
