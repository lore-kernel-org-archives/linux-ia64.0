From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 30 Mar 2007 16:23:00 +0000
Subject: Re: [patch 0/5] ia64 memory attribute fixes
Message-Id: <200703301023.00748.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200703211616.17257.bjorn.helgaas@hp.com>
In-Reply-To: <200703211616.17257.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 29 March 2007 17:54, Luck, Tony wrote:
> Found a small problem.  With this patch in place I get
> a complaint while booting on an Intel tiger:
> 
> Trying to vfree() bad address (a00000020001b000)
> BUG: at vm/vmalloc.c:323 __vunmap()

Oops, I forgot to page-align the address before passing it to
vunmap().  I'll post an updated patch with the fix.
