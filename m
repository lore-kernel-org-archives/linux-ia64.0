From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Nov 2002 18:55:35 +0000
Subject: Re: [Linux-ia64] /dev/rtc, regular interrupts
Message-Id: <marc-linux-ia64-105590709805477@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805468@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805468@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Nov 2002 12:23:05 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, Is there a way to get regular high-resolution timer
  Peter> interrupts from 2.5.X linux on itanium or itanium2, similar
  Peter> to what one would be able to get from /dev/rtc using the
  Peter> RTC_UIE_ON ioctl on an IA32 system?

ia64 is legacy-free so there is no guarantee that the old timer chip
is there (it isn't on hp's zx1-platforms, for example).  The EFI real
time interface doesn't provide for fine-grained timers, but the high
precision event timer (HPET) does.  However, HPET is not widely
implemented yet in today's hardware.  Depending on what you want to
do, the PMU could also be used as a high-precision timer.

	--david

