From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 02 Aug 2002 21:44:16 +0000
Subject: [Linux-ia64] Re: CPU hotplug boot change for IA64
Message-Id: <marc-linux-ia64-105590701905894@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What's the reason for putting cpu_initialize in setup.c instead of
smp.c?  Also, I much prefer to have all global variables declared in
header files; especially for special things that are marked __init or
__devinit, etc.  Nothing worse than someone accidentally trying to use
the variable after its gone.  (Yes, there are other offenders, but
that's no reason to add to the problem.)

	--david

