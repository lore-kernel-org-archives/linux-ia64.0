From: Benoit Welterlen <Benoit.Welterlen@Bull.Net>
Date: Thu, 24 Jun 2004 08:24:40 +0000
Subject: [PATCH]netpoll.c unaligned access
Message-Id: <40DA8FC8.FEF0D430@Bull.Net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------B6EC90AD988E1253DE5E227E"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------B6EC90AD988E1253DE5E227E
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,


I use netpoll (net/core/netpoll.c) to send dump over the network on IA64
(LKCD). But I have "unaligned access" in the netpoll_send_udp function.
I rewrited it to avoid this message :

------------------------------------------------------------------------
void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
{
	int total_len, eth_len, ip_len, udp_len;
	struct sk_buff *skb;
	struct udphdr *udph;
	struct iphdr *iph;
	struct ethhdr *eth;

	udp_len = len + sizeof(*udph);
	ip_len = eth_len = udp_len + sizeof(*iph);
	total_len = eth_len + ETH_HLEN;

	skb = find_skb(np, total_len, total_len - len);
	if (!skb)
		return;

	memcpy(skb->data, msg, len);
	skb->len += len;

	udph = (struct udphdr *) skb_push(skb, sizeof(*udph));
	udph->source = htons(np->local_port);
	udph->dest = htons(np->remote_port);
	udph->len = htons(udp_len);
	udph->check = 0;

	iph = (struct iphdr *)skb_push(skb, sizeof(*iph));

#if defined(__LITTLE_ENDIAN_BITFIELD)
	//iph->ihl      = 5; iph->version  = 4;
	put_unaligned(0x45,(unsigned char *)iph);
#elif defined (__BIG_ENDIAN_BITFIELD) 
        //iph->version  = 4; iph->ihl      = 5;
	put_unaligned(0x54,(unsigned char *)iph);
#else
#error	"Please fix <asm/byteorder.h>"
#endif
	iph->tos      = 0;
	put_unaligned(htons(ip_len),&(iph->tot_len));
	iph->id       = 0;
	iph->frag_off = 0;
	iph->ttl      = 64;
	iph->protocol = IPPROTO_UDP;
	iph->check    = 0;
	put_unaligned(htonl(np->local_ip),&(iph->saddr));
	put_unaligned(htonl(np->remote_ip),&(iph->daddr));
	iph->check    = ip_fast_csum((unsigned char *)iph, 5);

	eth = (struct ethhdr *) skb_push(skb, ETH_HLEN);

	eth->h_proto = htons(ETH_P_IP);
	memcpy(eth->h_source, np->local_mac, 6);
	memcpy(eth->h_dest, np->remote_mac, 6);

	netpoll_send_skb(np, skb);
}
-----------------------------------------------------------------

Regards,


Benoit Welterlen
-- 
*************************************************
*						*
*  .,p**"*=b_  Benoit Welterlen Welty		*
* ?P"  .__ `*b   BULL SA Echirolles (France)	*
* |P  .d?'`&, 9|   Room : B1 - 405 		*	
* M:  |}   |- H'   Tel : 0 47629 7390		*
* &|  `#?_._oH'  Linux Kernel Team		*
* `H.   "`"`'   				*
*  `#?.      					*
*    `^~.					*
*************************************************
--------------B6EC90AD988E1253DE5E227E
Content-Type: text/x-vcard; charset=us-ascii;
 name="Benoit.Welterlen.vcf"
Content-Description: Card for Benoit Welterlen
Content-Disposition: attachment;
 filename="Benoit.Welterlen.vcf"
Content-Transfer-Encoding: 7bit

begin:vcard 
n:Welterlen;Benoit
x-mozilla-html:TRUE
org:Bull SA;Linux Kernel
adr:;;;;;;
version:2.1
email;internet:Benoit.Welterlen@BULL.net
title:Stagiaire
note;quoted-printable:Polytech`Grenoble=0D=0A------------------------------=0D=0A"Software is like sex it's better when it's free.", Linus Torvalds 
x-mozilla-cpt:;-5920
fn:Benoit Welterlen
end:vcard

--------------B6EC90AD988E1253DE5E227E--

