From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Jun 2004 18:27:56 +0000
Subject: Re: Unaligned accesses in net/ipv4/netfilter/arp_tables.c:184
Message-Id: <1086805676.4288.16.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0406091106210.21291@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


   A patch for this was sent to the netfilter-devel list a while back,
see this link:

http://marc.theaimsgroup.com/?l=netfilter-devel&m7814727803971&w=2

I don't think the patch ever made it anywhere so far.

	Alex

On Wed, 2004-06-09 at 12:09, Christoph Lameter wrote:
> The following code casts pointers to char to long in order to do a fast
> comparison. This causes alignment errors on IA64 and likely also on
> other platforms:
> 
>         /* Look for ifname matches; this should unroll nicely. */
>         for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
>                 ret |= (((const unsigned long *)indev)[i]
>                         ^ ((const unsigned long *)arpinfo->iniface)[i])
>                         & ((const unsigned long *)arpinfo->iniface_mask)[i];
>         }
> 
> iniface is a pointer to char.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

