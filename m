From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 Feb 2004 21:29:48 +0000
Subject: Re: Important NaT-bit bug fix
Message-Id: <16446.25932.665235.203903@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16445.8557.274484.443935@napali.hpl.hp.com>
In-Reply-To: <16445.8557.274484.443935@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Feb 2004 21:16:15 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Wed, Feb 25, 2004 at 02:27:57PM -0800, David Mosberger
  Matthew> wrote:
  >> NOTE TO USERS/DISTRIBUTORS OF OLDER KERNELS: if you do NOT have
  >> the streamlined syscall-path patch applied in your kernel, then
  >> the patch needs to be modified such that in
  >> ia64_{get,put}_scratch_nat_bits() only the GET_BITS/PUT_BITS
  >> macros are changed (the rest should remain the same).  If in
  >> doubt, run the attached test program below.

  Matthew> Can you verify the following patch is what you meant by the
  Matthew> above?

Yes, that's exactly what I meant.  Of course, I'd still advise to
double-check by running the test program.

	--david
