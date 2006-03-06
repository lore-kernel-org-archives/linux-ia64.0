From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 06 Mar 2006 17:35:19 +0000
Subject: Re: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <200603061035.19838.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 06 March 2006 09:32, Dean Roe wrote:
> -	for_each_node(cnode) {
> +	/*
> +	 * FIXME: replace with cleaner for_each_XXX macro which addresses
> +	 * both compute and IO nodes once ACPI3.0 is available.
> +	 */
> +	for (cnode = 0; cnode < num_cnodes; cnode++) {

I don't understand this ACPI 3.0 dependency.  Can't you just define
for_each_XXX() the way you want it, and fill in the bitmask or whatever
it uses either (a) using ACPI 3.0 data, or (b) some interim hack?

Bjorn
