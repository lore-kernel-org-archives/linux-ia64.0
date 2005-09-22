From: Pavel Machek <pavel@ucw.cz>
Date: Thu, 22 Sep 2005 17:48:36 +0000
Subject: Re: [ACPI] [PATCH] ACPI: implement UUID-labelled vendor-defined resources
Message-Id: <20050922174835.GA27011@elf.ucw.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E02C0B5F2@orsmsx403.amr.corp.intel.com> <20050919155203.GA24346@infradead.org>
In-Reply-To: <20050919155203.GA24346-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "Moore, Robert" <robert.moore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>, "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Alex Williamson <alex.williamson-VXdhtT5mjnY@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Hi!

> > And to make things even more interesting, the base ACPICA code looks
> > nothing like the final Linux version of the code; it is converted on the
> > fly before every release to Linux.
> 
> So the Linux code is not the "preferred from of modification"?  You're
> on an extremly slipperly slope vs the GPL there.  Not that I want to
> sue your or intel, but this is certainly not in the spirit of the
> License.

Actually, they change it to conform to kernel coding-style... That
should be okay.

								Pavel
-- 
if you have sharp zaurus hardware you don't need... you know my address
