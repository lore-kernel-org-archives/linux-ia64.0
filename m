From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Apr 2004 22:45:48 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <16526.58012.918419.971565@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Apr 2004 17:35:10 -0500, Mario Smarduch <cms063@email.mot.com> said:

  Mario> I guess the question wasn't so much about attribute aliasing
  Mario> but killing all intransit memory accesses and prefetch before
  Mario> its safe to change the TLB attribute to uncacheble, with
  Mario> assurance that all new mem refs/prefetch will come from
  Mario> memory. I appreciate all your inputs.

Yes, but that's the _easy_ part, so to speak.

To be honest, I would appreciate if you could outline your strategy to
avoid memory-attribute aliasing.  If only because it would give me a
warm-and-fuzzy feeling... ;-)

If this isn't something you're comfortable discussing on a public
list, a private mail would still be appreciated.

Thanks,

	--david
