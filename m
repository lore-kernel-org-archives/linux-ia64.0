From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 19 Jan 2005 17:56:59 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501190956.59510.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 19, 2005 9:53 am, David Mosberger wrote:
> I'm still not clear which case you're concerned about: mapping I/O
> memory with WC or mapping real memory with WC.  For the latter, I
> think we may need an API to allocate memory that can be mapped WC (if
> possible at all).

Oh, I thought I said that in the first message, I'm talking about I/O memory 
here.  In any event though, we shouldn't be mapping anything with the WC 
attribute that the EFI memory map doesn't allow.  And yes, we probably do 
need a special allocator for mapping regular memory with WC or UC attributes 
to avoid mapping the same region with different attributes.

Thanks,
Jesse
