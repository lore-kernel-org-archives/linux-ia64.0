From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 25 Apr 2002 00:36:52 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905522@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 24, 2002 at 05:17:32PM -0700, David S. Miller wrote:
> Reread what I've quoted, these cards use almost nothing.
> 
> Consistent allocations account for maybe %2 to %6 of the total IOMMU
> mappings on a fully loaded sparc64 bus.  It doesn't even show up on
> the radar.
> 
> I've rolled the numbers before, I know it isn't a problem.

Ok, so there's no performance argument against adding the call.
You're just saying that since there are enough 32 bit mappings to go
around, using 64 bit mappings is silly.  Right?

Jesse

