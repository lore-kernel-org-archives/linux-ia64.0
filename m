From: "Egan Ford" <egan@sense.net>
Date: Sat, 19 Jan 2002 06:44:54 +0000
Subject: RE: [Linux-ia64] efibootmgr error
Message-Id: <marc-linux-ia64-105590698805885@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805880@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805880@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt, thank you for the rapid response.  It does work.

> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Matt_Domsch@Dell.com
> Sent: Friday, January 18, 2002 12:05 PM
> To: egan@sense.net; linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] efibootmgr error
>
>
> > One of my cluster nodes gets this error when running efibootmgr:
> >
> > write_variable():open(/proc/efi/vars/Efi-47c7b226-c42a-11d2-8e
> > 57-00a0c969723
> > b): No such file or directory
>
> It means that the specific file doesn't exist.  What BIOS/Firmware are you
> using?  Is it EFI 1.1-based?
>
> There's a new copy of efibootmgr 0.4.0-test4 that I posted to linux-ia64 a
> couple weeks ago that fixes this.  Rather than assume a fixed variable
> exists, it uses the first variable it can to do the writing.
>
> Please download and try
> http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.0-test4.tar.gz.
>
> Thanks,
> Matt
>
> --
> Matt Domsch
> Sr. Software Engineer
> Dell Linux Solutions www.dell.com/linux
> #1 US Linux Server provider with 24.5% (IDC Dec 2001)
> #2 Worldwide Linux Server provider with 18.2% (IDC Dec 2001)
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


