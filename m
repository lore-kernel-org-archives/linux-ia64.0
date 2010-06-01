From: Julia Lawall <julia@diku.dk>
Date: Tue, 01 Jun 2010 20:37:58 +0000
Subject: Re: question about arch/ia64/kernel/iosapic.c
Message-Id: <Pine.LNX.4.64.1006012233110.30224@ask.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
In-Reply-To: <Pine.LNX.4.64.1005300754160.12022@ask.diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 1 Jun 2010, Tony Luck wrote:

> On Tue, Jun 1, 2010 at 11:15 AM, Julia Lawall <julia@diku.dk> wrote:
> > Yes, but the question was more because I was trying to understand whether
> > the scanner should be looking for ioremap problems or not.
> 
> Adding Bjorn as he wrote all of the code in the current version
> of ioremap().
> 
> IIRC the original version of ioremap() just did what __ioremap() does
> now ... people using ioremap() for more creative purposes prompted
> the complexity to make sure that we didn't mix cacheable and
> uncacheable accesses.  Most core kernel use of ioremap() will
> still end up in __ioremap() ... so there would be no ill effects from
> those calls if done from code that holds locks.
> 
> Are there many spots in arch/ia64 that are flagged?

I didn't try all possible locking functions, only spin_lock_irqsave.
For that function, this was the only case in the entire Linux kernel.

I just tried for spin_lock, and there are two more cases, both in drivers.

julia
