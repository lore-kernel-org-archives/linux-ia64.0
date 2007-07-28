From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 28 Jul 2007 05:43:06 +0000
Subject: Re: [PATCH] flush cache fixes for ia64 [1/2] migration fix
Message-Id: <20070728144306.409b4c6c.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727133657.8c9c6803.kamezawa.hiroyu@jp.fujitsu.com>
	<20070727133843.6cd3f57a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0707270934300.15619@schroedinger.engr.sgi.com>
	<20070728070609.3a775842.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070728070609.3a775842.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, Zoltan.Menyhart@bull.net

On Sat, 28 Jul 2007 07:06:09 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 27 Jul 2007 09:39:16 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > This will have no effect on x86_64, ia64 and i386. Maybe useful for 
> > virtually mapped platforms (parisc)?
> > 
> yes.
> 
Ahh... but I should notify you that I added sync_icahce_dcache() (for ia64)
here. I'll post take5.

Thanks,
-Kame

