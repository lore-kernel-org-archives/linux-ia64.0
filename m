From: Chris Wedgwood <cw@f00f.org>
Date: Thu, 10 Jun 2004 01:45:19 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <20040610014519.GA3158@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com> <1086805676.4288.16.camel@tdi> <20040609130001.37a88da1.davem@redhat.com>
In-Reply-To: <20040609130001.37a88da1.davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@redhat.com>
Cc: Alex Williamson <alex.williamson@hp.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Jun 09, 2004 at 01:00:01PM -0700, David S. Miller wrote:

> How can you legitimately change this structure?  It's an exported
> userland interface, if you change it all the applications will stop
> working.

Why not split the structure for user-space and kernel-space version
and cp/frob at/near the syscall boundary?



  --cw
