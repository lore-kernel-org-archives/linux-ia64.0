From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 09 Mar 2004 19:25:41 +0000
Subject: Re: crash on SysRq : Show Memory
Message-Id: <20040309192541.GA3648@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
In-Reply-To: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 09, 2004 at 10:57:48AM -0800, Grant Grundler wrote:
> On Tue, Mar 09, 2004 at 01:47:15PM -0500, Aron Griffis wrote:
> > Jesse Barnes wrote:	[Tue Mar 09 2004, 12:54:25PM EST]
> > > What kind of machine are you running on?  What's your .config look like?
> > 
> > Long's Peak.
> 
> That's an RX2600 for anyone wanting to find the product on www.hp.com

Ah, zx1 then.  I accidentally deleted the original backtrace and it
doesn't appear to be in the list archives yet, but I'm guessing that
since the panic occured at arch/ia64/mm/contig.c:show_mem+0x100, I'm
guessing the problem is somewhere after the call to show_free_areas().
I don't have a zx1 box that's easy to test with, so I probably won't be
much help.

Jesse
