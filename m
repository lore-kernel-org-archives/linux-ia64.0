From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 Feb 2004 21:54:45 +0000
Subject: Re: CPU only nodes (no memory) patch for NUMA/DISCONTIG
Message-Id: <16443.51237.413077.809134@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <403A583C.7010808@hp.com>
In-Reply-To: <403A583C.7010808@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Feb 2004 09:40:49 -0500, Robert Picco <Robert.Picco@hp.com> said:

  Robert> Added commentary here.  There are additional comments in code which 
  Robert> hopefully elucidates the algorithm.
  Robert> Also I've addressed the other feedback.

The patch looked fine to me.  The only changes I made is to squish the
remaining trailing whitespace (which was only on otherwise empty
lines, in your case) and to change "CPU only" to "CPU-only" (seems
easier to parse that way).  I cooked up a ChangeLog entry, but in the
future, I'd really appreciate it if all patch-submissions would always
include the desired ChangeLog.  Otherwise, I have to go digging
through old mail and that takes time and makes it likely that I'll get
something wrong.  I attached the ChangeLog entry below.  If you want
something corrected, let me know soon, while I can still edit it.

Thanks,

	--david

ChangeSet@1.1666, 2004-02-24 13:48:30-08:00, Robert.Picco@hp.com
  [PATCH] ia64: add support for NUMA machines with CPU-only (memory-less) nodes

  This patch works around a limitation in the current NUMA code, which
  doesn't support CPU-only (memory-less) nodes.  With this patch
  CPU-only nodes are moved to a node with memory which is at the closest
  relative distance per the SLIT information.  Any node reassignments
  will result in the compression of the nodes and renumbering the nid
  values where appropriate.

