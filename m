From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Feb 2005 20:03:22 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <16914.21898.79217.485076@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Feb 2005 13:59:45 -0600, Robin Holt <holt@sgi.com> said:

  >>  I certainly don't want to switch my machines to 4-levels.  There
  >> is zero need for that on the machines I use, so why pay the
  >> overhead of an extra level?

  Robin> I missed the why the extra level question.  That part is
  Robin> motivated by some large MPI jobs need a fourth level to get a
  Robin> large enough single mapping to cover their entire dataset.
  Robin> We have already tripped this limitation for a couple of our
  Robin> really large customers.

What I'm saying is that the default probably should stay at 3-levels.
Optimizing ia64 linux _just_ for "really large customers" would be
a bad direction to go in.


	--david
