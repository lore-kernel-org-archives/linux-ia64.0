From: Marc Aurele La France <tsi@gpu.srv.ualberta.ca>
Date: Thu, 10 Aug 2000 03:26:16 +0000
Subject: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205303@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 9 Aug 2000, Michael Madore wrote:

> I have XFree 4.0.1 built on IA64, however I am having an issue with
> loadable modules that I would like to address.

> Loading individual modules works fine.  Unfortunately, if a module
> references a symbol inside another module, the dlopen() call  won't
> resolve the symbol.

> This is primarily a problem while running XFree86 -configure to create an
> initial configure file.  Here is an example:

> (II) LoadModule: "mga"
> (II) Loading /usr/X11R6/lib/modules/drivers/mga_drv.so
> dlopen: /usr/X11R6/lib/modules/drivers/mga_drv.so: undefined symbol:
> vgaHWddc1SetSpeed
> (EE) Failed to load /usr/X11R6/lib/modules/drivers/mga_drv.so
> (II) UnloadModule: "mga"

> vgaHWddc1SetSpeed is defined in /usr/X11R6/lib/modules/libvgahw.so

> How would dlopen() know to look at that module to resolve the dependency?

Looks like you built the server and modules with MakeDllModules #define'd
to YES.  This should work without it, i.e. leaving MakeDllModules to the
default of NO.  Some dlopen() implementations require all symbols to be
resolved after each module no matter what you tell it in the call.  This
seems to me to be the problem here.

Marc.

+----------------------------------+-----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310           |
|  Computing and Network Services  |  fax:    1-780-492-1729           |
|  352 General Services Building   |  email:  tsi@ualberta.ca          |
|  University of Alberta           +-----------------------------------+
|  Edmonton, Alberta               |                                   |
|  T6G 2H1                         |     Standard disclaimers apply    |
|  CANADA                          |                                   |
+----------------------------------+-----------------------------------+
XFree86 Core Team member.  ATI driver and X server internals.


