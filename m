From: alext@fc.hp.com (Alex Tsariounov)
Date: Fri, 20 Jun 2003 20:03:14 +0000
Subject: Re: 2.5.72 for ia64 released
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Message-Id: <marc-linux-ia64-105613946025937@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
To: linux-ia64@vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jun 20, 2003 at 11:01:30AM -0700, David Mosberger wrote:
>   Sam> No need for this ifeq ....
>   Sam> lib-m should work as well as lib-y.
>   Sam> If this is not the case then let me know - I will fix kbuild then.
> 
>   Sam> lib-m is actually documented!
> 
> I don't use RAID5 myself.  Can someone else test this and send me a
> patch if it works?

The workaround was needed for 2.5.69 but it looks like it works as
it originally should on 2.5.72.  Attached is a patch that goes back
to lib-m.

Thanks,
Alex

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ia64_raidfix.patch"

diff -Naur -X dontdiff linux-2.5.72-030619/arch/ia64/lib/Makefile linux-2.5.72-030619-fix/arch/ia64/lib/Makefile
--- linux-2.5.72-030619/arch/ia64/lib/Makefile	2003-06-20 13:54:00.000000000 -0600
+++ linux-2.5.72-030619-fix/arch/ia64/lib/Makefile	2003-06-20 13:48:24.000000000 -0600
@@ -12,12 +12,7 @@
 lib-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
 lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)	+= carta_random.o
-
-ifeq ($(CONFIG_MD_RAID5),m)
-	lib-y += xor.o
-else
-	lib-$(CONFIG_MD_RAID5)	+= xor.o
-endif
+lib-$(CONFIG_MD_RAID5)	+= xor.o
 
 IGNORE_FLAGS_OBJS =	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
 			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o

--oyUTqETQ0mS9luUI--
