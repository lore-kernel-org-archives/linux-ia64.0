From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Feb 2005 20:26:23 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <16914.23279.945036.75893@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Feb 2005 12:15:19 -0800, William Lee Irwin III <wli@holomorphy.com> said:

  >> I certainly don't want to switch my machines to 4-levels.  There
  >> is zero need for that on the machines I use, so why pay the
  >> overhead of an extra level?  BTW: why do you want 4-level/16KB
  >> over 3-level/64KB?

  William> It may be worth noticing that things like fault latency and
  William> small writes degrade with increased pagesize, though I seem
  William> to recall hearing that this effect was less pronounced or
  William> did not set in at 64KB on ia64.

Certainly, but fault-latency also increase with the number of levels.
And there are real customers who care about page-fault latency a lot
which run apps where the probability of the page-table entries being
in the cache is close to zero...

I'm not advocating one over the other --- I'm pro choice... ;-)

	--david
