From: "David S. Miller" <davem@redhat.com>
Date: Fri, 11 Jun 2004 05:40:45 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <20040610224045.612b0ffe.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
	<20040610220445.2116457b.davem@redhat.com>
	<20040611054111.GV24042@schnapps.adilger.int>
In-Reply-To: <20040611054111.GV24042@schnapps.adilger.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Dilger <adilger@clusterfs.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 10 Jun 2004 23:41:11 -0600
Andreas Dilger <adilger@clusterfs.com> wrote:

> - 	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
> + 	for (i = 0, ret = 0; i < IFNAMSIZ; i++) {
> 
> Shouldn't your change include the above?

Yes, I'm retarted, thanks for catching that.
