From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Aug 2009 08:47:56 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m13a85nxab.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>
	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>
	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>
	<m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com>
	<m1iqh1nxv3.fsf@fess.ebiederm.org>
In-Reply-To: <m1iqh1nxv3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Thu\, 06 Aug 2009 01\:35\:28 -0700")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>, Bernhard Walle <bwalle@suse.de>


Hmm.  I half take it back.  How is crashkernel=auto and then shrinking
the reserved size better than the extended syntax Bernhard Walle
introduced nearly two years ago?

Eric
