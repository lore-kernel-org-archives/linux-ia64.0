From: "David S. Miller" <davem@redhat.com>
Date: Fri, 11 Jun 2004 05:04:45 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <20040610220445.2116457b.davem@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 9 Jun 2004 11:09:42 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

>         /* Look for ifname matches; this should unroll nicely. */
>         for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
>                 ret |= (((const unsigned long *)indev)[i]
>                         ^ ((const unsigned long *)arpinfo->iniface)[i])
>                         & ((const unsigned long *)arpinfo->iniface_mask)[i];
>         }

This is far from a critical code path, so this is how I'm
going to fix this.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/10 22:05:19-07:00 davem@nuts.davemloft.net 
#   [IPV4]: Fix unaligned accesses in arp_tables.c
# 
# net/ipv4/netfilter/arp_tables.c
#   2004/06/10 22:05:03-07:00 davem@nuts.davemloft.net +3 -4
#   [IPV4]: Fix unaligned accesses in arp_tables.c
# 
diff -Nru a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
--- a/net/ipv4/netfilter/arp_tables.c	2004-06-10 22:05:40 -07:00
+++ b/net/ipv4/netfilter/arp_tables.c	2004-06-10 22:05:40 -07:00
@@ -179,11 +179,10 @@
 		return 0;
 	}
 
-	/* Look for ifname matches; this should unroll nicely. */
+	/* Look for ifname matches.  */
 	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)arpinfo->iniface)[i])
-			& ((const unsigned long *)arpinfo->iniface_mask)[i];
+		ret |= (indev[i] ^ arpinfo->iniface[i])
+			& arpinfo->iniface_mask[i];
 	}
 
 	if (FWINV(ret != 0, ARPT_INV_VIA_IN)) {
