From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Oct 2004 11:00:02 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <16750.23602.938088.880466@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Oct 2004 03:27:42 -0700, William Lee Irwin III <wli@holomorphy.com> said:

  wli> At some point in the comment, I wrote:
  William> Nice! I got reports that it would not be beneficial when I
  William> thought about going over this earlier. I suppose it's a
  William> small vindication of my methods to see the original
  William> objection contradicted here. =)

  wli> On Thu, Oct 14, 2004 at 12:44:59AM -0700, David Mosberger
  wli> wrote:
  >> What was the original comment relative to?  2.4 or 2.6?  In 2.6
  >> we lost the PTE quick-list, which I think is where the big
  >> overhead came from.  Right, Martin?

  wli> I don't recall much of the original comment, apart from that
  wli> someone said it had too much overhead. I may have presumed too
  wli> much when I presumed it was 2.6

OK, I don't think it was me, then.

I do suspect the quick-list would be faster than slab but the
difference is most likely in the noise and you can't argue with the
code-size reduction.

	--david
