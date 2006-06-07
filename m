From: Keith Owens <kaos@sgi.com>
Date: Wed, 07 Jun 2006 13:28:58 +0000
Subject: Re: [PATCH] printing support for MCA/INIT
Message-Id: <7710.1149686938@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto (on Wed, 07 Jun 2006 20:53:22 +0900) wrote:
>Printing message to console from MCA/INIT handler is useful,
>however doing oops_in_progress = 1 in them exactly makes
>something in kernel wrong.
>Especially it sounds ugly if system goes wrong after returning
>from recoverable MCA.
>
>This patch adds ia64_mca_printk() function that collects messages
>into temporary-not-so-large message buffer during in MCA/INIT
>environment and print them out later, after returning to normal
>context or when handlers determine to down the system.

NAK this patch.  The handlers print their progress as they perform the
MCA/INIT rendezvous.  That information is critical for diagnosing any
problems with entering the handlers, it must not be delayed until the
handlers have exited.

The correct fix is to make printk safe against non maskable interrupts
and to allow polled console I/O when interrupts are disabled.  That
fixes printk from NMI error handlers in all architectures, not just
ia64.

