From: Tim Schmielau <tim@physik3.uni-rostock.de>
Date: Mon, 17 Mar 2003 19:42:31 +0000
Subject: [Linux-ia64] [BUG & WORKAROUND] nanosleep() granularity bumps up in 2.5.64
Message-Id: <marc-linux-ia64-105590709806144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 17 Mar 2003, Tim Schmielau wrote:

> On Mon, 17 Mar 2003, Vitezslav Samel wrote:
>
> >   The nanosleep() bug narrowed down to 2.5.63-bk2. That's version, the "initial
> > jiffies" patch went in. And yes, it's on i686 machine.
>
> You can easily check whether it's connected with this change by setting
> INITIAL_JIFFIES to zero. This should exactly recover the previous
> situation.

OK. I've done the test myself and I plead guilty. As a temporary
workaround you can apply the following patch:


--- linux-2.5.64/include/linux/time.h.orig	Wed Mar  5 04:29:24 2003
+++ linux-2.5.64/include/linux/time.h	Mon Mar 17 20:31:06 2003
@@ -31,7 +31,7 @@
  * Have the 32 bit jiffies value wrap 5 minutes after boot
  * so jiffies wrap bugs show up earlier.
  */
-#define INITIAL_JIFFIES ((unsigned int) (-300*HZ))
+#define INITIAL_JIFFIES 0

 /*
  * Change timeval to jiffies, trying to avoid the


Still, after half an hour of glancing at the code I can't see my mistake.
I've re-checked that the problem does not occur with the original "initial
jiffies" patch for 2.4. So I must have missed a (subtle?) difference
between 2.4 and 2.5 when I did the forward-port.

Sorry,
Tim


