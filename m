From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Feb 2004 05:47:52 +0000
Subject: RE: [Patch] speed up interrupt handling
Message-Id: <16448.11144.584052.801939@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <16446.43280.853544.583305@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 28 Feb 2004 15:22:41 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Sorry, I should have been more clear.  For the user-mode driver, we
  Peter> need to disable the interrupt so that it can be acknowledged to the
  Peter> device in the user-level code after the in-kernel generic  interrupt
  Peter> handler has returned.

Ah, now it makes sense.  OK, I don't think it will have much of a
practical effect on the normal kernel, but the patch is obvious and
simple enough that I don't see a reason not to do it.

	--david
