From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 04 Jun 2004 05:56:40 +0000
Subject: Re: [PATCH] __ARCH_WANT_SYS_SIGPROCMASK
Message-Id: <16576.3864.219324.295528@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0406030810070.11780-100000@dhcp64-180.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0406030810070.11780-100000@dhcp64-180.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jason,

>>>>> On Thu, 3 Jun 2004 08:17:43 -0400 (EDT), Jason Baron <jbaron@redhat.com> said:

  Jason> The __ARCH_WANT_SYS_SIGPROCMASK #ifdef wraps the definition
  Jason> of both sys_sigprocmask as well as sys_rt_sigaction. I think
  Jason> it should probably only include the former. In any case, if
  Jason> CONFIG_IA32_SUPPORT is not set the build can't find the
  Jason> sys_rt_sigaction symbol as __ARCH_WANT_SYS_SIGPROCMASK is not
  Jason> definied in this case. The patch below, makes the #ifdef only
  Jason> apply to sys_sigprocmask. I've verfied that this patch does
  Jason> not break x86, ppc, x86_64, and of course fixes ia64 builds
  Jason> when CONFIG_IA32_SUPPORT is not set.

Darren Williams reported the same bug a few days ago on linux-ia64.
The patch is in my tree and just today hit Linus' tree (via Andrew),
so it should be all good now.

Thanks,

	--david
