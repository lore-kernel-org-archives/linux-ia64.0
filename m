From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 11 Jan 2001 19:35:57 +0000
Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005026@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 11 Jan 2001 11:09:22 -0800, Uros Prestor <uros@turbolinux.com> said:

  Uros> I still get a kernel panic in dtlb_fault() when setting
  Uros> CONFIG_DISABLE_VHPT=y.

Are you sure you picked up the new kernel?  Try "objdump -d" on
vmlinux and verify that itlb_fault ends with "b0" being restored.

	--david

