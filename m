From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Feb 2000 23:06:12 +0000
Subject: Re: [Linux-ia64] SoftSur Problem
Message-Id: <marc-linux-ia64-105590678204956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204955@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204955@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This normally happens when the IRQ routing information isn't correct
for some reason.  Perhaps you didn't turn on option
CONFIG_IA64_IRQ_ACPI?

	--david

>>>>> On Tue, 22 Feb 2000 18:02:59 -0500, Venkatesh Ramamurthy <Venkateshr@ami.com> said:

  Venkatesh> Hi, I have compiled the kernel source code ( from
  Venkatesh> kernel.org ) with the cross compiler ( source code from
  Venkatesh> cygnus). I booted the SoftSur System with the new build
  Venkatesh> of kernel. Since the softsur comes with QL1280 scsi card
  Venkatesh> , i boot through that device after copying the kernel
  Venkatesh> into the proper directory. What i am getting is a SCSI
  Venkatesh> timeout in Qlogic driver when my kernel boots up. If i
  Venkatesh> try with the default kernel it works fine.

  Venkatesh> Is there any special flag that i need to set when i do a
  Venkatesh> 'make config' during kernel compilation?


