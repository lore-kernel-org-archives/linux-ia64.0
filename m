From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 05 Jan 2001 18:48:45 +0000
Subject: Re: [Linux-ia64] Incorrect unwind data in entry.S
Message-Id: <marc-linux-ia64-105590678205882@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 21 Dec 2000 14:42:45 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> The prologue after .ret21 makes no sense.  Unwind claims that
  Keith> we are increasing the stack by 416 and spilling registers to
  Keith> stack but we are really removing the struct switch_stack.

The code is correct.  A prologue always describes the _current state_
of the frame, not the _changes_ to the frame (which would make no
sense).  In other words, the code says that after the
load_switch_stack, the frame is back to the original state (switch
stack is gone).

	--david

