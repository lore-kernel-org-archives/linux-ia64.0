From: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Date: Tue, 30 Mar 2004 08:27:41 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <20040330082741.541B77054E@sv1.valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org>
	<1080321646.31638.105.camel@nighthawk>
In-Reply-To: <1080321646.31638.105.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Zoltan,

At Fri, 26 Mar 2004 09:20:46 -0800,
Dave Hansen wrote:
> 
> Have you considered any common ground your patch might share with the
> people doing memory hotplug?
> 
> 	http://people.valinux.co.jp/~iwamoto/mh.html
> 
> They have a similar problem to your migration that occurs when a user
> wants to remove a whole or partial NUMA node.  
> lhms-devel@lists.sourceforge.net

Processes must be migrated to other nodes when a node is being
removed.  Conversely, processes may be migrated from other nodes when
a node is added.  I'm not familiar with NUMA things, and I think our
team doesn't have a particular solution.  If you have some idea,
that's great.

BTW, it seems page migration can use my remap_onepage function.  Our
code can move most kinds of pages including hugetlbfs pages and page
caches.

--
IWAMOTO Toshihiro
