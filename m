From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 30 Jun 2005 14:12:00 +0000
Subject: Re: Fast Syscalls and Virtualised Linux on Linux
Message-Id: <yq0wtoclyrz.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
In-Reply-To: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

Peter> One approach might be to redefine __BREAK_SYSCALL for the guest
Peter> OS.  That'd require a specially compiled glibc and kernel, and
Peter> possibly other executables.

Peter> Does anyone have a better idea?

Hi Peter,

That approach will be begging for hidden nasties all over the
place. You need to catch any static binaries as well then and anything
else that might use the break directly.

Cheers,
Jes
