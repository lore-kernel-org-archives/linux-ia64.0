From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 29 May 2002 05:13:05 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
>>>>> On Wed, 22 May 2002 13:08:08 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> One interesting `feature' is that on the one that keeps running
Peter> away, the CPU clock is detected as 718.793988 MHz not the
Peter> supposedly correct 733MHz.  

Guess what.  After the reboot that I did to find out what the BIOS
said, the kernel now reports the correct cpu clock frequency, and NTP
works.

Peter C

