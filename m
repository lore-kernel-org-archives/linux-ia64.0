From: "Jose Rodriguez Ruibal" <Jose.Rodriguez.Ruibal@fr.ibm.com>
Date: Thu, 16 Jan 2003 21:38:30 +0000
Subject: Re: [Linux-ia64] Problem booting SuSE SLES 8 beta (kernel 2.4.19) on
Message-Id: <marc-linux-ia64-105590709805703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805693@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805693@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi again,

I'm using SuSE SLES 8 with kernel 2.4.19. The "mptable" was a typing
mistake I made. I wanted to say "mptbase". I booted with dma disabled and
seems to work now. I'll do some tests and write back again if I get the
problem again. I'll keep you in touch.

Un saludo / Best regards / Bien Cordialement,

Jos=E9



                                                                           =
                                                           =20
                      grundler@cup.hp.c                                    =
                                                           =20
                      om (Grant                To:       Jose Rodriguez Rui=
bal/France/IBM@IBMFR                                       =20
                      Grundler)                cc:       linux-ia64@linuxia=
64.org                                                     =20
                                               Subject:  Re: [Linux-ia64] P=
roblem booting SuSE SLES 8 beta (kernel 2.4.19) on Itanium =20
                      16-01-03 20:13            2 box                      =
                                                           =20
                                                                           =
                                                           =20
                                                                           =
                                                           =20
                                                                           =
                                                           =20



On Thu, Jan 16, 2003 at 07:42:40PM +0100, Jose Rodriguez Ruibal wrote:
> Both, from the EFI shell and also from Linux.

ok. Which Linux works? The SLES 8 installer? RH AS 2.1? Self-built Kernel?

BTW, I've corrected the subject line since SLES 8 kernel for Itanium 2
systems is based on 2.4.19, not 2.4.9.

Original problem report said:
| I'm testing SuSE SLES 8 on a Itanium 2 box, and the installation goes
| more or less OK. The problem is that when I try to boot once installed,
| the boot process stops while loading the mptable module.

What made you think "mptable" was the problem when the last output
is "loading mptbase"?

Could you determine if the kernel binaries used by the SLES 8 installer
are the same as used on the reboot?
It sounds like they are not and the problem is the ramdisk.

thanks,
grant

ps. try using a different mail handler - the archives aren't able to
track this thread. See

https://lists.linuxia64.org/archives//linux-ia64/2003-January/thread.html






