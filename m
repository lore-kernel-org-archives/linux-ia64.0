From: James E Wilson <wilson@tuliptree.org>
Date: Fri, 07 Oct 2005 19:56:22 +0000
Subject: RE: PATCH: Fix 2.6 kernel for the new ia64 assembler
Message-Id: <1128714982.375.56.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051007180119.GA11645@lucon.org>
In-Reply-To: <20051007180119.GA11645@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-10-07 at 12:27, Magenheimer, Dan (HP Labs Fort Collins)
wrote:
> Will the fixed code work on both old and new assemblers?

Yes.  It is independent of the assembler, at the expense of being
slightly slower than necessary.  The code does an &=-16 to get a bundle
address, then adds 1 or 2 as appropriate to reach each slot.  Ideally,
the &=-16 should not be needed, but it is there to work around the
assembler problem.



