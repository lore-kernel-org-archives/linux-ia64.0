From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 15 Jan 2009 10:32:06 +0000
Subject: Re: [PATCH] ia64, xen: compilation fix caused by 79741dd35713ff4f6fd0eafd59fa94e8a4ba922d
Message-Id: <20090115103206.GT1565%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090115061655.GM1565%yamahata@valinux.co.jp>
In-Reply-To: <20090115061655.GM1565%yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 15, 2009 at 09:54:03AM +0100, Martin Schwidefsky wrote:
> On Thu, 2009-01-15 at 15:16 +0900, Isaku Yamahata wrote:
> > This patch fixes the following errors caused by
> > 79741dd35713ff4f6fd0eafd59fa94e8a4ba922d which changed
> > the prototypes of account_steal_time() and account_idle_time().
> > 
> > >   CC      arch/ia64/xen/time.o
> > > arch/ia64/xen/time.c: In function 'consider_steal_time':
> > > arch/ia64/xen/time.c:132: warning: passing argument 1 of 'account_steal_time' makes integer from pointer without a cast
> > > arch/ia64/xen/time.c:132: error: too many arguments to function 'account_steal_time'
> > > arch/ia64/xen/time.c:133: warning: passing argument 1 of 'account_steal_time' makes integer from pointer without a cast
> > > arch/ia64/xen/time.c:133: error: too many arguments to function 'account_steal_time'
> > 
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Sorry, somehow I managed to miss this callsite for account_steal_time,
> probably because it has not been present with 2.6.27 which is the
> version I used to create the initial patch series.
> 
> I assume that this patch will be pushed via the ia64 patch queue, no?

I suppose that Tony would handle it. Tony?

-- 
yamahata
