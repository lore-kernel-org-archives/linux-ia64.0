From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 05 Feb 2002 21:13:48 +0000
Subject: Re: [Linux-ia64] Pseudo-ops: IAS versus ia64-hp-linux-as
Message-Id: <marc-linux-ia64-105590698805992@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805959@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805959@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The following explanation is from the developer of IAS:

Thanks for the explanation.  It has been obvious to me for almost 3 years
that there was a problem with managing the size of the short data section,
and it is good to see that Intel has defined a solution for this.

>Note: that the two must come together and the need for linker support. As
>far as I know GNU linker does not support this.

Because the GNU hackers didn't know about the feature until now.  ld8.mov isn't
mentioned in my copy of the Assembler Reference Guide.  I see that there is a
new version of it on the Intel web site, but in order to figure that out,
I had to download it first.  It would be nice if these documents had version
numbers, so I can more easily tell when new versions are available.  Also,
the lack of change bars and a document history chapter means I have to
compare the new doc against the old doc by hand to find what is new.  That
is enough of a hassle that I rarely bother to do it.

Jim

