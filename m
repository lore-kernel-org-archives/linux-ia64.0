From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 09 Jun 2004 18:09:42 +0000
Subject: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org

The following code casts pointers to char to long in order to do a fast
comparison. This causes alignment errors on IA64 and likely also on
other platforms:

        /* Look for ifname matches; this should unroll nicely. */
        for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
                ret |= (((const unsigned long *)indev)[i]
                        ^ ((const unsigned long *)arpinfo->iniface)[i])
                        & ((const unsigned long *)arpinfo->iniface_mask)[i];
        }

iniface is a pointer to char.
