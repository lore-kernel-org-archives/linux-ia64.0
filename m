From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 07 Aug 2009 19:50:23 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1iqgze740.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>
	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>
	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>
	<m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com>
	<m1iqh1nxv3.fsf@fess.ebiederm.org> <4A7A9E54.60705@redhat.com>
In-Reply-To: <4A7A9E54.60705@redhat.com> (Amerigo Wang's message of "Thu\, 06 Aug 2009 17\:11\:48 +0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>, Bernhard Walle <bernhard.walle@gmx.de>, Kexec Mailing List <kexec@lists.infradead.org>


Let me put this concrete proposal on the table.

The problem:

With the current set of crashkernel= options we are asking the
distribution installer to perform magic.  Moving as much of this logic
into a normal init script for better maintenance is desirable.

My proposal:

Implement crashkernel=max which reserves as much memory as is
reasonable for a crash kernel, without seriously affecting stability,
performance, and reliability.

As an initial approximation I would use a 32nd of low memory.

In addition implement:

/sys/kernel/crash_size

That can be written to (with enough privileges when no crash kernel is
loaded) reduce the amount of memory reserved by the crash kernel.

Bernhard does that sound useful to you?

Amerigo does that seem reasonable?

Eric
