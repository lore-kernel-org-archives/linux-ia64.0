From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 16:01:14 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17010.23114.560223.6706@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 29 Apr 2005 16:51:53 +0100, Christoph Hellwig <hch@infradead.org> said:

  Christoph> On Fri, Apr 29, 2005 at 08:48:43AM -0700, David Mosberger wrote:
  >> >> Yes, but _if_ it's a good idea to use .nta with GCC, there is no
  >> >> reason not to do the same with ICC.  Don't introduce unnecessary
  >> >> divergence.

  Christoph> The same situation of .nta only for GCC already exists
  Christoph> for regular spinlocks as a result of my nta unlock patch
  Christoph> that I posted a week or so ago.

  >> And that's an argument to make the situation worse?  How about
  >> cleaning up the previous patch instead?

  Christoph> I don't think it's fair to expect contributors to fix up
  Christoph> ifdef'ed bits for a propritary compiler.  If HP and Intel
  Christoph> care about it they can add the features for icc later.

I don't think this is about proprietary vs non-proprietary.  It's
about whether the code is clean.  I'd _love_ to get rid of inline asm
in the future when GCC supports intrinsics since that could lead to
significantly improved code.

(And no, I don't expect Chris to necessarily fix up the ICC bits, though
 a reasonable best-effort wouldn't take much time.)

	--david
