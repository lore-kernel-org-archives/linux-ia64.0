From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 14 Dec 2001 22:35:03 +0000
Subject: Re: [Linux-ia64] fpswa patch(es)
Message-Id: <marc-linux-ia64-105590698805697@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805632@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805632@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 06 Dec 2001 15:44:19 -0600, Brian Sumner <bls@sgi.com> said:

  Brian> The following patch is really 3 patches rolled into one.
  Brian> I've found all 3 useful during application porting and debugging.

I see that this could be useful for certain debugging/hacking
activities, but I don't think it's generally useful enough to warrant
more kernel bloat.  I'd rather keep this patch separate from the
official tree.  On a side note, it seems to there are some race
conditions in incrementing the counters.

We could include more info in /proc/cpuinfo.  E.g., we could include a
count of the total number of fpswa and unaligned faults (on a per CPU
basis).  (Alpha Linux does this, if you want to look for an example).
If someone sent me a patch to do that, I'd be much more inclined to
apply it.

	--david

