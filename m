From: Hirokazu Takahashi <taka@valinux.co.jp>
Date: Tue, 30 Mar 2004 09:05:23 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <20040330.180523.08003015.taka@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org>
	<1080321646.31638.105.camel@nighthawk>
	<20040330082741.541B77054E@sv1.valinux.co.jp>
In-Reply-To: <20040330082741.541B77054E@sv1.valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, iwamoto@valinux.co.jp

Hello,

> > Have you considered any common ground your patch might share with the
> > people doing memory hotplug?
> > 
> > 	http://people.valinux.co.jp/~iwamoto/mh.html
> > 
> > They have a similar problem to your migration that occurs when a user
> > wants to remove a whole or partial NUMA node.  
> > lhms-devel@lists.sourceforge.net
> 
> Processes must be migrated to other nodes when a node is being
> removed.  Conversely, processes may be migrated from other nodes when
> a node is added.  I'm not familiar with NUMA things, and I think our
> team doesn't have a particular solution.  If you have some idea,
> that's great.
> 
> BTW, it seems page migration can use my remap_onepage function.  Our
> code can move most kinds of pages including hugetlbfs pages and page
> caches.

I believe his patch will interest you since most of the code is
independent of cpu architecture and it also covers mmaped files,
shmem, ramdisk, mlocked pages and so on.

We will post new version of the memory hotplug patches in a week.

Thank you,
Hirokazu Takahashi.
