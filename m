From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Jan 2005 22:12:55 +0000
Subject: Re: anyone using Itanium B-step support?
Message-Id: <16889.26471.787124.55865@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
In-Reply-To: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Jan 2005 13:56:36 -0800, James E Wilson <wilson@specifixinc.com> said:

  Jim> However, rather than add more ITANIUM_BSTEP_SPECIFIC support to
  Jim> the kernel, I think it makes more sense to obsolete it and
  Jim> remove it.

I agree.  I happened to run into the warning just recently myself and
came to the same conclusion.

We probably still have some B-step Merceds in our lab but IIRC, it was
so rare to trigger the erratum that even on those boxes we can live
without the workaround just fine.  And it's not likely that anyone is
using such old prototype hardware for anything mission critical...

	--david
