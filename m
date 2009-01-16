From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 16 Jan 2009 03:41:34 +0000
Subject: Re: linux-next: build problem with nfs tree (Was: Re: [mmotm][PATCH] fix ia64 build error)
Message-Id: <20090116123931.EBEF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090115175917.8e0ae536.akpm@linux-foundation.org> <20090116134930.68e783aa.sfr@canb.auug.org.au>
In-Reply-To: <20090116134930.68e783aa.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Prarit Bhargava <prarit@redhat.com>, David Howells <dhowells@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>, Kyle McMartin <kyle@mcmartin.ca>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <trond.myklebust@fys.uio.no>

> Hi Andrew,
> 
> On Thu, 15 Jan 2009 17:59:17 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > I do most of my gitting across a DSL connection.  It makes GUIs
> > painful.
> 
> Yeah, I will think on it ...
> 
> > > I have dropped the nfs tree from linux-next for today.
> > 
> > Just for this buglet?  That sounds a bit savage.
> 
> There was another problem with the fscache code as well.  Also, this was
> reported the day before yesterday and got no response.  Also, the other
> patch that added EXPORT_SYMBOL(copy_page) "recently" was from
> December, *2007* ... Also, this is 2.6.30 material and they have a long
> time to fix it.
> 
> Also, it is much easier on me :-)

Ghh, sorry for my really poor analysis ;)
thanks stephen.




