From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Feb 2005 18:07:07 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <16914.14923.166636.748463@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Feb 2005 06:02:13 -0600, Robin Holt <holt@sgi.com> said:

  Robin> For the 4-level case with 64k pages, what about just using
  Robin> 16k page tables?  That leaves us with 60 bits of addressable
  Robin> space which is fairly close to the full space.

You're kidding, right?  If getting "fairly close" to 64 bits was good
enough, there would be no point for 64KB pages.

	--david
