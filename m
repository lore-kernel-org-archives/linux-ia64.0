From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 17 Aug 2000 06:18:00 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Marc,

On Wed, 16 Aug 2000, Marc Aurele La France wrote:

> On Fri, 11 Aug 2000, Keith Owens wrote:
> 
> > >> I guess my question now is:  Should the dlopen() loader be able to
> > >> resolve inter-module dependencies?  If not, what is left to be done with
> > >> the elf loader make it functional on IA64?
> 
> > >Support for the ELF64 relocation types. Just like a block of code was added
> > >for Alpha support, the same type of thing will have to be added for IA64.
> 
> > modutils 2.3.13 has IA64 relocation support, courtesy of Mike Stephens
> > at Intel.  obj/obj_ia64.c should be a reasonable starting point.
> 
> Is anyone going ahead with this?  If not, I can probably come pretty close
> to getting it working even though I'd be going in blind (no hardware).
> 
> Let me know.

This is on my list of things to work on, but any help would certainly be
welcome.

Mike Madore


