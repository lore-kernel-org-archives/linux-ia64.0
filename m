From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 02 Jun 2003 18:34:02 +0000
Subject: RE: [Linux-ia64] [PATCH] MCA recovery for TLB faults for 2.4
Message-Id: <marc-linux-ia64-105590723706112@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I probably just don't understand what the plan is here.  Are you
> planning to fix everything in one fell swoop?  If not, I think
> incrementally improving the situation makes sense (i.e., if you work
> on piece X, make X as solid as possible; over time do this for more
> and more pieces of the MCA subsystem).  There is no doubt that making
> the entire MCA subsystem as robust as possible involves a huge amount
> of rather tricky work.  Same goes for the INIT path, of course (there
> are obvious ways to deadlock it right now; probably something that
> could benefit from a reasonably generic lock-busting infrastructure).

We are using the incremental plan ... fix a piece, make it solid, move on
to the next piece.

TLB recovery was chosen as the first piece as it appears to be the
simplest to implement, though its probably one of the lowest value
adds (frequency of TLB errors should be *far* lower than memory errors,
PCI bus errors and cache errors).  But it will get the infrastructure
together to pass control up to C-code to handle more complex cases
(e.g. multi-bit ECC error in memory, where processes will need to be
sacrificed to allow the OS to continue).

-Tony


