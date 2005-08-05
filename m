From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 05 Aug 2005 17:02:00 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <1123261320.3794.5.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-08-05 at 11:00 -0600, Alex Williamson wrote:
> On Fri, 2005-08-05 at 10:12 -0400, Jes Sorensen wrote:
> > +		if (md->type = EFI_BOOT_SERVICES_DATA &&
> > +		    md->attribute = EFI_MEMORY_UC) {
> 
>    That seems to have very limited usefulness.  Wouldn't you want
> something like:
> 
> if (md->attribute = EFI_MEMORY_UC && is_available_memory(md))

   Well, except for the WB test in is_available_memory().  The point is
why not include all those types is_available_memory includes?

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

