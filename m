From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 20:15:01 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 10:05:28 -0500
   
   I actually like the flag as a parameter because it allows platform
   specific extensions to pass in platform specific capabilities that
   can be ignored by platform that does not support these capabilities.

I hate this concept.  I can't think of any attribute that all
platforms can't take advantage of in some way and we'd actually
want drivers to use.

Here be the way to private platform-specific interfaces, which is
totally against the reason we have these interfaces in the first
place.

