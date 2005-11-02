From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Nov 2005 17:16:11 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051102171611.GB23600@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I think I will hold off on doing this for now.  I think it is better done
as a seperate patch.  I will happily try to tackle this once the direction
of 4-level PTDs is set, but until then, I think I want to skip this.

Thanks,
Robin

On Fri, Oct 28, 2005 at 03:19:57PM +1000, Ian Wienand wrote:
> Something I would really like is a small abstraction of some of the
> page table access macros to make it a little clearer as to what is
> happening.  Besides which using '-3' in many places assumes the size
> of entries (of particular interest is the size of a PTE, which you
> might want to increase; I can't see why you would increase the upper
> levels).
> 
> I'd like to see something like this go in, or possibly wrap it up with
> your changes.  I also tried to make comments a little more explicit.
