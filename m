From: Matthew Wilcox <willy@debian.org>
Date: Mon, 15 Sep 2003 23:16:41 +0000
Subject: Re: NFS server problems in 2.6.0-test[4,5]
Message-Id: <marc-linux-ia64-106366788728554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106366548926386@msgid-missing>
In-Reply-To: <marc-linux-ia64-106366548926386@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 15, 2003 at 03:36:16PM -0700, David Mosberger wrote:
> Has there been any progress in getting the NFS server debugged?

Yep, on the NFS mailing list ... here's the latest patch courtesy
of Neil Brown & Trond.  I still get a 5:30 minute hang when mounting
my ia64 NFS server, but that's probably something else.

Wouldn't surprise me if this affects other 64 bit arches too.

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-09-12 14:44:42.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-09-14 07:47:01.000000000 +1000
@@ -352,9 +352,9 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
-	struct { struct cmsghdr cmh;
-		struct in_pktinfo pki;
-	} cm;
+	char 		buffer[CMSG_SPACE(sizeof(struct in_pktinfo))];
+	struct cmsghdr *cmh = (struct cmsghdr *)buffer;
+	struct in_pktinfo *pki = (struct in_pktinfo *)CMSG_DATA(cmh);
 	int		len = 0;
 	int		result;
 	int		size;
@@ -374,13 +374,13 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		msg.msg_iovlen  = 0;
 		msg.msg_flags	= MSG_MORE;
 
-		msg.msg_control = &cm;
-		msg.msg_controllen = sizeof(cm);
-		cm.cmh.cmsg_len = sizeof(cm);
-		cm.cmh.cmsg_level = SOL_IP;
-		cm.cmh.cmsg_type = IP_PKTINFO;
-		cm.pki.ipi_ifindex = 0;
-		cm.pki.ipi_spec_dst.s_addr = rqstp->rq_daddr;
+		msg.msg_control = cmh;
+		msg.msg_controllen = sizeof(buffer);
+		cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
+		cmh->cmsg_level = SOL_IP;
+		cmh->cmsg_type = IP_PKTINFO;
+		pki->ipi_ifindex = 0;
+		pki->ipi_spec_dst.s_addr = rqstp->rq_daddr;
 
 		if (sock_sendmsg(sock, &msg, 0) < 0)
 			goto out;

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
