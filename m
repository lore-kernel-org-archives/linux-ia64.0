From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 18 Jul 2000 19:47:34 +0000
Subject: [Linux-ia64] Re: [ia64-dist] ANNOUNCE: New TurboLinux IA-64 distribution
Message-Id: <marc-linux-ia64-105590678205207@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does this release have all the updates necessary to build more than just
simple efi apps?  I think I remember something about patches for gnu-efi
and bfd.

Thanks,
Jesse

P.S. Thanks a lot for the release!  Keep up the good work!

Uros Prestor wrote:
> 
> WHAT'S NEW
> =====
> * GNOME desktop by Helix Code (lots of goodies).
> * Upgraded to the latest kernel (2.4.0-test1 + 0621 patch).
>   The toolchain is Cygnus May 1 release (2.9-ia64-000216-final) with
>   some additional patches (-mconstant-gp, -mauto-pic, gas unwind fixes).
> 
>   Upgraded to the latest glibc snapshot compiled under 2.3.99-pre6.
>   All the binaries from the 0505 release should work under 0714.
> * Netscape is installed by default and runs under IA-32 emulation mode.
> * Early support for kernel modules.
> * X11 server still XFree86 3.3.6 for ATI Rage 128 only.
>   XFree86 4.0.1 is available on our update ftp site for those who need
>   support for other graphics cards and for video driver development.
>   Note that 4.0.1 is not stable at this point.
> * New RPMs: gnapster, cdrecorder (yes, we burn our CDs on IA-64).
> * Fixed RPMS: strace, am-utils, nfs-utils.
> 
> The ISO image (~650 MB) is available at:
> 
>      ftp://ftp.turbolinux.com/pub/ia64/TLF-ia64-0714.iso
> 
> Check out README in the same directory.
> 
> Send questions, comments and feedback to ia64-dist@turbolinux.com
> 
> --
> Uros Prestor
> uros@turbolinux.com
> 
> _______________________________________________
> ia64-dist mailing list
> ia64-dist@turbolinux.com
> http://www.turbolinux.com/mailman/listinfo/ia64-dist


