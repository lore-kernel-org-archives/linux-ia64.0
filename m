From: Jes Sorensen <jes@sgi.com>
Date: Fri, 10 Mar 2006 09:54:35 +0000
Subject: Re: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <yq0irqm39r8.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060310082445.GA18715@verge.net.au>
In-Reply-To: <20060310082445.GA18715@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Horms" = Horms  <horms@verge.net.au> writes:

Horms> I'm not sure of the worthiness of this idea, so please consider
Horms> it an RFC.  Its key merits are:

Hi Horms,

Rips out a lot of code so if it still works then I'd say it's a good
win!

You get a D- for these two though:

Horms> +static const char *mvec_name =  NULL;
Horms> +static int nomca = 0;

No need to initialize globals to zero as the BSS is cleared at boot.

Cheers,
Jes
