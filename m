From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 08 May 2007 23:01:44 +0000
Subject: Re: [PATCH Resend] - SN: validate smp_affinity mask on intr redirect
Message-Id: <871whqapif.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
In-Reply-To: <20070508152315.26329.8428.64771@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, steiner@sgi.com, linux-ia64@vger.kernel.org


Jack>  }
Jack> +
Jack> +bool is_affinity_mask_valid(cpumask_t cpumask)
Jack> +{
Jack> +	if (ia64_platform_is("sn2")) {
Jack> +		/* Only allow one CPU to be specified in the smp_affinity mask */
Jack> +		if (cpus_weight(cpumask) != 1)
Jack> +			return false;

Why not just:
		return cpus_weight(cpumask) = 1;


It's a Boolean; treat it as one.
(If you thought the average kernel programmer (who's s/he?) understood
the logical implication rule it could be:
	return !ia64_platform_is("sn2") || cpus_weight(cpumask) = 1;
)
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

