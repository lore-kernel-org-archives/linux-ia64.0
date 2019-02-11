From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Mon, 11 Feb 2019 03:21:43 +0000
Subject: Re: [PATCH net-next v5 09/12] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <CABeXuvqMR7T=3ORvXPihkz-WbTN+oFeHkCu9uvebEq9wTLpJuQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190202153454.7121-1-deepa.kernel@gmail.com> <20190202153454.7121-10-deepa.kernel@gmail.com>
 <AM4PR0501MB2769C4BE6CF1C5B051068D0BC56B0@AM4PR0501MB2769.eurprd05.prod.outlook.com>
In-Reply-To: <AM4PR0501MB2769C4BE6CF1C5B051068D0BC56B0@AM4PR0501MB2769.eurprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ran Rozenstein <ranro@mellanox.com>
Cc: "davem@davemloft.net" <davem@davemloft.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "y2038@lists.linaro.org" <y2038@lists.linaro.org>, "chris@zankel.net" <chris@zankel.net>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "rth@twiddle.net" <rth@twiddle.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "ubraun@linux.ibm.com" <ubraun@linux.ibm.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>

On Feb 10, 2019, at 7:43 AM, Ran Rozenstein <ranro@mellanox.com> wrote:

>> Subject: [PATCH net-next v5 09/12] socket: Add SO_TIMESTAMPING_NEW
>>
>> Add SO_TIMESTAMPING_NEW variant of socket timestamp options.
>> This is the y2038 safe versions of the SO_TIMESTAMPING_OLD for all
>> architectures.
>>
>> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
>> Acked-by: Willem de Bruijn <willemb@google.com>
>
>
> Hi,
>
> I have app that include:
>    #include <linux/errqueue.h>
>
> It now fail with this error:
>    In file included from timestamping.c:6:0:
>    /usr/include/linux/errqueue.h:46:27: error: array type has incomplete element type 'struct __kernel_timespec'
>      struct __kernel_timespec ts[3];
>                                       ^~
> I tried to do the trivial fix, to include time.h:
> In include/uapi/linux/errqueue.h
>    #include <linux/time.h>
>    #include <linux/types.h>
>
> But it just add some other noises:
>                In file included from /usr/include/linux/errqueue.h:5:0,
>                                 from timestamping.c:6:
>                /usr/include/linux/time.h:10:8: error: redefinition of ?struct timespec?
>                 struct timespec {
>                        ^~~~~~~~
>                In file included from /usr/include/sys/select.h:39:0,
>                                 from /usr/include/sys/types.h:197,
>                                 from /usr/include/stdlib.h:279,
>                                 from timestamping.c:2:
>                /usr/include/bits/types/struct_timespec.h:8:8: note: originally defined here
>                 struct timespec
>                        ^~~~~~~~
>                In file included from /usr/include/linux/errqueue.h:5:0,
>                                 from timestamping.c:6:
>                /usr/include/linux/time.h:16:8: error: redefinition of ?struct timeval?
>                 struct timeval {
>                        ^~~~~~~
>                In file included from /usr/include/sys/select.h:37:0,
>                                 from /usr/include/sys/types.h:197,
>                                 from /usr/include/stdlib.h:279,
>                                 from timestamping.c:2:
>                /usr/include/bits/types/struct_timeval.h:8:8: note: originally defined here
>                 struct timeval
>                        ^~~~~~~
>
>
> Can you please advise how to solve it?
>
> Thanks,
> Ran

The errqueue.h already had the same issue reported previously:
https://lore.kernel.org/netdev/CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com/

Earlier when I tested this with kernel selftests such as
tools/testing/selftests/networking/timestamping/rxtimestamp(the test
was broken to begin with because of  missing include of unistd.h), I
was using make.cross to build.
This does not put the headers in the right place
(obj-$ARCH/usr/include instead of usr/include). Hence, I did not
realize that this breaks the inclusion of errqueue.h due to the
missing __kernel_timespec definition.
I forgot that nobody seems to be using linux/time.h.

But, if I include guards( #ifndef __KERNEL__) for struct timespec,
struct timeval etc for linux/time.h, then we can include it from
userspace/ errqueue.h for __kernel_timespec:

--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -2,7 +2,7 @@
 #ifndef _UAPI_LINUX_ERRQUEUE_H
 #define _UAPI_LINUX_ERRQUEUE_H

-#include <linux/types.h>
+#include <linux/time.h>

 struct sock_extended_err {
        __u32   ee_errno;
diff --git a/include/uapi/linux/time.h b/include/uapi/linux/time.h
index a6aca9aaab80..40913d9a5bc8 100644
--- a/include/uapi/linux/time.h
+++ b/include/uapi/linux/time.h
@@ -5,6 +5,8 @@
 #include <linux/types.h>


+#ifdef __KERNEL__
+
 #ifndef _STRUCT_TIMESPEC
 #define _STRUCT_TIMESPEC
 struct timespec {
@@ -42,6 +44,8 @@ struct itimerval {
        struct timeval it_value;        /* current value */
 };

+#endif /* __KERNEL__ */

Arnd,

I forgot how we plan to include the definition for __kernel_timespec
for libc or userspace. Does this seem right to you?
Also these changes to errqueue.h needs to be reverted probably as this
breaks userspace.

Thanks,
-Deepa







-Deepa
