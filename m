From: "David S. Miller" <davem@redhat.com>
Date: Thu, 25 Apr 2002 00:17:32 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905521@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Wed, 24 Apr 2002 17:21:19 -0700

   On Wed, Apr 24, 2002 at 05:08:08PM -0700, David S. Miller wrote:
   > Devices use, EACH, something like a few kilobytes of consistent
   > memory for descriptors.
   
   I thought I did.  The issue isn't keeping 4gb around, it's using up
   the 32 bit mappings in the bridge for 64 bit capable cards.

Reread what I've quoted, these cards use almost nothing.

Consistent allocations account for maybe %2 to %6 of the total IOMMU
mappings on a fully loaded sparc64 bus.  It doesn't even show up on
the radar.

I've rolled the numbers before, I know it isn't a problem.

