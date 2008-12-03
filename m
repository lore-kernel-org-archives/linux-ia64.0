From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 03 Dec 2008 12:25:17 +0000
Subject: Re: [Patch V3 0/3] Enable irqs when waiting for rwlocks
Message-Id: <1228307117.9673.232.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
	 <20081202161311.ae3376cb.akpm@linux-foundation.org>
	 <20081203113744.GE8970@sgi.com>
In-Reply-To: <20081203113744.GE8970@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, ptesarik@suse.cz, tee@sgi.com, mingo@elte.hu, linux-arch@vger.kernel.org

On Wed, 2008-12-03 at 05:37 -0600, Robin Holt wrote:
> > It's a bit regrettable to have different architectures behaving in
> > different ways.  It would be interesting to toss an x86_64
> > implementation into the grinder, see if it causes any problems, see if
> > it produces any tangible benefits.  Then other architectures might
> > follow.  Or not, depending on the results ;)
> 
> I personally expect SGI to work on this for x86_64 in the future.
> Once we actually start testing systems with 128 and above cpus, I
> would expect to see these performance issues needing to be addressed.
> Until then, it is just a theoretical.

Personally I consider this a ugly hack and would love to see people
solve the actual problem and move away from rwlock_t, its utter rubbish.
