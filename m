From: Bernhard Walle <bernhard.walle@gmx.de>
Date: Fri, 07 Aug 2009 19:13:09 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7C7CC5.8040306@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>	<m1eirqtmey.fsf@fess.ebiederm.org>	<20090805140408.GJ7259@hmsreliant.think-freely.org>	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>	<m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com>	<m1iqh1nxv3.fsf@fess.ebiederm.org> <m13a85nxab.fsf@fess.ebiederm.org>
In-Reply-To: <m13a85nxab.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Amerigo Wang <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>, Bernhard Walle <bwalle@suse.de>

Eric W. Biederman schrieb:
> Hmm.  I half take it back.  How is crashkernel=auto and then shrinking
> the reserved size better than the extended syntax Bernhard Walle
> introduced nearly two years ago?

BTW: Ubuntu ships by default with

	crashkernel84M-2G:64M@16M,2G-:128M@16M

What is the complexity for the user? I didn't edit /boot/grub/menu.lst,
I just installed kexec-tools and a few other kdump-related packages, and
then this was in my menu.lst.

Don't make the kernel complex. Make the userspace complex.


Regards,
Bernhard


