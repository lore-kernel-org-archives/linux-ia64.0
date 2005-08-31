From: Robin Holt <holt@sgi.com>
Date: Wed, 31 Aug 2005 11:28:03 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <20050831112803.GB9951@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 30, 2005 at 08:56:25PM -0700, Tony Luck wrote:
> On 8/30/05, Keith Owens <kaos@sgi.com> wrote:
> > Tony, can you give some indication on your plans for my MCA/INIT
> > rewrite?  Will you send it to Linus in the next couple of weeks or will
> > it have to wait for 2.6.15 to open?
> 
> Keith,
> 
> It is a big enough piece that I don't expect to get to dig through it and test
> before Linus hits us with 2.6.14-rc1 and issues the "slow-down" command.
> So, realistically this looks to be 2.6.15 material (unless there are others
> on the list that would like to see this in earlier and provide comments and
> test run results ... hint hint).

I would really like this in for the next distributor pull of the kernel
so it gets more exposure there.  I have used the stuff Keith posted on
8/17 and did not see anything handled incorrectly.  I will retest with
the latest today.  The machine even handled simulataneous failures the
three times I three them at it.  I only tried one nmi and did not attempt
to resume from it, but at least the register information made sense.
Compared to what I have seen in the past from NMIs, this was a vast
improvement.

What testing would you like to see?  I do not understand the issues enough
to comment on the patches, but could possibly coax a couple other people
who are into spending a half-day on it.

Thanks, Robin
