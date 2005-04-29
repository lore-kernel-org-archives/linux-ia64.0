From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 15:38:14 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <17010.21734.836498.607840@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 29 Apr 2005 08:30:27 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> So is my version of inline asm int the latest version
  Christoph> from yesterday.  There is an alternate version included
  Christoph> for !ASM_SUPPORTED in C which does not use an nta store.

Yes, but _if_ it's a good idea to use .nta with GCC, there is no
reason not to do the same with ICC.  Don't introduce unnecessary
divergence.

	--david
