From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 May 2004 21:29:41 +0000
Subject: Re: [PATCH] don't udelay() in sn_mmiob
Message-Id: <16566.24005.529238.412533@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405261749.02254.jbarnes@engr.sgi.com>
In-Reply-To: <200405261749.02254.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 May 2004 17:06:31 -0400, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Thursday, May 27, 2004 4:46 pm, David Mosberger wrote:

  >> Wouldn't you want at least a cpu_relax() in that loop?

  Jesse> That'll cause the CPU to switch to the other thread if it's
  Jesse> SMT so it won't spin waiting for the access to complete?  If
  Jesse> so, then yes.

It is simply good practice to always use cpu_relax() in busy-loops.
It'll make sure the compiler doesn't get too clever (thanks to the
implied barrier()) and ensures that the CPU doesn't go nuts on the
busy-loop (e.g., a Pentium 4 core might overheat).  In the case
of ia64, cpu_relax() results in a "hint @pause" instruction which
is specified as:

 "Indicates to the processor that the currently executing stream is
  waiting, spinning, or doing low priority tasks.  This hint can be
  used by the processor to allocate more resources or time to another
  executing stream on the same processor."

	--david
