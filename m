From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 17 Oct 2000 17:16:19 +0000
Subject: Re: [Linux-ia64] Instruction Execution
Message-Id: <marc-linux-ia64-105590678205579@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205577@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205577@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Oct 2000 09:51:51 -0700, "Mattox, Dave" <DMattox@UNITECH.COM> said:

  Dave> I just got my Itanium Machine in and after installing Linux
  Dave> (no problems with that, good work guys), I tried some timings.

  Dave> I ran a loop 666,000,000 times and it appears that each bundle
  Dave> is taking 3 seconds to execute. So this means 3 cycles per
  Dave> bundle, or 1 cycle per instruction. Is the Lion SDV Machine
  Dave> executing instructions serially? If it is, is it Linux setting
  Dave> this, or are the beta chips disabled in some manner?

Make sure "Multidispersal" is enabled in the advanced chipset
configuration menu of the firmware (BIOS).

	--david

