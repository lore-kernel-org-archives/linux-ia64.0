From: Grant Grundler <iod00d@hp.com>
Date: Thu, 05 Aug 2004 15:39:29 +0000
Subject: Re: [Fastboot] Re: [BROKEN PATCH] kexec for ia64
Message-Id: <20040805153929.GC6526@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com> <200407261536.05133.jbarnes@engr.sgi.com> <20040730155504.2a51b1fa.rddunlap@osdl.org> <m18ycvhx1j.fsf@ebiederm.dsl.xmission.com> <20040804233335.GD548@cup.hp.com> <m1hdri2uw0.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1hdri2uw0.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Grant Grundler <iod00d@hp.com>, "Randy.Dunlap" <rddunlap@osdl.org>, linux-ia64@vger.kernel.org, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org, fastboot@osdl.org

On Wed, Aug 04, 2004 at 08:14:55PM -0600, Eric W. Biederman wrote:
> VGA/serial console devices rarely need to do be bus masters so they
> should be fine.

yeah - you are right. I wasn't thinking.
Can anyone comment on UGA or other console devices?

> In the general case it appears to be overkill, incorrect and
> insufficient to disable bus mastering on all PCI devices.  Which is
> why device_shutdown() calls device specific code.

Is anyone else considering using kexec() to recover from a oops/panic?
What is the risk calling multiple device_shutdown() will expose another panic?

While calling a device specific cleanup is best, I worry about how
much code/data gets touched in this path. I was hoping something
simple like twiddling bus master bit would be sufficient.
If it's not, oh well.

thanks,
grant
