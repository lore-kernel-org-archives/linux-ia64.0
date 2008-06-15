From: Bernhard Walle <bwalle@suse.de>
Date: Sun, 15 Jun 2008 09:55:53 +0000
Subject: Re: kdump regression: /proc/vmcore is 0 after kdump
Message-Id: <20080615115553.594e4ad7@kopernikus.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0806050058u3159e7b5x3113f63b3e0f3d8f@mail.gmail.com>
	<20080605081633.GA6713@verge.net.au>
	<3877989d0806130922p1f36a3bes9914144ac8c42266@mail.gmail.com>
	<3877989d0806150226x62fc1d1bk96131430f55848e1@mail.gmail.com>
In-Reply-To: <3877989d0806150226x62fc1d1bk96131430f55848e1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, andrew.patterson@hp.com, Petr Tesarik <ptesarik@suse.cz>, Simon Horman <horms@verge.net.au>, linux-ia64@vger.kernel.org, Kexec Mailing List <kexec@lists.infradead.org>, Roland McGrath <roland@redhat.com>

* "Luming Yu" <luming.yu@gmail.com> [2008-06-15 17:26]:
>
> My git bisection result indicates the following commit causes the
> kdump regression in 2.6.25-rc1:
> commit 3c75e23784e6ed5f4841de43d0750fd9b37bafcb
> Author: Andrew Patterson <andrew.patterson@hp.com>
> Date:   Tue Jan 22 17:18:27 2008 -0700

Can you verify that reverting that commit indeed fixes kdump at your
site?



Bernhard
-- 
Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
