From: "Jim Hull" <jim_hull@hp.com>
Date: Mon, 28 Jan 2002 18:37:45 +0000
Subject: RE: [Linux-ia64] 32bit format VHPT walker
Message-Id: <marc-linux-ia64-105590698805943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805938@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805938@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike:

Although having a VHPT walker is optional, if a processor has one, it must
support both short and long formats.  As for whether any OS uses the long
format, yes, HP-UX does.

 -- Jim

> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of mchen@vmware.com
> Sent: Friday, January 25, 2002 10:17 PM
> To: WEI,DONG (HP-Roseville,ex1)
> Cc: 'Mike Chen'; 'linux-ia64@linuxia64.org'
> Subject: RE: [Linux-ia64] 32bit format VHPT walker
>
>
> Thanks, according to the Intel document, the VHPT walker is optional on
> a given processor model. I know that the short format VHPT walker is
> supported on current Itanium processors. How about the long format
> VHPT walker? Is there operating system that uses the long format
> VHPT walker?
>
> Mike
>
> Quoting "WEI,DONG (HP-Roseville,ex1)" <dong_wei@am.exch.hp.com>:
>
> >
> >
> > > -----Original Message-----
> > > From: Mike Chen [mailto:mchen@vmware.com]
> > > Sent: Friday, January 25, 2002 6:07 PM
> > > To: linux-ia64@linuxia64.org
> > > Subject: [Linux-ia64] 32bit format VHPT walker
> > >
> > >
> > > I have a really simple question. Is 32 bit format VHPT walker
> > > available
> > > on Itanium processor?
> >
> > Please refer to 4.1.5 of Vol 2 of the SDM.
> >
> > > Is there a EFI or SAL call to query it?
> >
> > No.
> >
> > Dong Wei
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>


