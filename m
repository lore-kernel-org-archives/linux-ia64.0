From: James Bottomley <James.Bottomley@steeleye.com>
Date: Sun, 18 May 2003 14:28:45 +0000
Subject: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705935@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2003-05-18 at 09:21, Arjan van de Ven wrote:
> On Sun, May 18, 2003 at 09:17:48AM -0500, James Bottomley wrote:
> > (it uses 32 bit addr and 32 bit len descriptors, but reduces len to 24
> > bits to steal the extra byte for 7 bits extra addressing).  However, it
> > is forced to request the full 64 bit address mask---I've never worked
> > out what will happen to it on a machine with more than 512GB memory.
> 
> Uh??? right now even in 2.4 arbitrary bitmasks are supported for
> non-coherent memory.

Ah, my mistake.  I keep forgetting there are two of these drivers in the
aic7xxx directory.  The 79xx does have a 64 bit descriptor and sets the
full width.  The 7xxx doesn't and sets a partial width.

Sorry,

James



