From: "David S. Miller" <davem@redhat.com>
Date: Sat, 17 May 2003 22:17:49 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705926@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jes Sorensen <jes@wildopensource.com>
   Date: 17 May 2003 12:44:52 -0400
   
   I thought about this one, but from the system's point of view, I don't
   see a difference between being able to do 64 bit DMA to consistent
   allocations and 64 bit DMA to dynamic allocations. I'd say this is a
   host adapter/driver problem for descriptor limitations as you pointed
   out.

You're probably right, we'll see ;-)

