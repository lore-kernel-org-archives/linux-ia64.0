From: "Egan Ford" <egan@sense.net>
Date: Fri, 27 Jul 2001 13:22:08 +0000
Subject: RE: [Linux-ia64] efi/elilo serial output
Message-Id: <marc-linux-ia64-105590693005943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005932@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005932@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Scratch 57600, it is really 115200.  I need to bump it down, most terminal
servers
do not get above 38400.

> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Matt_Domsch@Dell.com
> Sent: Thursday, July 26, 2001 8:51 PM
> To: egan@sense.net; linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] efi/elilo serial output
>
>
> > Looking for suggestions for serial out at 9600.
> >
> > EFI 1.02 will allow serial out, but only at 57600.
>
> I have all my IA-64 servers (Dell PowerEdge 7150) running serial out at
> 115200 (the EFI default), and linux console logging at 115200
> also.  Haven't
> tried running it slower though.
>
> -Matt
>
> --
> Matt Domsch
> Sr. Software Engineer
> Dell Linux Solutions
> www.dell.com/linux
> #2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
> #3 Unix provider with 18% in the US (Dataquest)!
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


