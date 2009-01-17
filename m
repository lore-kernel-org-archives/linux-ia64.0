From: David Howells <dhowells@redhat.com>
Date: Sat, 17 Jan 2009 04:43:52 +0000
Subject: Re: linux-next: build problem with nfs tree (Was: Re: [mmotm][PATCH] fix ia64 build error)
Message-Id: <24484.1232167432@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090116134930.68e783aa.sfr@canb.auug.org.au> <20090115200315.EBE3.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090115093514.f3f6b8ff.akpm@linux-foundation.org> <20090116124949.7828a559.sfr@canb.auug.org.au> <20090115175917.8e0ae536.akpm@linux-foundation.org>
In-Reply-To: <20090116134930.68e783aa.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>, Kyle McMartin <kyle@mcmartin.ca>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <trond.myklebust@fys.uio.no>

Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> > > I have dropped the nfs tree from linux-next for today.
> > 
> > Just for this buglet?  That sounds a bit savage.
> 
> There was another problem with the fscache code as well.  Also, this was
> reported the day before yesterday and got no response.

I've been flying to Tasmania for LCA and spending much time sitting around in
too many different airports.

> Also, the other patch that added EXPORT_SYMBOL(copy_page) "recently" was
> from December, *2007* ... Also, this is 2.6.30 material and they have a long
> time to fix it.

The patch was required Tuesday morning for my patches to build on top of
Linus's vanilla kernel.  This may have changed, but I haven't checked - too
busy enjoying my pre-LCA hols in Tas:-)

David
