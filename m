From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 10 Dec 2001 23:00:12 +0000
Subject: Re: [Linux-ia64] pio barriers
Message-Id: <marc-linux-ia64-105590698805672@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Actually, I was thinking that for most platforms, mf.a should do a
'flushbus' (i.e. act as a barrier for all previous pio reads/writes).
Of course, for SN, we'll need to do other stuff too, so I'd like to
make a machine vector.

Jesse

On Mon, Dec 10, 2001 at 04:57:33PM -0600, Jack Steiner wrote:
> There is a macro in io.h
> 
> 	#define __ia64_mf_a()   __asm__ __volatile__ ("mf.a" ::: "memory")
> 
> 
> However, it is not clear to me when a mf.a is actually required?? Does
> anyone have an opinion?? I dont see any clear need for it. Seems like places
> where we might want to use it actually require a flushbus(). 

