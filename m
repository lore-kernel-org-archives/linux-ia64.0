From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 23 Aug 2003 21:06:10 +0000
Subject: Re: [PATCH] default to building compressed
Message-Id: <marc-linux-ia64-106167293524944@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106166018214674@msgid-missing>
In-Reply-To: <marc-linux-ia64-106166018214674@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Aug 23, 2003 at 06:30:38PM +0100, Matthew Wilcox wrote:
> 
> i386 defaults to building `bzImage' (as well as modules) if you just type
> `make'.  This patch mirrors that on ia64 by building `compressed'.
>
> Comments?

Why not kill this 'compressed' indirection.
If people want to build vmlinux.gz, then let people specify that.
Much less confusing.

The build should also write out the full path to the location of the
kernel - no reason for people to guess the directory.

Sorry - no patch this time :-(

	Sam
