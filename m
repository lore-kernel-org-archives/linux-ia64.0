From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 23:42:59 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705860@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 17:44:57 -0500
   
   However, in PCI-X mode, we do not have the capability to generate
   SAC addresses.

The device can generate addresses that have the top-32bits 0 though.

You problem is rather that you cannot guarentee to be able to allocate
physical memory which is <4GB on each and every node.

That is very different from a "PCI-X issue".  It is a "this NUMA
platform" issue.

