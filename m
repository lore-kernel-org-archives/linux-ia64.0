From: "David S. Miller" <davem@redhat.com>
Date: Wed, 09 Jun 2004 20:29:37 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <20040609132937.68866dfc.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
	<1086805676.4288.16.camel@tdi>
	<20040609130001.37a88da1.davem@redhat.com>
	<1086812976.4288.50.camel@tdi>
In-Reply-To: <1086812976.4288.50.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 09 Jun 2004 14:29:36 -0600
Alex Williamson <alex.williamson@hp.com> wrote:

>    Which is probably why the patch never went anywhere.  There's
> certainly an alignment issue in the usage of the struct arpt_arp in the
> code snippet Christoph pointed out.  Sounds like it'd be better to fix
> the usage than the structure alignment.

Right.  I distinctly remember a similar fix being needed to
ip_tables.c many months ago, a search though the change history
for that file might prove profitable :-)
