From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 08 Jun 2006 03:39:25 +0000
Subject: Re: [PATCH] printing support for MCA/INIT
Message-Id: <44879BED.4070405@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> Hidetoshi Seto (on Wed, 07 Jun 2006 20:53:22 +0900) wrote:
>> This patch adds ia64_mca_printk() function that collects messages
>> into temporary-not-so-large message buffer during in MCA/INIT
>> environment and print them out later, after returning to normal
>> context or when handlers determine to down the system.
> 
> NAK this patch.  The handlers print their progress as they perform the
> MCA/INIT rendezvous.  That information is critical for diagnosing any
> problems with entering the handlers, it must not be delayed until the
> handlers have exited.

Isn't it just convenience of MCA/INIT handler developers like us?
I don't think it is needed much more than providing stable system to
ia64 users. Even recoverable TLB error which handled perfectly in old
days is now possibly break the system and its logs.

Why don't you use notifier all around there for such purpose?
Or is it better to have a switch the visibility of these messages?
IA64_MCA_DEBUG() is already there.

I guess there are only 2 cases actually needs to display its progress,
long time wait on rendezvous and INIT-monarch. Except these cases,
who cares about short delay of the last words from fading system and
difference of delayed messages, "there was a CMC/CPE" and "an MCA was
corrected"?

> The correct fix is to make printk safe against non maskable interrupts
> and to allow polled console I/O when interrupts are disabled.  That
> fixes printk from NMI error handlers in all architectures, not just
> ia64.

Too idealistic, at least this time.
There are many delicate thing in doing new printk from NMI context
besides interrupted printk and console driver. Making NMI handlers
(especially MCA handlers) based on assumption that printk still work
correct is technically not safe.

This patch should be replaced if such printk_on_critical is available.
Until then, I believe it is better to put the stability of the system
needed by ia64 users above our convenience.

How about your second thought?

H.Seto

