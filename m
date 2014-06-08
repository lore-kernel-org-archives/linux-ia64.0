From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Date: Sun, 08 Jun 2014 13:56:35 +0000
Subject: is sba_map_ioc_to_node() needed in arch/ia64/hp/common/sba_iommu.c
Message-Id: <53946B93.2070900@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm playing with cppcheck which complains about :

        /* setup NUMA node association */
        sba_map_ioc_to_node(ioc, device->handle);
        return 0;<--- Memory leak: ioc
}

Well, cppcheck produces a fair amount of false positives, but in this
case I'm just wondering if there is really just one caller of the
function sba_map_ioc_to_node and furthermore if the function itself is
needed b/c its whole body is #ifdef'ed ? :

static void __init
sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
{
#ifdef CONFIG_NUMA
        unsigned int node;

        node = acpi_get_node(handle);
        if (node != NUMA_NO_NODE && !node_online(node))
                node = NUMA_NO_NODE;

        ioc->node = node;
#endif
}

-- 
Toralf

