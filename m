From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Jun 2004 20:29:36 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <1086812976.4288.50.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
	 <1086805676.4288.16.camel@tdi>  <20040609130001.37a88da1.davem@redhat.com>
In-Reply-To: <20040609130001.37a88da1.davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@redhat.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2004-06-09 at 14:00, David S. Miller wrote:
> On Wed, 09 Jun 2004 12:27:56 -0600
> Alex Williamson <alex.williamson@hp.com> wrote:
> 
> > http://marc.theaimsgroup.com/?l=netfilter-devel&m7814727803971&w=2
> 
> How can you legitimately change this structure?  It's an exported
> userland interface, if you change it all the applications will
> stop working.
> 

   Which is probably why the patch never went anywhere.  There's
certainly an alignment issue in the usage of the struct arpt_arp in the
code snippet Christoph pointed out.  Sounds like it'd be better to fix
the usage than the structure alignment.

	Alex

