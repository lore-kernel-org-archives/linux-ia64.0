From: Manfred Spraul <manfreds@colorfullife.com>
Date: Sat, 11 Mar 2000 09:02:06 +0000
Subject: [Linux-ia64] Q: stack coherency
Message-Id: <marc-linux-ia64-105590678204981@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Can I access a structure that's stored on the stack of one CPU from
another CPU? I'm just noisy because I always did that [e.g SysV message
code ipc/msg.c], and now a friend asked me if that's true for all cpu
architecures.

CPU1:
- initialize linked list element [local variable]
- spin_lock
- add to linked list
- spin_unlock
- ...


CPU2:
- spin_lock
- walk the linked list
- spin_unlock.

--
	Manfred



