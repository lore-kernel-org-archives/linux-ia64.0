From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 Jul 2007 05:02:13 +0000
Subject: Re: [PATCH] flush icache before set_pte take6. [4/4] optimization
Message-Id: <20070731140213.5469a775.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
	<20070731114155.5785123c.kamezawa.hiroyu@jp.fujitsu.com>
	<ed5aea430707302115h484620f1le51fc054436b273a@mail.gmail.com>
	<20070731132932.8e21d48c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070731132932.8e21d48c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Mosberger-Tang <dmosberger@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, Christoph Lameter <clameter@sgi.com>

On Tue, 31 Jul 2007 13:29:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 30 Jul 2007 22:15:50 -0600
> "David Mosberger-Tang" <dmosberger@gmail.com> wrote:
> 
> > This seems crazy to me.  Flushing should occur according to the
> > *architecture*, not model-by-model.  Even if we happen to get "lucky"
> > on pre-Montecito CPUs, that doesn't justify such ugly hacks.  
> 

BTW, how about the quality of patch[2/4] ?

If it is enough well, I want it to be merged....

please..
-Kame

