From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 09 Dec 2002 22:17:05 +0000
Subject: Re: [Linux-ia64] Unwind can load wrong data from pt_regs
Message-Id: <marc-linux-ia64-105590709805528@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805516@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805516@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 10 Dec 2002 09:04:25 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> How did you guess :).  I will look at libunwind and do a
  Keith> kernel fix.

The basic idea for the fix is to add a new variable (pt_regs_addr) to
unw_frame_info to track the sp of the latest UNW_FLAG_INTERRUPT_FRAME
encountered.

	--david

