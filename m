From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 07 Aug 2009 21:03:06 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <20090807210306.GA25609@basil.fritz.box>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A7A3A78.7080200@redhat.com> <m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com> <m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com> <m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com> <m1iqh1nxv3.fsf@fess.ebiederm.org> <4A7A9E54.60705@redhat.com> <m1iqgze740.fsf@fess.ebiederm.org>
In-Reply-To: <m1iqgze740.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Amerigo Wang <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>, Bernhard Walle <bernhard.walle@gmx.de>, Kexec Mailing List <kexec@lists.infradead.org>

> As an initial approximation I would use a 32nd of low memory.

That means a 1TB machine will have a 32GB crash kernel.

Surely that's excessive?!?

It would be repeating all the same mistakes people made with hash tables
several years ago.

> 
> That can be written to (with enough privileges when no crash kernel is
> loaded) reduce the amount of memory reserved by the crash kernel.
> 
> Bernhard does that sound useful to you?
> 
> Amerigo does that seem reasonable?

It doesn't sound reasonable to Andi.

Why do you even want to grow the crash kernel that much? Is there
any real problem with a 64-128MB crash kernel?

-Andi
> 

-- 
ak@linux.intel.com -- Speaking for myself only.
