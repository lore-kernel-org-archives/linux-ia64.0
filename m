From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 14 Jul 2007 10:25:39 +0000
Subject: Re: [PATCH 1/2] ia64 clocksource
Message-Id: <20070714102539.GA7358@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070714002509.GJ2317@localhost>
In-Reply-To: <20070714002509.GJ2317@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 13, 2007 at 08:25:09PM -0400, Bob Picco wrote:
> 
> Andrew and Tony:
> 
> I'd like to get this into -mm with the intent of targeting for 2.6.24. There
> is only documentation change since Pete's last posting on ia64 ml. I doubt
> Pete's email address exists because of his early retirement the end of May.

What's the reason not to put it into 2.6.23?  The code has been around for
quite a long time, and finishing the transition to get rid of the timer
interpolator ASAP would be very valueable.

