From: Petr Tesarik <ptesarik@suse.cz>
Date: Wed, 17 Oct 2007 19:48:47 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <4716671F.8020201@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Petr Tesarik wrote:
>[...]
>   4. While talking about RNAT, does the RBS syncing back and forth
> handle correctly the case when part of the RNAT stored in the backing
> store belongs to the kernel registers? It must not be possible to change
> the NAT bits for kernel registers from userspace!
> 
>      Maybe it's not an issue, because I tried to actually exploit this
> bug, and my attempts failed.

I've just verified that put_rnat() does the right thing here (even
prevents setting NaT for syscall arguments), so modifying RNAT bits is
no problem. The other things still apply.

Regards,
Petr Tesarik
