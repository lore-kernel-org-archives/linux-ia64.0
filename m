From: "Vadim Furman" <vadimf@mainsoft.com>
Date: Thu, 02 Mar 2000 19:24:09 +0000
Subject: RE: [Linux-ia64] Running ia32 binaries ...
Message-Id: <marc-linux-ia64-105590678204970@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204969@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204969@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you for your advice.
Using "-static" solves the problem with "hello" app.
But I can't use this option with my real-life app.

So I proceed with dynamic option. I copied all the .so from "ldd" output
into my LD_LIBRARY_PATH on IA64. I still have "file not found" error.
One thing that I noticed is that path to /lib/ld-linux.so.2 is hard-coded
inside executable. On IA64 system that points to IA64 loader. May be that is
the problem?

> -----Original Message-----
> From: Don Dugger [mailto:n0ano@valinux.com]
> Sent: Thursday, March 02, 2000 9:46 AM
> To: Vadim Furman
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Running ia32 binaries ...
>
>
> Vadim-
>
> Did you configure and re-compile the kernel that you are running?
> I don't know if IA32 was configured into the binaries on the CD.
> Make sure that `CONFIG_IA32_SUPPORT' is turned on.
>
> Another problem could be with dynamic libraries.  The simplest
> solution is to use the `-static' flag to create a static program.
> If you want to run dynamic binaries you need to make sure that
> all the IA32 dynamic libraries are installed on your IA64 box in
> a separate directory and then have the environment variable
> `LD_LIBRARY_PATH' point to that directory.
>
> Let me know if either of those don't solve your problem.
>
> On Thu, Mar 02, 2000 at 10:24:49AM -0800, Vadim Furman wrote:
> > Hi,
> > I'm trying to run ia32-linux binaries on a ia64 machine with
> 64-bit kernel
> > from Linux Word CD, and I get: "file not found" error. Are
> there any patches
> > to install?
> > The program is a simplest "hello world".
> >
> >
> >
> >
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
>
> --
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@valinux.com
> Ph: 303/938-9838
>



