From: alext@fc.hp.com (Alex Tsariounov)
Date: Tue, 23 Sep 2003 20:15:23 +0000
Subject: Re: libelf package
Message-Id: <marc-linux-ia64-106434865517102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106401166405460@msgid-missing>
In-Reply-To: <marc-linux-ia64-106401166405460@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 23, 2003 at 11:47:48AM -0700, David Mosberger wrote:
> >>>>> On 22 Sep 2003 19:32:01 -0700, Jim Wilson <wilson@specifixinc.com> said:
...
>   Jim> There is also a libelf project that was written by Michael Riepe, Uni
>   Jim> Hannover.  I'd never heard of this one before today, and I doubt many
>   Jim> others have either.
> 
> AFAIK, it's a fairly standard interface.  I certainly have known about
> it for years and I suspect many others do, too.

Speaking from my experience only, I've moved (ported is not the word)
some code for reading symbols out of elf files that used libelf from
HPUX to Linux ia32 and ia64 using this library both on Debian and RedHat
(using the rpms available at rpmfind.net for RedHat ia32 and ia64).

No source changes were necessary, it worked "out of the box."  That says
something for the standards aspect of this "wrong" software.

I hope the replacement that RedHat is working on will produce the same
excellent results.

Alex
