From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 09 Aug 2001 03:09:45 +0000
Subject: Re: [Linux-ia64] Why VHPT is disabled in the default configuration?
Message-Id: <marc-linux-ia64-105590698805047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805045@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805045@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Aug 2001 09:50:51 +0900, "MAEDA Naoaki" <maeda.naoaki@nifty.com> said:

  Naoaki> Hi, Dose anybody know why CONFIG_DISABLE_VHPT flag is set in
  Naoaki> the default kernel configuration?

  Naoaki> I have tested the VHPT enabled kernel that shows better
  Naoaki> memory bandwidth and latency performance. If there are no
  Naoaki> concerns enabling the VHPT feature, it should be enabled in
  Naoaki> default, I think.

Yes, the VHPT should be enabled on recent CPUs (B3 or newer, IIRC).
But you shouldn't assume that the default configuration included in
the source code contains anything sensible.

	--david

