From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 02 Aug 2002 22:37:24 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905900@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> There are actually relatively few ia64 dependencies in iosapic.c,
> too, so I could imagine (in the distant future) using it across
> architectures, too.  PA-RISC already uses the same hardware,
> and I wouldn't be surprised if others do eventually.

yes. x86 (Foster, ie HyperThreading CPU) does too.
80-90% of iosapic.c for ia64 and parisc are functionally identical.
IIRC, differences are in "discovery" and PCI routing table setup.
Haven't looked at x86 version yet.

If someone wants to merge them, I can make HW available remotely.
I've got all the HW but not the time. :^(
(IA64 rx2600 and PARISC A500 are already remotely accessible).

grant

