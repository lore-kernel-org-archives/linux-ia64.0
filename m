From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 20:32:30 +0000
Subject: Re: [Linux-ia64] patch to no longer use ia64's software mmu
Message-Id: <marc-linux-ia64-105590698805609@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805585@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805585@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 04 Dec 2001 12:22:54 -0800 (PST), "David S. Miller" <davem@redhat.com> said:

  DaveM> If what you are asking is should we tweak the APIs again so
  DaveM> that situations like current IA64 can be done more sanely in
  DaveM> the PCI DMA layer, I say definitely no.

I certainly agree that the PCI DMA interface shouldn't be tweaked just
because of IA64.  What I'm wondering is whether we'll have to tweak it
anyhow to more gracefully handle the case where a hardware I/O TLB
runs out of space.  If so, I think the software I/O TLB makes sense.

  DaveM> There really is no excuse for the current IA64 hardware
  DaveM> situation, there were probably well over 3 or 4 major 64-bit
  DaveM> platforms from competitors, whose PCI controllers were pretty
  DaveM> well documented publicly, from which Intel could have derived
  DaveM> a working 64-bit platform PCI controller design.

Well, I won't comment on *this* one! ;-))

	--david

