From: Bill Nottingham <notting@redhat.com>
Date: Thu, 10 Aug 2000 04:08:57 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205305@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Marc Aurele La France (tsi@gpu.srv.ualberta.ca) said: 
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

You could link all the modules against their dependencies and
futz with the library search path in the server. But that's pretty
ugly, and you'd probably still run into problems with codependent
modules (glx/GLcore).

> Looks like you built the server and modules with MakeDllModules #define'd
> to YES.  This should work without it, i.e. leaving MakeDllModules to the
> default of NO.  Some dlopen() implementations require all symbols to be
> resolved after each module no matter what you tell it in the call.  This
> seems to me to be the problem here.

Someone fixed the elfloader on ia64?  Last I checked it doesn't
even *build* without patches, but I haven't tried it too recently.

Bill

