From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 10 Aug 2000 05:37:13 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > Looks like you built the server and modules with MakeDllModules #define'd
> > to YES.  This should work without it, i.e. leaving MakeDllModules to the
> > default of NO.  Some dlopen() implementations require all symbols to be
> > resolved after each module no matter what you tell it in the call.  This
> > seems to me to be the problem here.
> 
> Someone fixed the elfloader on ia64?  Last I checked it doesn't
> even *build* without patches, but I haven't tried it too recently.

I'm building with a patched version of the elfloader.

Mike Madore


