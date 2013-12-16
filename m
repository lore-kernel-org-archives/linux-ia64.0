From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Mon, 16 Dec 2013 04:59:00 +0000
Subject: Re: [PATCH 10/10] Kconfig: cleanup SERIO_I8042 dependencies
Message-Id: <20131216045859.GA4322@core.coreip.homeip.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <52ACA43F.2040402@zytor.com>
 <20131215103657.GB20197@core.coreip.homeip.net>
 <1387122626.1979.136.camel@deneb.redhat.com>
 <20131215.202725.1549146673897801643.davem@davemloft.net>
In-Reply-To: <20131215.202725.1549146673897801643.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Sun, Dec 15, 2013 at 08:27:25PM -0500, David Miller wrote:
> From: Mark Salter <msalter@redhat.com>
> Date: Sun, 15 Dec 2013 10:50:26 -0500
> 
> > On Sun, 2013-12-15 at 02:36 -0800, Dmitry Torokhov wrote:
> >> How are we going to merge this? In bulk through input tree or peacemeal
> >> through all arches first?
> >
> > They should all go together to eliminate the chance of bisect breakage.
> > Either the input tree or maybe akpm tree.
> 
> This sounds good to me.

OK, then I'll pick it up once I collect more acks from the arch
maintainers.

-- 
Dmitry
