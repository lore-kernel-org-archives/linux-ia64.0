From: Jim Wilson <wilson@tuliptree.org>
Date: Mon, 24 Feb 2003 20:30:29 +0000
Subject: Re: [Linux-ia64] [Patch] 2/2 fix in machvec.h
Message-Id: <marc-linux-ia64-105590709805920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805918@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805918@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-02-24 at 13:21, Siddha, Suresh B wrote:
> IA64 ABI specifies that globals > 8 bytes need to be aligned to 16
bytes.
> gcc doesn't follow this convention. 

That looks like an usual part of the ABI that was missed in the original
gcc port.  The ABI states that structures have a certain alignment in
one place, and then in a different place it states that global variables
have a possibly larger alignment.  Thus the alignment of a structure
depends on whether it is a local or global variable.  I am not familiar
with any other ABI that has this requirement.  It should be only the
alignment of global variables of structure or array type that are wrong.

I don't think that there is any way to get the right behavior from gcc
without modifying the variable alignment code to add a new hook for this
special case.  This change may create incompatibilities, which means it
may be a difficult change to make without breaking existing linux
distros.

Jim



