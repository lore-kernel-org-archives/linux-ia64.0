From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Tue, 24 Apr 2001 14:41:44 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.3)
Message-Id: <marc-linux-ia64-105590693005453@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >> - Hack fs/binfmt_elf so that the auxiliary information is passed
> >> independent of whether the binary is statically or dynamically
> >> linked (Rich, I haven't run this past Linus yet, but I hope he
> >> won't have an issue with it; it really makes no sense at all to not
> >> pass this info for static binaries: an ELF file is an ELF file, no
> >> matter whether it's static or dynamic).
> 
> Gustavo> This doesn't seem to be working well here. I've checked both
> Gustavo> glibc 2.2.1 and the latest 2.2.2 from CVS and I was still
> Gustavo> getting the following error:
> 
> You need the April kernel and the latest glibc-2.2.3 from CVS and it
> should work fine.

As the subject tells, my comments were about the message "kernel update
(second patch relative to 2.4.3).". Is there anything new??

I'll have a look at glib 2.2.3.

> We are not going to revert the patch.

I was not asking you to do so... :-)

I was just reporting a bug in *my* environment and telling those who
have the same problem what to do. Maybe I'm wasting my time...

Anyway, thanks!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

