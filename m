From: "David S. Miller" <davem@redhat.com>
Date: Wed, 09 Jun 2004 20:00:01 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <20040609130001.37a88da1.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
	<1086805676.4288.16.camel@tdi>
In-Reply-To: <1086805676.4288.16.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 09 Jun 2004 12:27:56 -0600
Alex Williamson <alex.williamson@hp.com> wrote:

> http://marc.theaimsgroup.com/?l=netfilter-devel&m7814727803971&w=2

How can you legitimately change this structure?  It's an exported
userland interface, if you change it all the applications will
stop working.
