From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 25 Mar 2004 19:04:44 +0000
Subject: RE: add lowpower_idle sysctl
Message-Id: <200403251904.i2PJ4iF25729@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040324095422.GA241@elf.ucw.cz>
References: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
In-Reply-To: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Pavel Machek' <pavel@ucw.cz>
Cc: 'Andrew Morton' <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> Pavel Machek wrote on Wed, March 24, 2004 1:54 AM
> > +extern int idle_mode;
> > +
> > +#define IDLE_NOOP	0
> > +#define IDLE_HALT	1
> > +#define IDLE_POLL	2
> > +#define IDLE_ACPI	3
> >
>
> How is idle_noop different from idle_poll?

I was thinking idle_noop truly does nothing at all, versus idle_poll
which optimize cross cpu wakeup.


