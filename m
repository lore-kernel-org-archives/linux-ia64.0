From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 03 Dec 2008 12:44:49 +0000
Subject: Re: [Patch V3 0/3] Enable irqs when waiting for rwlocks
Message-Id: <1228308289.9673.237.camel@twins>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
	 <20081202161311.ae3376cb.akpm@linux-foundation.org>
	 <20081203113744.GE8970@sgi.com>  <1228307117.9673.232.camel@twins>
	 <1228307798.1009.1.camel@nathan.suse.cz>
In-Reply-To: <1228307798.1009.1.camel@nathan.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com, mingo@elte.hu, linux-arch@vger.kernel.org

On Wed, 2008-12-03 at 13:36 +0100, Petr Tesarik wrote:
> Peter Zijlstra píše v St 03. 12. 2008 v 13:25 +0100:
> > On Wed, 2008-12-03 at 05:37 -0600, Robin Holt wrote:
> > > > It's a bit regrettable to have different architectures behaving in
> > > > different ways.  It would be interesting to toss an x86_64
> > > > implementation into the grinder, see if it causes any problems, see if
> > > > it produces any tangible benefits.  Then other architectures might
> > > > follow.  Or not, depending on the results ;)
> > > 
> > > I personally expect SGI to work on this for x86_64 in the future.
> > > Once we actually start testing systems with 128 and above cpus, I
> > > would expect to see these performance issues needing to be addressed.
> > > Until then, it is just a theoretical.
> > 
> > Personally I consider this a ugly hack and would love to see people
> > solve the actual problem and move away from rwlock_t, its utter rubbish.
> 
> Me too, but we don't have that clean and nice solution today, but what
> we _do_ have today are the machines which break badly when interrupts
> are disabled for the whole duration of taking a rwlock_t. :(

Right, which creates an incentive to work on it. So we then either to a
quick and ugly hack and relieve the stress and never again get around to
looking at that particular issue (because management or something
doesn't see the problem anymore) or we do the right thing and fix it
properly.

I prefer the second, but I understand its not always an option.

> Feel free to rewrite all users of rwlock_t. I'll appreciate it, oh so
> very much.

Hehe, I wish! its on my todo list though, along with some other things,
but very unlikely I'll ever get around to it.

The good news is that Eric Dumazet recently got rid of a few prominent
users in the net code.

