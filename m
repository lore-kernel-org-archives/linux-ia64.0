From: Sam Ravnborg <sam@ravnborg.org>
Date: Wed, 19 Mar 2003 22:01:50 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] SN makefile update take 2
Message-Id: <marc-linux-ia64-105590723705274@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705269@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705269@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 18, 2003 at 10:47:07PM -0800, David Mosberger wrote:
> >>>>> On Tue, 18 Mar 2003 16:36:25 -0800, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> David, here's an updated patch that doesn't mess with
>   Jesse> arch/ia64/Makefile in case you hadn't applied the last one
>   Jesse> yet.
> 
> Applied, thanks.
>
In 2.5.65 I deprecated the usage of EXTRA_TARGETS - so be prepared
for a small update when merging with Linus.

See Documentation/kbuild/makefiles.txt - look for
targets
extra-y

Sorry for any inconvinience. 

	Sam

