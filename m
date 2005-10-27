From: Keith Owens <kaos@sgi.com>
Date: Thu, 27 Oct 2005 00:29:25 +0000
Subject: Re: [RFC] Extend notify_die() hooks for IA64
Message-Id: <17762.1130372965@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <10137.1128667602@kao2.melbourne.sgi.com>
In-Reply-To: <10137.1128667602@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 26 Oct 2005 14:15:52 -0500, 
Dean Nelson <dcn@sgi.com> wrote:
>On Fri, Oct 07, 2005 at 04:46:42PM +1000, Keith Owens wrote:
>> This mail is only for discussion, the patch is 2.6.15-rc1 material.  It
>> has been compiled and has minimal testing.  Against 2.6.14-rc3.
>
>I applied your patch to Tony Luck's test tree. Added some changes of my own
>to XPC so it would register for the notify_die() callouts. And I did some
>preliminary testing which showed that things for the most part worked as
>advertised.
>
>I used DIE_MACHINE_RESTART and DIE_MACHINE_HALT to get XPC to indicate to
>other partitions (on a SGI Altix system) to disengage from accessing the
>terminating partitions memory.
>
>And I used DIE_MCA_MONARCH_ENTER and DIE_INIT_MONARCH_ENTER to indicate to
>other partitions to ignore the fact that our heartbeat wasn't incrementing.
>And I used DIE_MCA_MONARCH_LEAVE and DIE_INIT_MONARCH_LEAVE to indicate that
>we should now be heartbeating again.
>
>I also needed to make a few changes to kdebug.h and trap.c (see patch below)
>to allow register_notify_die() to be utilized by a module. And I added an
>unregister_notify_die() since a module can be removed. Would it be acceptable
>to add such changes should your proposed patch find approval?

Both registering and unregistering notify_die() is racy.  NMI type
events can occur at any time so another cpu could be running the notify
chain while you are modifying it.  There is a continuing discussion on
lkml about this topic at the moment, Subject: Notifier chains are unsafe.

>Is there a reason why the notify_die() callout isn't being added to
>emergency_restart()?

emergency_restart() is not supposed to block or sleep.  So I was
unhappy about adding any notify_die callbacks to that function.  This
is also part of the current discussion on lkml, should notify_die
functions be able to block?

