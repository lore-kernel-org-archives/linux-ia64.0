From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Sep 2004 11:14:16 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <16712.9224.664624.671494@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 15 Sep 2004 06:04:51 -0500, Robin Holt <holt@sgi.com> said:

  Robin> That is exactly what it does, but I was wondering if there are other
  Robin> examples of drivers that do this.  If not, I would still like to
  Robin> push for doing the minimum necessary to keep from designing something
  Robin> that has no users.

There certainly have been requests for that in the past.  I think one
such request came from someone building cluster interconnects.  Also,
on some platforms it is helpful to map the AGP memory via
write-combine, though we fixed that particular issue for ia64 by
requiring write-back mapping support.

	--david
