From: dann frazier <dannf@hp.com>
Date: Thu, 10 Mar 2005 17:19:45 +0000
Subject: RE: cpu_to_node_map on UP systems
Message-Id: <1110475185.28015.26.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110350919.9439.16.camel@localhost>
In-Reply-To: <1110350919.9439.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-03-09 at 11:31 -0800, Luck, Tony wrote:
> >> In 2.6.11, cpu_to_node_map has moved from numa.c to smpboot.c.  Since
> >> smpboot.c isn't built on non-SMP systems, this causes 
> >non-smp builds to
> >> fail to link in various places.
> >> 
> >> I don't know what the right answer is here - resurrect numa.c maybe?
> >We do not seem to have a problem on our Autobuild with CONFIG_SMP=n
> >http://www.gelato.unsw.edu.au/kerncomp/
> >
> >Just tested latest bk ChangeSet@1.2028, 2005-03-08 
> >16:26:54-08:00, gregkh@suse.de
> >tiger_defconfig
> >CONFIG_SMP=n
> >
> >plus removal of some unwanted drivers builds OK
> 
> Yes, tiger builds ok with SMP=n (if you pull from the linux-ia64-test-2.6.12
> you'll also gets Bjorn's fix to iosapic so the the resulting kernel will
> boot, rather than hang).
> 
> There are still problems with building the generic kernel with SMP=n

fyi, I tried a UP build of linux-ia64-test-2.6.12 (assuming I checked
out the right stuff - I don't use bk much), and I get the following
compile error:

  AS      arch/ia64/kernel/head.o
arch/ia64/kernel/head.S:267:54: macro
"SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE" passed 3 arguments, but takes just 2
make[1]: *** [arch/ia64/kernel/head.o] Error 1

This is because the macro is defined as the following w/
CONFIG_HOTPLUG_CPU:

#define SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE(_reg1,_reg2,_pred)

But, if CONFIG_HOTPLUG_CPU is disabled (it requires CONFIG_SMP), the
following is defined:

#define SAL_TO_OS_BOOT_HANDOFF_STATE_SAVE(a1,a2)

I posted my .config here:
http://free.linux.hp.com/~dannf/linux-ia64-test-2.6.12-20050310.config

