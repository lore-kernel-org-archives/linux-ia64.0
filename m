From: Bill Nottingham <notting@redhat.com>
Date: Fri, 04 Jun 2004 20:21:18 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <20040604202118.GB7126@nostromo.devel.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@napali.hpl.hp.com) said: 
>   Bill> Where this came out of was requests from various partners and
>   Bill> We can always just live with crappy ia32 (and by extension,
>   Bill> x86-64) support on ia64. :)
> 
> I don't think "crappy" is acceptable but it doesn't have to be perfect
> on ia64, because you 99% of the apps on a typically Linux box will be
> ia64-native binaries (I'd imagine the reverse may often be true for
> x86-64).

Actually, most x86-64 stuff is native too. Where this normally
hits with ISVs is their middleware apps. Apparently, ISVs are
averse to rebuilding their custom-changed Apache or databases,
and want to just run the x86 binaries.

> Again, I don't think multi-arch support is ia64-specific, so whatever
> can be done to improve this support will help other platforms, too.
> I'm guessing that some of the ISV problems have come from the fact
> that they tried to install _everything_ into /emul/ia32-linux?  That
> is probably not the best approach.  For self-contained applications,
> just installing in /opt or some place like that should work just fine
> (and in my experience it does).  /emul/ia32-linux should probably be
> reserved for use for files that are known or very likely to collide
> with ia64 files of the same name (such as the gtk engine shared
> libraries).

Only doing it for some files isn't really practical from a distribution
standpoint; keeping tables of what 32-bit stuff goes in 'X', what
32-bit stuff goes in 'Y', and what 32-bit stuff goes in 'Z' doesn't
scale.

> As for running shell scripts: isn't there a linux32 command that takes
> care of that?

Assuming that you know the shell script wants to use ia32 apps?

Bill
