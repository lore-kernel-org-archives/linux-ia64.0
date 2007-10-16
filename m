From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Tue, 16 Oct 2007 08:34:14 +0000
Subject: PAL_PROC_SET_FEATURES documentation
Message-Id: <20071016083414.GA28569@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Where would I find documentation on the Itanium 2 specific flags to
PAL_PROC_SET_FEATURES?

Linux arch/ia64/kernel/setup.c seems to enable bit 0x80, but there is no
explanatory comment attached.

The Itanium 2 microarchitecture manual [1] says that early deferral of
speculative memory ops (bypassing VHPT walker) can be enabled via
PAL_PROC_SET_FEATURES, but as far as I can see does not specify anywhere
which is the appropriate bit...

Also, is it true that early deferral only happens with psr.ic=0, as
per Table 5-2?  What is the motivation for that?

Matt

[1] i.e. http://download.intel.com/design/Itanium2/manuals/25111003.pdf

