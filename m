From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 May 2001 15:00:49 +0000
Subject: Re: [Linux-ia64] Software IO-TLB Kernel panic
Message-Id: <marc-linux-ia64-105590693005604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005601@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005601@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 May 2001 13:44:50 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> I am reproduceably getting kernel panics when accessing
  Martin> discs on an Adaptec 39160 adapter (SCSI host 1 after the
  Martin> built-in QLA1280).  I am using the "new" aic7xxx driver on a
  Martin> 2.4.4 IA64 kernel.  I configured the kernel for
  Martin> DIG-compliant C0-stepping hardware.

  Martin> The kernel panic occurs in map_single
  Martin> (arch/ia64/lib/swiotlb.c:171).

Sounds like the driver is trying to map buffers that are bigger than
(1 << IO_TLB_SHIFT) (currently 2KB).

	--david

