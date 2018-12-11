From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Tue, 11 Dec 2018 20:25:19 +0000
Subject: [PATCH v2 7/8] socket: Add SO_TIMESTAMPING_NEW
Message-Id: <20181211202520.16799-8-deepa.kernel@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181211202520.16799-1-deepa.kernel@gmail.com>
In-Reply-To: <20181211202520.16799-1-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, arnd@arndb.de, y2038@lists.linaro.org, chris@zankel.net, fenghua.yu@intel.com, rth@twiddle.net, tglx@linutronix.de, ubraun@linux.ibm.com, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-s390@vger.kernel.org, linux-xtensa@linux-xtensa.org, sparclinux@vger.kernel.org

Add SO_TIMESTAMPING_NEW variant of socket timestamp options.
This is the y2038 safe versions of the SO_TIMESTAMPING_OLD
for all architectures.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: chris@zankel.net
Cc: fenghua.yu@intel.com
Cc: rth@twiddle.net
Cc: tglx@linutronix.de
Cc: ubraun@linux.ibm.com
Cc: linux-alpha@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-s390@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: sparclinux@vger.kernel.org
---
 arch/alpha/include/uapi/asm/socket.h  |  5 +-
 arch/mips/include/uapi/asm/socket.h   |  5 +-
 arch/parisc/include/uapi/asm/socket.h |  5 +-
 arch/sparc/include/uapi/asm/socket.h  |  8 +--
 include/linux/socket.h                |  7 +++
 include/uapi/asm-generic/socket.h     |  5 +-
 include/uapi/linux/errqueue.h         |  4 ++
 net/core/scm.c                        | 27 ++++++++++
 net/core/sock.c                       | 73 +++++++++++++++------------
 net/ipv4/tcp.c                        | 29 ++++++-----
 net/smc/af_smc.c                      |  3 +-
 net/socket.c                          | 15 ++++--
 12 files changed, 122 insertions(+), 64 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 352e3dc0b3d9..8b9f6f7f8087 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -116,19 +116,20 @@
 
 #define SO_TIMESTAMP_NEW         62
 #define SO_TIMESTAMPNS_NEW       63
+#define SO_TIMESTAMPING_NEW      64
 
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG = 64
 #define SO_TIMESTAMP		SO_TIMESTAMP_OLD
 #define SO_TIMESTAMPNS		SO_TIMESTAMPNS_OLD
+#define SO_TIMESTAMPING		SO_TIMESTAMPING_OLD
 #else
 #define SO_TIMESTAMP (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMP_OLD : SO_TIMESTAMP_NEW)
 #define SO_TIMESTAMPNS (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPNS_OLD : SO_TIMESTAMPNS_NEW)
+#define SO_TIMESTAMPING (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPING_OLD : SO_TIMESTAMPING_NEW)
 #endif
 
-#define SO_TIMESTAMPING        SO_TIMESTAMPING_OLD
-
 #define SCM_TIMESTAMP          SO_TIMESTAMP
 #define SCM_TIMESTAMPNS        SO_TIMESTAMPNS
 #define SCM_TIMESTAMPING       SO_TIMESTAMPING
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index d1752e3f1248..9fc80c5d54e4 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -126,19 +126,20 @@
 
 #define SO_TIMESTAMP_NEW         62
 #define SO_TIMESTAMPNS_NEW       63
+#define SO_TIMESTAMPING_NEW      64
 
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG = 64
 #define SO_TIMESTAMP		SO_TIMESTAMP_OLD
 #define SO_TIMESTAMPNS		SO_TIMESTAMPNS_OLD
+#define SO_TIMESTAMPING		SO_TIMESTAMPING_OLD
 #else
 #define SO_TIMESTAMP (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMP_OLD : SO_TIMESTAMP_NEW)
 #define SO_TIMESTAMPNS (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPNS_OLD : SO_TIMESTAMPNS_NEW)
+#define SO_TIMESTAMPING (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPING_OLD : SO_TIMESTAMPING_NEW)
 #endif
 
-#define SO_TIMESTAMPING        SO_TIMESTAMPING_OLD
-
 #define SCM_TIMESTAMP          SO_TIMESTAMP
 #define SCM_TIMESTAMPNS        SO_TIMESTAMPNS
 #define SCM_TIMESTAMPING       SO_TIMESTAMPING
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 0a45b668abd1..82f1c9447d6b 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -107,19 +107,20 @@
 
 #define SO_TIMESTAMP_NEW         0x4037
 #define SO_TIMESTAMPNS_NEW       0x4038
+#define SO_TIMESTAMPING_NEW      0x4039
 
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG = 64
 #define SO_TIMESTAMP		SO_TIMESTAMP_OLD
 #define SO_TIMESTAMPNS		SO_TIMESTAMPNS_OLD
+#define SO_TIMESTAMPING		SO_TIMESTAMPING_OLD
 #else
 #define SO_TIMESTAMP (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMP_OLD : SO_TIMESTAMP_NEW)
 #define SO_TIMESTAMPNS (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPNS_OLD : SO_TIMESTAMPNS_NEW)
+#define SO_TIMESTAMPING (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPING_OLD : SO_TIMESTAMPING_NEW)
 #endif
 
-#define SO_TIMESTAMPING        SO_TIMESTAMPING_OLD
-
 #define SCM_TIMESTAMP          SO_TIMESTAMP
 #define SCM_TIMESTAMPNS        SO_TIMESTAMPNS
 #define SCM_TIMESTAMPING       SO_TIMESTAMPING
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index dc8527cae5a7..5bdbb25c28d2 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -106,20 +106,22 @@
 #define SO_TIMESTAMPNS_OLD       0x0021
 #define SO_TIMESTAMPING_OLD      0x0023
 
-#define SO_TIMESTAMP_NEW         0x0040
-#define SO_TIMESTAMPNS_NEW       0x0041
+#define SO_TIMESTAMP_NEW         0x0041
+#define SO_TIMESTAMPNS_NEW       0x0042
+#define SO_TIMESTAMPING_NEW      0x0043
 
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG = 64
 #define SO_TIMESTAMP		SO_TIMESTAMP_OLD
 #define SO_TIMESTAMPNS		SO_TIMESTAMPNS_OLD
+#define SO_TIMESTAMPING		SO_TIMESTAMPING_OLD
 #else
 #define SO_TIMESTAMP (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMP_OLD : SO_TIMESTAMP_NEW)
 #define SO_TIMESTAMPNS (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPNS_OLD : SO_TIMESTAMPNS_NEW)
+#define SO_TIMESTAMPING (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPING_OLD : SO_TIMESTAMPING_NEW)
 #endif
 
-#define SO_TIMESTAMPING        SO_TIMESTAMPING_OLD
 
 #define SCM_TIMESTAMP          SO_TIMESTAMP
 #define SCM_TIMESTAMPNS        SO_TIMESTAMPNS
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 8b571e9b9f76..372fd77698a2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -350,6 +350,13 @@ extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
 struct timespec64;
 
+struct scm_timestamping_internal {
+	struct timespec64 ts[3];
+};
+
+extern void put_cmsg_scm_timestamping64(struct msghdr *msg, struct scm_timestamping_internal *tss);
+extern void put_cmsg_scm_timestamping(struct msghdr *msg, struct scm_timestamping_internal *tss);
+
 /* The __sys_...msg variants allow MSG_CMSG_COMPAT iff
  * forbid_cmsg_compat=false
  */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 0b0fae6b57a9..2fdfb6126246 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -110,6 +110,7 @@
 
 #define SO_TIMESTAMP_NEW         62
 #define SO_TIMESTAMPNS_NEW       63
+#define SO_TIMESTAMPING_NEW         64
 
 #if !defined(__KERNEL__)
 
@@ -117,13 +118,13 @@
 /* on 64-bit and x32, avoid the ?: operator */
 #define SO_TIMESTAMP		SO_TIMESTAMP_OLD
 #define SO_TIMESTAMPNS		SO_TIMESTAMPNS_OLD
+#define SO_TIMESTAMPING		SO_TIMESTAMPING_OLD
 #else
 #define SO_TIMESTAMP (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMP_OLD : SO_TIMESTAMP_NEW)
 #define SO_TIMESTAMPNS (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPNS_OLD : SO_TIMESTAMPNS_NEW)
+#define SO_TIMESTAMPING (sizeof(time_t) = sizeof(__kernel_long_t) ? SO_TIMESTAMPING_OLD : SO_TIMESTAMPING_NEW)
 #endif
 
-#define SO_TIMESTAMPING        SO_TIMESTAMPING_OLD
-
 #define SCM_TIMESTAMP          SO_TIMESTAMP
 #define SCM_TIMESTAMPNS        SO_TIMESTAMPNS
 #define SCM_TIMESTAMPING       SO_TIMESTAMPING
diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index c0151200f7d1..d955b9e32288 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -41,6 +41,10 @@ struct scm_timestamping {
 	struct timespec ts[3];
 };
 
+struct scm_timestamping64 {
+	struct __kernel_timespec ts[3];
+};
+
 /* The type of scm_timestamping, passed in sock_extended_err ee_info.
  * This defines the type of ts[0]. For SCM_TSTAMP_SND only, if ts[0]
  * is zero, then this is a hardware timestamp and recorded in ts[2].
diff --git a/net/core/scm.c b/net/core/scm.c
index b1ff8a441748..52ef219cf6df 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -29,6 +29,7 @@
 #include <linux/pid.h>
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
+#include <linux/errqueue.h>
 
 #include <linux/uaccess.h>
 
@@ -252,6 +253,32 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 }
 EXPORT_SYMBOL(put_cmsg);
 
+void put_cmsg_scm_timestamping64(struct msghdr *msg, struct scm_timestamping_internal *tss_internal)
+{
+	struct scm_timestamping64 tss;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(tss.ts); i++) {
+		tss.ts[i].tv_sec = tss_internal->ts[i].tv_sec;
+		tss.ts[i].tv_nsec = tss_internal->ts[i].tv_nsec;
+	}
+
+	put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMPING_NEW, sizeof(tss), &tss);
+}
+EXPORT_SYMBOL(put_cmsg_scm_timestamping64);
+
+void put_cmsg_scm_timestamping(struct msghdr *msg, struct scm_timestamping_internal *tss_internal)
+{
+	struct scm_timestamping tss;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(tss.ts); i++)
+		tss.ts[i] = timespec64_to_timespec(tss_internal->ts[i]);
+
+	put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMPING_OLD, sizeof(tss), &tss);
+}
+EXPORT_SYMBOL(put_cmsg_scm_timestamping);
+
 void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 {
 	struct cmsghdr __user *cm
diff --git a/net/core/sock.c b/net/core/sock.c
index 1f4db404782c..2a04f568ab47 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -676,6 +676,45 @@ static void setsockopt_timestamp(struct sock *sk, int type, int val)
 	sock_enable_timestamp(sk, SOCK_TIMESTAMP);
 }
 
+static int setsockopt_timestamping(struct sock *sk, int type, int val)
+{
+	if (type = SO_TIMESTAMPING_NEW)
+		sock_set_flag(sk, SOCK_TSTAMP_NEW);
+
+	if (val & ~SOF_TIMESTAMPING_MASK)
+		return -EINVAL;
+
+	if (val & SOF_TIMESTAMPING_OPT_ID &&
+	    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
+		if (sk->sk_protocol = IPPROTO_TCP &&
+		    sk->sk_type = SOCK_STREAM) {
+			if ((1 << sk->sk_state) &
+			    (TCPF_CLOSE | TCPF_LISTEN))
+				return -EINVAL;
+			sk->sk_tskey = tcp_sk(sk)->snd_una;
+		} else {
+			sk->sk_tskey = 0;
+		}
+	}
+
+	if (val & SOF_TIMESTAMPING_OPT_STATS &&
+	    !(val & SOF_TIMESTAMPING_OPT_TSONLY))
+		return -EINVAL;
+
+	sk->sk_tsflags = val;
+	if (val & SOF_TIMESTAMPING_RX_SOFTWARE) {
+		sock_enable_timestamp(sk,
+				      SOCK_TIMESTAMPING_RX_SOFTWARE);
+	} else {
+		if (type = SO_TIMESTAMPING_NEW)
+			sock_reset_flag(sk, SOCK_TSTAMP_NEW);
+		sock_disable_timestamp(sk,
+				       (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
+	}
+
+	return 0;
+}
+
 /*
  *	This is meant for all protocols to use and covers goings on
  *	at the socket level. Everything here is generic.
@@ -851,39 +890,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_TIMESTAMPING_OLD:
-		if (val & ~SOF_TIMESTAMPING_MASK) {
-			ret = -EINVAL;
-			break;
-		}
-
-		if (val & SOF_TIMESTAMPING_OPT_ID &&
-		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
-			if (sk->sk_protocol = IPPROTO_TCP &&
-			    sk->sk_type = SOCK_STREAM) {
-				if ((1 << sk->sk_state) &
-				    (TCPF_CLOSE | TCPF_LISTEN)) {
-					ret = -EINVAL;
-					break;
-				}
-				sk->sk_tskey = tcp_sk(sk)->snd_una;
-			} else {
-				sk->sk_tskey = 0;
-			}
-		}
-
-		if (val & SOF_TIMESTAMPING_OPT_STATS &&
-		    !(val & SOF_TIMESTAMPING_OPT_TSONLY)) {
-			ret = -EINVAL;
-			break;
-		}
-
-		sk->sk_tsflags = val;
-		if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
-			sock_enable_timestamp(sk,
-					      SOCK_TIMESTAMPING_RX_SOFTWARE);
-		else
-			sock_disable_timestamp(sk,
-					       (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE));
+		ret = setsockopt_timestamping(sk, optname, val);
 		break;
 
 	case SO_RCVLOWAT:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 73e1628a3946..bc9907648cf5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1847,17 +1847,17 @@ static int tcp_zerocopy_receive(struct sock *sk,
 #endif
 
 static void tcp_update_recv_tstamps(struct sk_buff *skb,
-				    struct scm_timestamping *tss)
+				    struct scm_timestamping_internal *tss)
 {
 	if (skb->tstamp)
-		tss->ts[0] = ktime_to_timespec(skb->tstamp);
+		tss->ts[0] = ktime_to_timespec64(skb->tstamp);
 	else
-		tss->ts[0] = (struct timespec) {0};
+		tss->ts[0] = (struct timespec64) {0};
 
 	if (skb_hwtstamps(skb)->hwtstamp)
-		tss->ts[2] = ktime_to_timespec(skb_hwtstamps(skb)->hwtstamp);
+		tss->ts[2] = ktime_to_timespec64(skb_hwtstamps(skb)->hwtstamp);
 	else
-		tss->ts[2] = (struct timespec) {0};
+		tss->ts[2] = (struct timespec64) {0};
 }
 
 static void tcp_recv_sw_timestamp(struct msghdr *msg, const struct sock *sk, struct timespec64 *ts)
@@ -1900,29 +1900,30 @@ static void tcp_recv_sw_timestamp(struct msghdr *msg, const struct sock *sk, str
 
 /* Similar to __sock_recv_timestamp, but does not require an skb */
 static void tcp_recv_timestamp(struct msghdr *msg, const struct sock *sk,
-			       struct scm_timestamping *tss)
+			       struct scm_timestamping_internal *tss)
 {
 	bool has_timestamping = false;
-	struct timespec64 ts = timespec_to_timespec64(tss->ts[0]);
 
-	tcp_recv_sw_timestamp(msg, sk, &ts);
+	tcp_recv_sw_timestamp(msg, sk, &tss->ts[0]);
 
 	if (sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE)
 		has_timestamping = true;
 	else
-		tss->ts[0] = (struct timespec) {0};
+		tss->ts[0] = (struct timespec64) {0};
 
 	if (tss->ts[2].tv_sec || tss->ts[2].tv_nsec) {
 		if (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)
 			has_timestamping = true;
 		else
-			tss->ts[2] = (struct timespec) {0};
+			tss->ts[2] = (struct timespec64) {0};
 	}
 
 	if (has_timestamping) {
-		tss->ts[1] = (struct timespec) {0};
-		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMPING_OLD,
-			 sizeof(*tss), tss);
+		tss->ts[1] = (struct timespec64) {0};
+		if (sock_flag(sk, SOCK_TSTAMP_NEW))
+			put_cmsg_scm_timestamping64(msg, tss);
+		else
+			put_cmsg_scm_timestamping(msg, tss);
 	}
 }
 
@@ -1963,7 +1964,7 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 	long timeo;
 	struct sk_buff *skb, *last;
 	u32 urg_hole = 0;
-	struct scm_timestamping tss;
+	struct scm_timestamping_internal tss;
 	bool has_tss = false;
 	bool has_cmsg;
 
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 80e2119f1c70..e588305e9cf4 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -280,7 +280,8 @@ static void smc_copy_sock_settings(struct sock *nsk, struct sock *osk,
 			     (1UL << SOCK_RXQ_OVFL) | \
 			     (1UL << SOCK_WIFI_STATUS) | \
 			     (1UL << SOCK_NOFCS) | \
-			     (1UL << SOCK_FILTER_LOCKED))
+			     (1UL << SOCK_FILTER_LOCKED) | \
+			     (1UL << SOCK_TSTAMP_NEW))
 /* copy only relevant settings and flags of SOL_SOCKET level from smc to
  * clc socket (since smc is not called for these options from net/core)
  */
diff --git a/net/socket.c b/net/socket.c
index 96fe831b79ad..d0c018645900 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -731,14 +731,17 @@ static void sock_recv_sw_timestamp(struct msghdr *msg, struct sock *sk,
 			 sizeof(ts), &ts);
 	}
 }
+
 /*
  * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
  */
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
+
 	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
-	struct scm_timestamping tss;
+	struct scm_timestamping_internal tss;
+
 	int empty = 1, false_tstamp = 0;
 	struct skb_shared_hwtstamps *shhwtstamps  		skb_hwtstamps(skb);
@@ -755,20 +758,22 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 	memset(&tss, 0, sizeof(tss));
 	if ((sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) &&
-	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
+	    ktime_to_timespec64_cond(skb->tstamp, tss.ts + 0))
 		empty = 0;
 	if (shhwtstamps &&
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
 	    !skb_is_swtx_tstamp(skb, false_tstamp) &&
-	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
+	    ktime_to_timespec64_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
 		empty = 0;
 		if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_PKTINFO) &&
 		    !skb_is_err_queue(skb))
 			put_ts_pktinfo(msg, skb);
 	}
 	if (!empty) {
-		put_cmsg(msg, SOL_SOCKET,
-			 SO_TIMESTAMPING_OLD, sizeof(tss), &tss);
+		if (sock_flag(sk, SOCK_TSTAMP_NEW))
+			put_cmsg_scm_timestamping64(msg, &tss);
+		else
+			put_cmsg_scm_timestamping(msg, &tss);
 
 		if (skb_is_err_queue(skb) && skb->len &&
 		    SKB_EXT_ERR(skb)->opt_stats)
-- 
2.17.1
