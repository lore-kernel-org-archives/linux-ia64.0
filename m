From: colin ngam <cngam@sgi.com>
Date: Tue, 10 May 2005 23:56:01 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <42814A11.3000809@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

Hi Christoph,

I do not have visibility to how these get used - my apology.  However, I 
do have some comments for your perusal:

..... SNIP .....

>+int sn_pcibus_to_node(struct pci_bus *bus)
>+{
>+	return nasid_to_cnodeid(NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base));
>  
>
The cnodeid returned by the above function can be a node id:
    1.  With memory but no cpus - Headless Nodes.
    2.  With no memory and no cpus - IO Nodes.

>+}
>+EXPORT_SYMBOL(sn_pcibus_to_node);
>+
>+/*
>  * sn_alloc_pci_sysdata() - This routine allocates a pci controller
>  *	which is expected as the pci_dev and pci_bus sysdata by the Linux
>  *	PCI infrastructure.
>Index: linux-2.6.11/include/asm-ia64/topology.h
>=================================>--- linux-2.6.11.orig/include/asm-ia64/topology.h	2005-05-05 11:01:46.000000000 -0700
>+++ linux-2.6.11/include/asm-ia64/topology.h	2005-05-05 16:55:00.000000000 -0700
>@@ -29,6 +29,15 @@
> #define node_to_cpumask(node) (node_to_cpu_mask[node])
>
> /*
>+ * Returns the cpus local to a given PCI device.
>+ * pcibus_to_node is defined in asm/pci.h
>+ */
>+#define pcibus_to_cpumask(bus) (pcibus_to_node(bus) = -1 ? \
>+					CPU_MASK_ALL : \
>+					node_to_cpumask(pcibus_to_node(bus)) \
>+				)
>  
>
pcibus_to_cpumask() can return 0 if the node is an ionode - TIO or 
Headless Node(node with no CPUs but has memory).

... SNIP ...

Thanks.

colin
