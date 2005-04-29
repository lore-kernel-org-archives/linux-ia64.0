From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 15:28:50 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17010.21170.372148.828282@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 29 Apr 2005 08:19:20 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> On Fri, 29 Apr 2005, David Mosberger wrote:
  >> Let's not reintroduce in-line asm, please?

  Christoph> How do I do a nta store without inline asm?

You add a new intrinsic?

  Christoph> There is already lots of inline asm in spinlock.h.

spinlock.h is special because it performs non-standard calls to the
out-of-line spinlock contention-handler, but those places are enclosed
inside ASM_SUPPORTED.

	--david
