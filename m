From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Feb 2004 18:24:19 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16448.56531.599687.659285@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 28 Feb 2004 21:21:00 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> The in-kernel handling for edge-triggered interrupts already
  Peter> has this problem, as far as I can tell.  However, for the
  Peter> more modern IA64 platforms as far as I know there *are* no
  Peter> edge-triggered interrupts, so it shouldn't be a problem.

On a zx2000, I see:

$ cat /proc/interrupts |fgrep -i edge
 49:      14555   IO-SAPIC-edge  serial

I doubt you care about user-level serial-line drivers, though. ;-)

	--david
