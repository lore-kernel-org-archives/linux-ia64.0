From: Christoph Lameter <christoph@lameter.com>
Date: Fri, 19 Nov 2004 19:49:40 +0000
Subject: Re: pte bit spin lock
Message-Id: <Pine.LNX.4.58.0411191148270.14667@server.graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <419D9911.1080306@yahoo.com.au>
In-Reply-To: <419D9911.1080306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Nov 2004, Nick Piggin wrote:

> I was wondering if it might be possible to change arch/ia64/kernel/ivt.S
> routines that modify pte access bits, to first take a "spin lock bit" in
> the pte before any other modifications to it, and clear the lock bit when
> done?

Sure.

> And second question, a pte's memory doesn't ever get updated transparently
> by the hardware on ia64, does it?

Correct.

> And my last question... I wonder if someone might be able to help me do the
> assembly for the locking in ivt.S provided it is a small job and I give the
> specification? Sorry, I have no idea about ia64 assembly :(

I could take a look at it next week.
