From: David Mosberger <davidm@hpl.hp.com>
Date: Sun, 06 Feb 2000 00:13:32 +0000
Subject: Re: [Linux-ia64] Q: TLB flush under SMP
Message-Id: <marc-linux-ia64-105590678204915@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204914@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204914@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 06 Feb 2000 00:38:21 +0100, Manfred Spraul <manfreds@colorfullife.com> said:

  Manfred> Is the first snapshot supposed to run on SMP
  Manfred> hardware/simulator?

SMP support is under development.  It works somewhat, but isn't
stable.  Personally, I don't care for SMP very much until I have an
SMP system myself... ;-)

  Manfred> On ia64, flush_tlb_range() does nothing if the target mm is
  Manfred> not the active mm on the current processor, but what if
  Manfred> that mm is active on another cpu?

I don't think everything has been updated for SMP support yet.  This
certainly does look suspect, though.

  Manfred> And it seems that the ia64 supports inter processor tlb
  Manfred> flushes with special instructions [ptc.g], is the
  Manfred> documentation publicly available?

Not just yet, but it will be available very soon.

	--david


