From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Aug 2009 03:51:58 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1ljlxsiox.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>
	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>
In-Reply-To: <4A7A506B.2060008@redhat.com> (Amerigo Wang's message of "Thu\, 06 Aug 2009 11\:39\:23 +0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

>> No the crashdump mechanism is useless because user space is already
>> broken and unusable.
>
> Again, why broken?

To get a stock stat drive by hand I had to list about 5 kernel modules
in the right magic order in /etc/kdump.conf

Neither mount by label or mount by uuid when specified in /etc/kdump.conf
I had to hack mkdumprd to get an initrd that even finds the proper disk
to mount.

Short version it takes a huge amount of expertise to get what ships with
fedora to pass the trivial alt-sysrq-c test.  It would probably be about
as easy to write you own custom initrd by hand.

Eric
