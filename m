From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 21 Jan 2002 20:41:25 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 21 Jan 2002 23:30:32 +0100 (CET), Ingo Molnar <mingo@elte.hu> said:

  Ingo> Besides causing the current bug, it was superfluous in the old
  Ingo> scheduler as well, so i'm only wondering aloud - perhaps there
  Ingo> were more subtle reasons as well?

No, it wasn't superfluous.  It had to re-establish the original state
after disabling interrupts to switch the TLB pinning.

	--david

