From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 22 Apr 2005 14:56:19 +0000
Subject: Re: [Pcihpd-discuss] Re: [ACPI] [RFC/PATCH 1/3] ACPI based I/O
Message-Id: <1114181779.4902.1.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD13.5080900@jp.fujitsu.com>
	 <1114104091.2784.40.camel@eeyore> <42689BE6.4040004@jp.fujitsu.com>
	 <200504220953.20831@bilbo.math.uni-mannheim.de>
In-Reply-To: <200504220953.20831-rMKJyNB0tZ8LKYO4ye7UPbyZi+5vbtHrhC4ANOJQIlc@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rolf Eike Beer <eike-hotplug-F+mm6HnICJmzQB+pC5nmwQ@public.gmane.org>
Cc: pcihpd-discuss-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Kenji Kaneshige <kaneshige.kenji-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

On Fri, 2005-04-22 at 09:53 +0200, Rolf Eike Beer wrote:
> Am Freitag, 22. April 2005 08:38 schrieb Kenji Kaneshige:
> > Hi Bjorn,
> 
> > > Nitpick: these declarations should follow the style of the rest
> > > of the file, i.e., add a space between the function name and the
> > > opening parenthesis.
> >
> > Thank you very much for comments.
> > I'll update my patches based on your comments.
> 
> No, please don't do this. It just causes me to send another patch to kill them 
> alltogether.

Don't be silly.  If you want to change the whole file to conform to
one style, fine.  I even agree with the sentiment that arch/ia64
would be better off if it were more consistent with the rest of the
kernel.

But isolated changes to a file should follow the style of the rest
of the file.

