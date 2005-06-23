From: Jesse Barnes <jesse.barnes@intel.com>
Date: Thu, 23 Jun 2005 21:10:07 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <200506231410.07739.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, June 23, 2005 2:02 pm, Christoph Lameter wrote:
> -0700 @@ -109,6 +109,7 @@ struct pci_controller {
>  	void *acpi_handle;
>  	void *iommu;
>  	int segment;
> +	int node;		/* nearest node with memory or -1 for global allocation
> */
...
> +#ifdef CONFIG_NUMA
> +				PCI_CONTROLLER(bus)->node = ioc->node;
> +#endif
>  				return;
>  			}

It looks like you're adding the new 'node' field unconditionally, but 
protecting the sba assignment by CONFIG_NUMA?  Which one is wrong? :)

Jesse
