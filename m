From: Gerald Pfeifer <gp@suse.de>
Date: Sat, 11 Sep 2004 19:28:12 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <Pine.LNX.4.61.0409112122090.7865@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 11 Sep 2004, Matthew Wilcox wrote:
> There is no hpet device in currently shipping zx1 boxes.  I'm not sure
> there's one in currently shipping sx1000 boxes either.

I'm believe Eigers (rx7620) and Olympias (rx8620) come with HPET,
at least they claim to. ;-)

  ACPI: HPET (v001     HP   rx8620 0x00000000   HP 0x00000000) @ ....

Gerald
