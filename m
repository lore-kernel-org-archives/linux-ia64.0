From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 10 Aug 2000 05:34:37 +0000
Subject: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205307@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > (II) LoadModule: "mga"
> > (II) Loading /usr/X11R6/lib/modules/drivers/mga_drv.so
> > dlopen: /usr/X11R6/lib/modules/drivers/mga_drv.so: undefined symbol:
> > vgaHWddc1SetSpeed
> > (EE) Failed to load /usr/X11R6/lib/modules/drivers/mga_drv.so
> > (II) UnloadModule: "mga"
> 
> > vgaHWddc1SetSpeed is defined in /usr/X11R6/lib/modules/libvgahw.so
> 
> > How would dlopen() know to look at that module to resolve the dependency?
> 
> Looks like you built the server and modules with MakeDllModules #define'd
> to YES.  This should work without it, i.e. leaving MakeDllModules to the
> default of NO.  Some dlopen() implementations require all symbols to be
> resolved after each module no matter what you tell it in the call.  This
> seems to me to be the problem here.

Yes, MakeDllModules was set to YES.  I did notice that on IA32 the modules
all ended in .a instead of .so.  I assume that is because of this setting.

I based my build off of a SPEC file for XFree 4.0 which had this set to
YES.  I'll try it set to no and see if it works.

Thanks

Mike Madore
Software Engineer
TurboLinux, Inc.


