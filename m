From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 16 Dec 2003 16:23:10 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107159183019933@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 16 December 2003 5:17 am, Matthew Wilcox wrote:
> On Tue, Dec 16, 2003 at 05:37:35PM +0800, Yu, Luming wrote:
> > Could you let me see what are you patch doing.  
> 
> I haven't seen Bjorn's patch yet, but it'll be something like:
> 
> --- arch/ia64/pci/pci.c 12 Aug 2003 19:10:49 -0000      1.3
> +++ arch/ia64/pci/pci.c 16 Dec 2003 12:13:53 -0000
> @@ -153,7 +153,7 @@ alloc_resource (char *name, struct resou
>         res->end = end;
>         res->flags = flags;
>  
> -       if (request_resource(root, res))
> +       if (insert_resource(root, res))
>                 return -EBUSY;
>  
>         return 0;

Yup, that's exactly the patch.

And I agree with Matthew about preferring this over your patch.
Did you look at /proc/iomem with and without your patch?  The
value of keeping the request_resource() (or insert_resource())
should be obvious.

Bjorn

