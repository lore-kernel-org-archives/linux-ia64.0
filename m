From: Marc Aurele La France <tsi@gpu.srv.ualberta.ca>
Date: Thu, 10 Aug 2000 15:38:31 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205309@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 9 Aug 2000, Michael Madore wrote:

> > > Looks like you built the server and modules with MakeDllModules #define'd
> > > to YES.  This should work without it, i.e. leaving MakeDllModules to the
> > > default of NO.  Some dlopen() implementations require all symbols to be
> > > resolved after each module no matter what you tell it in the call.  This
> > > seems to me to be the problem here.

> > Someone fixed the elfloader on ia64?  Last I checked it doesn't
> > even *build* without patches, but I haven't tried it too recently.

> I'm building with a patched version of the elfloader.

Is this patch available for integration into the base source?

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


