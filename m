From: David Mosberger <davidm@hpl.hp.com>
Date: Sun, 10 Sep 2000 22:12:58 +0000
Subject: Re: [Linux-ia64] More on B1 BigSur and test8 kernel
Message-Id: <marc-linux-ia64-105590678205485@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205482@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 10 Sep 2000 19:58:52 -0000, Uros Prestor <uros@turbolinux.com> said:

  Uros> observed pretty much the same behaviour as HJ.  I didn't try
  Uros> out his patches, though.

I doubt those patches will help.  Have you tried with the ACPI
interpreter turned off?  Perhaps that will create irq problems later
on, but it should at least tell you if it's the source of the irq 0
stream.

	--david

