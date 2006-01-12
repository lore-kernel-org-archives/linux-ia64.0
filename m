From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Thu, 12 Jan 2006 19:58:28 +0000
Subject: Re: SDP perf drop with 2.6.15
Message-Id: <20060112195828.GD9256@mellanox.co.il>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060112195004.GK3106@esmail.cup.hp.com>
In-Reply-To: <20060112195004.GK3106@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Quoting r. Grant Grundler <iod00d@hp.com>:
> Subject: Re: SDP perf drop with 2.6.15
> 
> On Thu, Jan 12, 2006 at 09:18:03AM +0200, Michael S. Tsirkin wrote:
> > > Makes me think it's a change in the interrupt code path.
> > > Any clues on where I might start with this?
> > 
> > oprofile should show where we are spending the time.
> 
> Executive summary:
> 	Silly me. interrupt bindings changed and I didn't check after rolling
> 	to 2.6.15 (from 2.6.14). That explains the increase cpu utilization
> 	with lower performance.
> 	Getting similar performance with -T 0,0 (2.6.15) vs -T 1,1 (2.6.14).
> 

OK, so we are left with the ref count now.
I'm seeing this myself sometimes, I have some other stuff to attend to
next week, and then I plan to look into this.

-- 
MST
