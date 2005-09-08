From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Sep 2005 07:01:21 +0000
Subject: Re: [PATCH 2.6.13 8/7] MCA/INIT: tweaks
Message-Id: <10873.1126162881@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10631.1126162398@kao2.melbourne.sgi.com>
In-Reply-To: <10631.1126162398@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 08 Sep 2005 16:53:18 +1000, 
Keith Owens <kaos@sgi.com> wrote:
>Some tweaks to the previous MCA/INIT patch sets.
>
>* Remove the requirement that kernel stacks be aligned on KERNEL_STACK_SIZE.
>* Remove the serialization of MCA/INIT handlers returning to SAL.  The
>  problem looked like a race but was really caused by a broken prom
>  doing cacheable accesses to the minstate area.
>* Print the cpu number and monarch status in the INIT handler.
>* Workaround for broken proms that access the minstate area using
>  cacheable addresses.

With the above tweaks, the new MCA/INIT handlers pass all my stress
tests.  On SGI systems I can send INIT tens of times without any
problem, the system dumps the tasks and keeps going.  I was also
running ia64regcheck at the same time, it passed the test, no registers
were corrupted by INIT.

All the problems that have been reported against the new MCA/INIT
handlers have been caused by SAL not conforming to the SAL
specification.  Some versions of SAL only call the monarch cpu and not
the slaves for INIT.  Some versions of SAL call all cpus as monarchs.
Some versions of SAL do not resume correctly after INIT.  Even on these
broken versions of SAL, the new OS handlers give better results that
the existing OS handlers.  On working versions of SAL, INIT is now
fully recoverable.  On working versions of SAL, a recoverable MCA which
needs to send INIT in order to rendezvous can now be successfully
resumed.

This code is definitely ready for inclusion in 2.6.13-rc1.

