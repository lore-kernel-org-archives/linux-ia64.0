From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Apr 2009 23:07:51 +0000
Subject: RE: ia64 allmodconfig bustage in 2.6.30-rc2
Message-Id: <57C9024A16AD2D4C97DC78E552063EA39E96F3DE@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090417152551.381bc522.akpm@linux-foundation.org>
In-Reply-To: <20090417152551.381bc522.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> `make allmodconfig'
> `make vmlinux'
>
>  CC      arch/ia64/kernel/asm-offsets.s
> In file included from include/linux/bitops.h:17,
>                 from include/linux/kernel.h:15,
>                 from include/linux/sched.h:52,
>                 from arch/ia64/kernel/asm-offsets.c:9:
> /usr/src/devel/arch/ia64/include/asm/bitops.h: In function `set_bit':
> /usr/src/devel/arch/ia64/include/asm/bitops.h:47: error: implicit declaration of function `BUILD_BUG_ON'

Line 47 of bitops.h is a CMPXCHG_BUGCHECK() and allmodconfig
has CONFIG_IA64_DEBUG_CMPXCHG=y, so we pick the debug version
that uses ia64_getreg(_IA64_REG_IP) to printk a message about
where we are stuck.

Now allmodconfig picks CONFIG_PARAVIRT=y ... so this ends up
taking us to __paravirt_getreg(), which is where the BUILD_BUG_ON()
gets introduced.  So we need to include <linux/kernel.h> somewhere
(or somewhere earlier than we currently do) to make this alright.

But our probem is that kernel.h goes off and includes bitops.h
long before it defines BUILD_BUG_ON.  Just moving the definition
of BUILD_BUG_ON up before we #include anything else (ugly) fixes
this immediate problem ... but then there are lots of other errors from
asm/bitops.h :-(

Deleting the two BUILD_BUG_ON instances from paravirt_privop.h does
get the build up on its feet and running.  But that loses us some
compile time checking for a coding/usage error.

Yamahata-san: How important do you think the BUILD_BUG_ON()
checks are here?  What would the failure look like if we dropped
them, and at some later time someone coded a call to ia64_getreg
with a non-constant register number as argument?

-Tony

