From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 23 Apr 2003 18:02:59 +0000
Subject: [Linux-ia64] Re: gettimeoffset() for sn2
Message-Id: <marc-linux-ia64-105590723705593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 23 Apr 2003 12:19:25 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> This patch is against 2.4.21-pre5-cset-1.1020, I will be working on a
  Jes> 2.5.x version later today.

  Jes> Unless there are strong objections, I'd love to see this applied to the
  Jes> 2.4.x tree. Oh yes, I tested it on my zx1 as well.

One small comment: lose the " = NULL" initializers for the global
*time_hook variables; they only increase the data size for no good
reason.

The bigger issue: note that do_gettimeofday() acquires a _read_ lock.
Thus, you need to be careful about updating rtc_offset atomically.

	--david

