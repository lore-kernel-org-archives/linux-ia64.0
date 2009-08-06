From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 09:04:17 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7A9C91.6070002@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>	<m1eirqtmey.fsf@fess.ebiederm.org>	<20090805140408.GJ7259@hmsreliant.think-freely.org>	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>	<m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com>	<m1iqh1nxv3.fsf@fess.ebiederm.org> <m13a85nxab.fsf@fess.ebiederm.org>
In-Reply-To: <m13a85nxab.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>, Bernhard Walle <bwalle@suse.de>

Eric W. Biederman wrote:
> Hmm.  I half take it back.  How is crashkernel=auto and then shrinking
> the reserved size better than the extended syntax Bernhard Walle
> introduced nearly two years ago?
>   

You mean something like crashkernelQ2M-2G:64M,2G-:128M?
Isn't it longer and more complex than "crashkernel=auto" for an end user?

Hmm, this makes me to think that "crashkernel=auto" can be a replacement 
for that extended syntax...

