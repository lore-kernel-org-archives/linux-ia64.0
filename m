From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 10 Nov 2003 19:22:34 +0000
Subject: Re: hot cache line due to note_interrupt()
Message-Id: <marc-linux-ia64-106849217203308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106849141002215@msgid-missing>
In-Reply-To: <marc-linux-ia64-106849141002215@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Nov 2003 13:08:34 -0600, Jack Steiner <steiner@sgi.com> said:

  Jack> FYI, I dont know the background on note_interrupt() in
  Jack> arch/ia64/kernel/irq.c, but I had to disable the function on
  Jack> our large systems.

I try to keep irq.c in sync with i386/kernel/irq.c as much as possible
(for an eventual merge).  I'd propose to bring up the issue on lkml
since it's likely to affect large x86 machines, too.  Then we can fix
x86 and ia64 at the same time.

	--david
