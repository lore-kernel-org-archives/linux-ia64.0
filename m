From: Alex Chiang <achiang@hp.com>
Date: Wed, 07 May 2008 04:44:28 +0000
Subject: Re: [PATCH 2/2] - IA64 machvec support for UV
Message-Id: <20080507044427.GA1711@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080506201857.GA4830@sgi.com>
In-Reply-To: <20080506201857.GA4830@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Jack Steiner <steiner@sgi.com>:
>  
> +config IA64_SGI_UV`
> +	bool "SGI-UV`"
> +	select NUMA
> +	select ACPI_NUMA
> +	select SWIOTLB
> +	help
> +	  Selecting this option will optimize the kernel for use on UV based
> +	  systems, but the resulting kernel binary will not run on other
                   ^^^

Should that be "and" instead of "but" ?

/ac

