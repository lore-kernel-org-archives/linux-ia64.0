From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 29 Aug 2000 19:04:26 +0000
Subject: Re: [Fwd: [Fwd: [Linux-ia64] ia64 redhat 7 beta]]
Message-Id: <marc-linux-ia64-105590678205412@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205407@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205407@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Aug 2000 11:52:34 -0700, Uros Prestor <uros@turbolinux.com> said:

  >> I have to place the card into a 32 bit system to access the bios
  >> and make a change, then place it back into my BigSur to try it.

  Uros> I was able to boot both test6 and test7 kernels on BigSurs
  Uros> without any Qlogic BIOS changes.  I had to enable >4G
  Uros> addressing on Lion systems when booting test6 kernels.

If you have a bigsur with >=4GB of memory, you can use kernel option
mem=4g to ignore the high memory for now.  Thanks to the work of BJ
Nima, the next qlogic driver will be able to deal with >=4GB memory
machines even if the controller operates in 32-bit mode (at the
expense of performance).

	--david

