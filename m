From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Wed, 16 Jan 2002 19:29:33 +0000
Subject: RE: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805856@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike,

I just tested this functionality last week on a Lion.  Using the ISC DHCP
3.0 with the attached patch I was able to remotely install and boot Lion
systems.  I used the tftpd that comes with Redhat 7.2 as well...

I hope this helps..

matt

diff -ruN ../dhcp-3.0/Makefile.conf ./Makefile.conf
--- ../dhcp-3.0/Makefile.conf	Tue Jun 26 11:31:36 2001
+++ ./Makefile.conf	Fri Oct  5 10:19:10 2001
@@ -286,7 +286,8 @@
 ## Linux 2.0
 ##--linux-2.0--
 #COPTS = -DLINUX_MAJOR=$(MAJORVERSION) -DLINUX_MINOR=$(MINORVERSION) \
-#        $(BINDDEF) $(CC_OPTIONS)
+#        $(BINDDEF) $(CC_OPTIONS) -DDLL
+#LIBS = -ldl
 #CF = cf/linux.h
 #ADMMANDIR = /usr/man/man8
 #ADMMANEXT = .8
@@ -305,7 +306,8 @@
 ## Linux 2.1
 ##--linux-2.1--
 #COPTS = -DLINUX_MAJOR=$(MAJORVERSION) -DLINUX_MINOR=$(MINORVERSION) \
-#        $(BINDDEF) $(CC_OPTIONS)
+#        $(BINDDEF) $(CC_OPTIONS) -DDLL
+#LIBS = -ldl
 #CF = cf/linux.h
 #ADMMANDIR = /usr/man/man8
 #ADMMANEXT = .8
@@ -324,7 +326,8 @@
 ## Linux 2.2
 ##--linux-2.2--
 #COPTS = -DLINUX_MAJOR=$(MAJORVERSION) -DLINUX_MINOR=$(MINORVERSION) \
-#        $(BINDDEF) $(CC_OPTIONS)
+#        $(BINDDEF) $(CC_OPTIONS) -DDLL
+#LIBS = -ldl
 #CF = cf/linux.h
 #ADMMANDIR = /usr/man/man8
 #ADMMANEXT = .8
@@ -421,6 +424,7 @@
 #FFMANEXT = .5
 #LIBMANDIR = /opt/man/man3
 #LIBMANEXT = .3
+#LIBS = -ldl
 #MANCAT = man
 #COPTS=-w3 -Dlint $(BINDDEF)
 #LFLAGS=-l socket
diff -ruN ../dhcp-3.0/client/dhclient.c ./client/dhclient.c
--- ../dhcp-3.0/client/dhclient.c	Wed Aug  8 07:46:14 2001
+++ ./client/dhclient.c	Fri Oct  5 10:16:41 2001
@@ -89,6 +89,12 @@
 
 void do_release(struct client_state *);
 
+/* %%PXE begin */
+int dhcpd_operation = NORMAL;
+int bootserver_operation = 0;
+struct iaddr mcast_discovery_addr = { 0, 0 };
+/* %%PXE end */
+
 int main (argc, argv, envp)
 	int argc;
 	char **argv, **envp;
@@ -335,7 +341,13 @@
 	inaddr_any.s_addr = INADDR_ANY;
 
 	/* Discover all the network interfaces. */
+/* %%PXE begin */
+#if 0
 	discover_interfaces (DISCOVER_UNCONFIGURED);
+#else
+	discover_interfaces(DISCOVER_UNCONFIGURED, 0);
+#endif
+/* %%PXE end */
 
 	/* Parse the dhclient.conf file. */
 	read_client_conf ();
@@ -388,9 +400,16 @@
 	   are relevant should be running, so now we once again call
 	   discover_interfaces(), and this time ask it to actually set
 	   up the interfaces. */
+/* %%PXE begin */
+#if 0
 	discover_interfaces (interfaces_requested
 			     ? DISCOVER_REQUESTED
 			     : DISCOVER_RUNNING);
+#else
+	discover_interfaces((interfaces_requested ?
+		DISCOVER_REQUESTED : DISCOVER_RUNNING), 0);;
+#endif
+/* %%PXE end */
 
 	/* Make up a seed for the random number generator from current
 	   time plus the sum of the last four bytes of each
@@ -2876,7 +2895,13 @@
 	}
 	interface_reference (&interfaces, interface, MDL);
 
+/* %%PXE begin */
+#if 0
 	discover_interfaces (DISCOVER_UNCONFIGURED);
+#else
+	discover_interfaces (DISCOVER_UNCONFIGURED, 0);
+#endif
+/* %%PXE end */
 
 	for (ip = interfaces; ip; ip = ip -> next) {
 		/* If interfaces were specified, don't configure
@@ -2893,10 +2918,18 @@
 					     ip -> client -> alias);
 		script_go (ip -> client);
 	}
-	
+
+/* %%PXE begin */
+#if 0
 	discover_interfaces (interfaces_requested
 			     ? DISCOVER_REQUESTED
 			     : DISCOVER_RUNNING);
+#else
+	discover_interfaces ((interfaces_requested
+			     ? DISCOVER_REQUESTED
+			     : DISCOVER_RUNNING), 0);
+#endif
+/* %%PXE end */
 
 	for (ip = interfaces; ip; ip = ip -> next) {
 		if (ip -> flags & INTERFACE_RUNNING)
diff -ruN ../dhcp-3.0/common/bpf.c ./common/bpf.c
--- ../dhcp-3.0/common/bpf.c	Sun Apr  8 14:12:49 2001
+++ ./common/bpf.c	Fri Oct  5 10:16:41 2001
@@ -183,6 +183,8 @@
    XXX Changes to the filter program may require changes to the constant
    offsets used in if_register_send to patch the BPF program! XXX */
 
+/* %%PXE begin */
+#if 0
 struct bpf_insn dhcp_bpf_filter [] = {
 	/* Make sure this is an IP packet... */
 	BPF_STMT (BPF_LD + BPF_H + BPF_ABS, 12),
@@ -209,6 +211,40 @@
 	/* Otherwise, drop it. */
 	BPF_STMT(BPF_RET+BPF_K, 0),
 };
+#else
+struct bpf_insn dhcp_bpf_filter [] = {
+	/* Make sure this is an IP packet... */
+	BPF_STMT (BPF_LD + BPF_H + BPF_ABS, 12),
+	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, ETHERTYPE_IP, 0, 11),
+
+	/* Make sure it's a UDP packet... */
+	BPF_STMT (BPF_LD + BPF_B + BPF_ABS, 23),
+	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, IPPROTO_UDP, 0, 9),
+
+	/* Make sure this isn't a fragment... */
+	BPF_STMT(BPF_LD + BPF_H + BPF_ABS, 20),
+	BPF_JUMP(BPF_JMP + BPF_JSET + BPF_K, 0x1fff, 7, 0),
+
+	/* Get the IP header length... */
+	BPF_STMT (BPF_LDX + BPF_B + BPF_MSH, 14),
+
+	/* Make sure it's to the right port... */
+	BPF_STMT (BPF_LD + BPF_H + BPF_IND, 16),
+	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, 67, 3, 0),             /* patch
*/
+
+	/* try the PXE unicast port, too... */
+	BPF_STMT (BPF_LDX + BPF_B + BPF_MSH, 14),
+	BPF_STMT (BPF_LD + BPF_H + BPF_IND, 16),
+	BPF_JUMP (BPF_JMP + BPF_JEQ + BPF_K, 4011, 0, 1),
+
+	/* If we passed all the tests, ask for the whole packet. */
+	BPF_STMT(BPF_RET+BPF_K, (u_int)-1),
+
+	/* Otherwise, drop it. */
+	BPF_STMT(BPF_RET+BPF_K, 0),
+};
+#endif
+/* %%PXE end */
 
 #if defined (DEC_FDDI)
 struct bpf_insn *bpf_fddi_filter;
@@ -397,7 +433,15 @@
 #endif /* USE_BPF_SEND */
 
 #ifdef USE_BPF_RECEIVE
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet (interface, buf, len, from, hfrom)
+#else
+ssize_t
+receive_packet(interface, buf, len, from, to, hfrom)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	size_t len;
@@ -490,6 +534,9 @@
 					       interface -> rbuf,
 					       interface -> rbuf_offset,
 					       from,
+/* %%PXE begin */
+						to,
+/* %%PXE end */
 					       (unsigned char *)0,
 					       hdr.bh_caplen);
 
@@ -542,11 +589,25 @@
 	return 1;
 }
 
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback ()
+#else
+void
+maybe_setup_fallback(int bootserver)
+#endif
+/* %%PXE end */
 {
 	isc_result_t status;
 	struct interface_info *fbi = (struct interface_info *)0;
+
+/* %%PXE begin */
+#if 0
 	if (setup_fallback (&fbi, MDL)) {
+#else
+	if (setup_fallback(&fbi, MDL, bootserver)) {
+#endif
+/* %%PXE end */
 		if_register_fallback (fbi);
 		status = omapi_register_io_object ((omapi_object_t *)fbi,
 						   if_readsocket, 0,
diff -ruN ../dhcp-3.0/common/conflex.c ./common/conflex.c
--- ../dhcp-3.0/common/conflex.c	Mon Jun  4 14:18:39 2001
+++ ./common/conflex.c	Fri Oct  5 10:16:41 2001
@@ -558,6 +558,15 @@
 			return BALANCE;
 		if (!strcasecmp (atom + 1, "ound"))
 			return BOUND;
+/* %%PXE begin */
+		if (!strcasecmp(atom + 1, "ootserver")) {
+			return BOOTSERVER;
+		}
+
+		if (!strcasecmp(atom + 1, "ootserver-operation")) {
+			return BOOTSERVER_OPERATION;
+		}
+/* %%PXE end */
 		break;
 	      case 'c':
 		if (!strcasecmp (atom + 1, "ase"))
@@ -646,6 +655,21 @@
 			if (!atom [6])
 				return DEFINE;
 		}
+/* %%PXE begin */
+		if (!strcasecmp(atom + 1, "isable")) {
+			return DISABLE;
+		}
+
+		if (!strcasecmp(atom + 1, "hcpd-operation")) {
+			return DHCPD_OPERATION;
+		}
+
+#ifdef DLL
+		if (!strcasecmp(atom + 1, "ll")) {
+			return TOKEN_DLL;
+		}
+#endif /* DLL */
+/* %%PXE end */
 		break;
 	      case 'e':
 		if (isascii (atom [1]) && tolower (atom [1]) = 'x') {
@@ -801,6 +825,11 @@
 			return MY;
 		if (!strcasecmp (atom + 1, "clt"))
 			return MCLT;
+/* %%PXE begin */
+		if (!strcasecmp(atom + 1, "cast-discovery-addr")) {
+			return MCAST_DISCOVERY_ADDR;
+		}
+/* %%PXE end */
 		break;
 	      case 'n':
 		if (!strcasecmp (atom + 1, "ormal"))
@@ -884,6 +913,11 @@
 			return PICK;
 		if (!strcasecmp (atom + 1, "aused"))
 			return PAUSED;
+/* %%PXE begin */
+		if (!strcasecmp(atom + 1, "roxy")) {
+			return PROXY;
+		}
+/* %%PXE end */
 		break;
 	      case 'r':
 		if (!strcasecmp (atom + 1, "esolution-interrupted"))
diff -ruN ../dhcp-3.0/common/ctrace.c ./common/ctrace.c
--- ../dhcp-3.0/common/ctrace.c	Mon Feb 26 14:21:07 2001
+++ ./common/ctrace.c	Fri Oct  5 10:16:41 2001
@@ -200,6 +200,9 @@
 				 (struct dhcp_packet *)(tip + 1),
 				 len - sizeof *tip,
 				 tip -> from_port,
+/* %%PXE begin */
+				tip->to_port,
+/* %%PXE end */
 				 tip -> from,
 				 (tip -> havehfrom ?
 				  &tip -> hfrom
diff -ruN ../dhcp-3.0/common/dhcp-eval.5 ./common/dhcp-eval.5
--- ../dhcp-3.0/common/dhcp-eval.5	Thu Oct  4 13:40:47 2001
+++ ./common/dhcp-eval.5	Fri Oct  5 10:16:41 2001
@@ -165,6 +165,7 @@
 The \fBexists\fR expression returns true if the specified option
 exists in the incoming DHCP packet being processed.
 .RE
+.PP
 .B known
 .PP
 .RS 0.25i
@@ -172,6 +173,7 @@
 currently being processed is known - that is, if there's a host
 declaration for it.
 .RE
+.PP
 .B static
 .PP
 .RS 0.25i
diff -ruN ../dhcp-3.0/common/discover.c ./common/discover.c
--- ../dhcp-3.0/common/discover.c	Thu Jun 21 09:46:09 2001
+++ ./common/discover.c	Fri Oct  5 10:16:41 2001
@@ -62,10 +62,22 @@
 struct in_addr limited_broadcast;
 struct in_addr local_address;
 
+/* %%PXE begin */
+#if 0
 void (*bootp_packet_handler) PROTO ((struct interface_info *,
 				     struct dhcp_packet *, unsigned,
 				     unsigned int,
 				     struct iaddr, struct hardware *));
+#else
+void (*bootp_packet_handler) PROTO ((struct interface_info *,
+				     struct dhcp_packet *,
+				     unsigned,
+				     unsigned int,
+				     unsigned int,
+				     struct iaddr,
+				     struct hardware *));
+#endif
+/* %%PXE end */
 
 omapi_object_type_t *dhcp_type_interface;
 #if defined (TRACING)
@@ -122,6 +134,10 @@
 {
 	struct interface_info *ip = (struct interface_info *)ipo;
 	ip -> rfdesc = ip -> wfdesc = -1;
+/* %%PXE begin */
+	ip->bootserver = 0;
+	ip->pxe_rfdesc = ip->pxe_wfdesc = -1;
+/* %%PXE end */
 	return ISC_R_SUCCESS;
 }
 
@@ -130,7 +146,28 @@
    register that interface with the network I/O software, figure out what
    subnet it's on, and add it to the list of interfaces. */
 
+/* %%PXE begin */
+int
+if_pxe_readsocket(omapi_object_t *h)
+{
+	struct interface_info *ip;
+
+	if (h->type != dhcp_type_interface) {
+		return -1;
+	}
+
+	ip = (struct interface_info *)h;
+
+	return ip->pxe_rfdesc;
+}
+
+#if 0
 void discover_interfaces (state)
+#else
+void discover_interfaces(state, bootserver)
+	int bootserver;
+#endif
+/* %%PXE end */
 	int state;
 {
 	struct interface_info *tmp, *ip;
@@ -628,6 +665,10 @@
 		tmp -> index = -1;
 
 		/* Register the interface... */
+/* %%PXE begin */
+		tmp->bootserver = bootserver;
+		tmp->pxe_rfdesc = tmp->pxe_wfdesc = -1;
+/* %%PXE end */
 		if_register_receive (tmp);
 		if_register_send (tmp);
 
@@ -642,6 +683,14 @@
 				log_error ("Can't set close-on-exec on %s:
%m",
 					   tmp -> name);
 		}
+
+/* %%PXE begin */
+		if (tmp->pxe_rfdesc != -1) {
+			if (fcntl(tmp->pxe_rfdesc, F_SETFD, 1) < 0) {
+				log_error("Cannot set close-on-exec on PXE
%s: %m", tmp->name);
+			}
+		}
+/* %%PXE end */
 #endif
 	      next:
 		interface_dereference (&tmp, MDL);
@@ -662,6 +711,36 @@
 		if (status != ISC_R_SUCCESS)
 			log_fatal ("Can't register I/O handle for %s: %s",
 				   tmp -> name, isc_result_totext (status));
+
+/* %%PXE begin */
+		{
+			ip = 0;
+			status = interface_allocate(&ip, MDL);
+			if (status != ISC_R_SUCCESS) {
+				log_fatal("Cannott allocate PXE interface
%s: %s",
+					   tmp->name,
isc_result_totext(status));
+			}
+			
+			*ip = *tmp;
+			ip->outer = 0;
+			ip->inner = (void *)ip;
+			ip->rfdesc = ip->pxe_rfdesc;
+			ip->wfdesc = ip->pxe_wfdesc;
+			ip->flags &= ~INTERFACE_RUNNING;
+			ip->bootserver = 2;
+
+			tmp->next = ip;
+			tmp = ip;
+		}
+
+		status = omapi_register_io_object((omapi_object_t *)tmp,
+			if_readsocket, 0, got_one, 0, 0);
+
+		if (status != ISC_R_SUCCESS) {
+			log_fatal("Cannot register PXE I/O handle for %s:
%s",
+				tmp->name, isc_result_totext(status));
+		}
+/* %%PXE end */
 	}
 
 	close (sock);
@@ -673,7 +752,13 @@
 
 	if (!setup_fallback) {
 		setup_fallback = 1;
+/* %%PXE begin */
+#if 0
 		maybe_setup_fallback ();
+#else
+		maybe_setup_fallback(bootserver);
+#endif
+/* %%PXE end */
 	}
 
 #if defined (HAVE_SETFD)
@@ -699,7 +784,13 @@
 	return ip -> rfdesc;
 }
 
+/* %%PXE begin */
+#if 0
 int setup_fallback (struct interface_info **fp, const char *file, int line)
+#else
+int setup_fallback (struct interface_info **fp, const char *file, int line,
int bootserver)
+#endif
+/* %%PXE end */
 {
 	isc_result_t status;
 
@@ -708,6 +799,9 @@
 		log_fatal ("Error allocating fallback interface: %s",
 			   isc_result_totext (status));
 	strcpy (fallback_interface -> name, "fallback");
+/* %%PXE begin */
+	fallback_interface->bootserver = bootserver;
+/* %%PXE end */
 	if (dhcp_interface_setup_hook)
 		(*dhcp_interface_setup_hook) (fallback_interface,
 					      (struct iaddr *)0);
@@ -747,6 +841,9 @@
 		struct dhcp_packet packet;
 	} u;
 	struct interface_info *ip;
+/* %%PXE begin */
+	struct sockaddr_in to;
+/* %%PXE end */
 
 	if (h -> type != dhcp_type_interface)
 		return ISC_R_INVALIDARG;
@@ -754,7 +851,13 @@
 
       again:
 	if ((result +/* %%PXE begin */
+#if 0
 	     receive_packet (ip, u.packbuf, sizeof u, &from, &hfrom)) < 0) {
+#else
+	     receive_packet(ip, u.packbuf, sizeof u, &from, &to, &hfrom)) <
0) {
+#endif
+/* %%PXE end */
 		log_error ("receive_packet failed on %s: %m", ip -> name);
 		return ISC_R_UNEXPECTED;
 	}
@@ -773,8 +876,20 @@
 		ifrom.len = 4;
 		memcpy (ifrom.iabuf, &from.sin_addr, ifrom.len);
 
+/* %%PXE begin */
+#if 0
 		(*bootp_packet_handler) (ip, &u.packet, (unsigned)result,
 					 from.sin_port, ifrom, &hfrom);
+#else
+		(*bootp_packet_handler)(ip,
+					&u.packet,
+					(unsigned)result,
+					from.sin_port,
+					to.sin_port,
+					ifrom,
+					&hfrom);
+#endif
+/* %%PXE end */
 	}
 
 	/* If there is buffered data, read again.    This is for, e.g.,
diff -ruN ../dhcp-3.0/common/dlpi.c ./common/dlpi.c
--- ../dhcp-3.0/common/dlpi.c	Thu Apr  5 13:53:01 2001
+++ ./common/dlpi.c	Fri Oct  5 10:16:41 2001
@@ -613,7 +613,14 @@
 #endif /* USE_DLPI_SEND */
 
 #ifdef USE_DLPI_RECEIVE
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet (interface, buf, len, from, hfrom)
+#else
+ssize_t receive_packet(interface, buf, len, from, to, hfrom)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	size_t len;
@@ -687,8 +694,20 @@
 	bufix += offset;
 	length -= offset;
 #endif
+/* %%PXE begin */
+#if 0
 	offset = decode_udp_ip_header (interface, dbuf, bufix,
 				       from, (unsigned char *)0, length);
+#else
+	offset = decode_udp_ip_header(interface,
+				      dbuf,
+				      bufix,
+				      from,
+				      to,
+				      (unsigned char *)0,
+				      length);
+#endif
+/* %%PXE end */
 
 	/* If the IP or UDP checksum was bad, skip the packet... */
 	if (offset < 0) {
diff -ruN ../dhcp-3.0/common/lpf.c ./common/lpf.c
--- ../dhcp-3.0/common/lpf.c	Mon Apr 23 17:36:00 2001
+++ ./common/lpf.c	Fri Oct  5 10:16:41 2001
@@ -336,7 +336,14 @@
 #endif /* USE_LPF_SEND */
 
 #ifdef USE_LPF_RECEIVE
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet (interface, buf, len, from, hfrom)
+#else
+ssize_t receive_packet(interface, buf, len, from, to, hfrom)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	size_t len;
@@ -368,8 +375,20 @@
 	length -= offset;
 
 	/* Decode the IP and UDP headers... */
+/* %%PXE begin */
+#if 0
 	offset = decode_udp_ip_header (interface, ibuf, bufix, from,
 				       (unsigned char *)0,
(unsigned)length);
+#else
+	offset = decode_udp_ip_header(interface,
+				      ibuf,
+				      bufix,
+				      from,
+				      to,
+				      (unsigned char *)0,
+				      (unsigned)length);
+#endif
+/* %%PXE end */
 
 	/* If the IP or UDP checksum was bad, skip the packet... */
 	if (offset < 0)
@@ -401,11 +420,24 @@
 	return 1;
 }
 
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback ()
+#else
+void maybe_setup_fallback(int bootserver)
+#endif
+/* %%PXE end */
 {
 	isc_result_t status;
 	struct interface_info *fbi = (struct interface_info *)0;
+
+/* %%PXE begin */
+#if 0
 	if (setup_fallback (&fbi, MDL)) {
+#else
+	if (setup_fallback(&fbi, MDL, bootserver)) {
+#endif
+/* %%PXE end */
 		if_register_fallback (fbi);
 		status = omapi_register_io_object ((omapi_object_t *)fbi,
 						   if_readsocket, 0,
diff -ruN ../dhcp-3.0/common/nit.c ./common/nit.c
--- ../dhcp-3.0/common/nit.c	Sat Feb 17 13:17:25 2001
+++ ./common/nit.c	Fri Oct  5 10:16:41 2001
@@ -347,7 +347,14 @@
 #endif /* USE_NIT_SEND */
 
 #ifdef USE_NIT_RECEIVE
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet (interface, buf, len, from, hfrom)
+#else
+ssize_t receive_packet(interface, buf, len, from, to, hfrom)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	size_t len;
@@ -378,8 +385,20 @@
 	length -= offset;
 
 	/* Decode the IP and UDP headers... */
+/* %%PXE begin */
+#if 0
 	offset = decode_udp_ip_header (interface, ibuf, bufix,
 				       from, (unsigned char *)0, length);
+#else
+	offset = decode_udp_ip_header(interface,
+				      ibuf,
+				      bufix,
+				      from,
+				      to,
+				      (unsigned char *)0,
+				      length);
+#endif
+/* %%PXE end */
 
 	/* If the IP or UDP checksum was bad, skip the packet... */
 	if (offset < 0)
diff -ruN ../dhcp-3.0/common/options.c ./common/options.c
--- ../dhcp-3.0/common/options.c	Thu Aug 23 09:11:34 2001
+++ ./common/options.c	Fri Oct  5 10:16:41 2001
@@ -162,6 +162,19 @@
 			return 0;
 		}
 
+/* %%PXE begin */
+		if (universe->is_vendor) {
+			/*
+			 * When parsing (or trying to parse) vendor option
+			 * space; if we do not know what the option is,
+			 * just skip it and say everything is kosher.
+			 */
+			if (!universe->options[code]) {
+				return 1;
+			}
+		}
+/* %%PXE end */
+
 		/* If the option contains an encapsulation, parse it.   If
 		   the parse fails, or the option isn't an encapsulation (by
 		   far the most common case), or the option isn't entirely
@@ -175,6 +188,37 @@
 		    save_option_buffer (universe, options, bp,
 					&bp -> data [offset + 2], len,
 					universe -> options [code], 1);
+
+/* %%PXE begin */
+			/*
+			 * This is probably very PXE specific and there is
+			 * probably a better way to do this, but this hack
+			 * seems to work.  Basically, if we are paring the
+			 * DHCP options and we find a vendor encapsulated
+			 * option, send it back through the option parser
+			 * for every vendor option space that exists.
+			 */
+			if (universe = &dhcp_universe &&
+				code = DHO_VENDOR_ENCAPSULATED_OPTIONS)
+			{
+				unsigned n;
+
+				for (n = 0; n < universe_count; ++n) {
+					if (!universes[n]->is_vendor) {
+						continue;
+					}
+
+					if (!parse_option_buffer(
+						options,
+						&bp->data[offset+2],
+						len,
+						universes[n]))
+					{
+						return 0;
+					}	
+				}
+			}
+/* %%PXE end */
 		}
 		offset += len + 2;
 	}
@@ -506,6 +550,10 @@
 	priority_list [priority_len++] = DHO_DHCP_MESSAGE_TYPE;
 	priority_list [priority_len++] = DHO_DHCP_SERVER_IDENTIFIER;
 	priority_list [priority_len++] = DHO_DHCP_LEASE_TIME;
+/* %%PXE begin */
+	priority_list [priority_len++] = DHO_DHCP_RENEWAL_TIME;
+	priority_list [priority_len++] = DHO_DHCP_REBINDING_TIME;
+/* %%PXE end */
 	priority_list [priority_len++] = DHO_DHCP_MESSAGE;
 	priority_list [priority_len++] = DHO_DHCP_REQUESTED_ADDRESS;
 
@@ -607,8 +655,15 @@
 				     inpacket, lease, client_state,
 				     in_options, cfg_options, scope,
 				     priority_list, priority_len,
+/* %%PXE begin */
+#if 0
 				     main_buffer_size,
 				     (main_buffer_size +
+#else
+				     (main_buffer_size - 7),
+				     ((main_buffer_size - 7) +
+#endif
+/* %%PXE end */
 				      ((overload & 1) ? DHCP_FILE_LEN : 0)),
 				     terminate, vuname);
 
@@ -696,6 +751,40 @@
 
 /* Store all the requested options into the requested buffer. */
 
+/* %%PXE begin */
+/* Used to qsort() vendor-encapsulated-options by size. */
+
+struct s_optcmp {
+	unsigned ix;
+	int len;
+};
+
+int
+_optcmp(const void *left, const void *right)
+{
+	int s;
+
+	/* Sort first by size.  Longer options are first in list.
+	 */
+	s = ((struct s_optcmp *)left)->len - ((struct s_optcmp
*)right)->len;
+
+	if (s < 0) {
+		return 1;
+	} else if (s > 0) {
+		return -1;
+	}
+
+	/* If options are same length, sort by location.  If the
+	 * option came first, it is still first.
+	 */
+	if (((struct s_optcmp *)left)->ix < ((struct s_optcmp *)right)->ix)
{
+		return 1;
+	} else {
+		return -1;
+	}	
+}
+/* %%PXE end */
+
 int store_options (buffer, buflen, packet, lease, client_state,
 		   in_options, cfg_options, scope, priority_list,
priority_len,
 		   first_cutoff, second_cutoff, terminate, vuname)
@@ -756,7 +845,31 @@
 
 	    /* Code for next option to try to store. */
 	    code = priority_list [i];
-	    
+
+/* %%PXE begin */
+		if (lease) {
+			if (lease->flags & PXE_LEASE) {
+				switch (code) {
+					case DHO_DHCP_LEASE_TIME:
+					case DHO_DHCP_RENEWAL_TIME:
+					case DHO_DHCP_REBINDING_TIME:
+					continue;
+				}
+			}
+		}
+		
+		if (packet) {
+			if (packet->proxy || packet->bootserver) {
+				switch (code) {
+					case DHO_DHCP_LEASE_TIME:
+					case DHO_DHCP_RENEWAL_TIME:
+					case DHO_DHCP_REBINDING_TIME:
+					continue;
+				}
+			}
+		}
+/* %%PXE end */
+
 	    /* Look up the option in the site option space if the code
 	       is above the cutoff, otherwise in the DHCP option space. */
 	    if (code >= cfg_options -> site_code_min)
@@ -880,7 +993,231 @@
 	    }
 
 	    /* Try to store the option. */
-	    
+
+/* %%PXE begin */
+/* Special check for vendor-encapsulated-options with a total length that
+ * is greater than 255 bytes or that will cross a buffer boundary.  This
+ * is done because the existing PXE clients only know how to parse
+ * sub-options when they are contiguous.  This also means that PXE clients
+ * do not know how to handle a single sub-option that is longer than 255
+ * bytes, but since that really is not defined and is already not handled
+ * cleanly by this code, we are not going to worry about that.
+ *
+ * NOTE - The parse code should barf if a single option or sub-option
+ * exceeds 255 bytes.  Right now it just takes and the option stuffing
+ * code fills the buffer with an invalid length byte.
+ */
+	if (code = DHO_VENDOR_ENCAPSULATED_OPTIONS && (length > 255 ||
+		(bufix < first_cutoff && bufix + length > first_cutoff) ||
+		(bufix < second_cutoff && bufix + length > second_cutoff)))
+	{
+		struct s_optcmp *subcmp;
+		unsigned subcnt;  /* number of sub-options */
+		unsigned subix;   /* index into subcmp[] array */
+		unsigned left;    /* space left in buffer */
+
+		/* Skip into next buffer if we are right on a buffer
+		 * boundary.  If this would cause our option to go
+		 * past the end of the buffer, skip it.
+		 */
+		optstart = bufix;
+
+		if (optstart < first_cutoff && first_cutoff - optstart < 5)
{
+			optstart = first_cutoff;
+		}
+
+		if (optstart < second_cutoff && second_cutoff - optstart <
5) {
+			optstart = second_cutoff;
+		}
+
+		if (optstart + 2 + length > buflen) {
+			/* Option would go past end of buffer, skip it.
+			 */
+	    		data_string_forget (&od, MDL);
+			return bufix;
+		}
+
+		/* Count number of sub-options in the option.
+		 */
+		for (subcnt = 0, ix = 0; ix < length; ) {
+			++subcnt;
+
+			switch (od.data[ix]) {
+			case 0:
+			case 255:
+				++ix;
+				break;
+
+			default:
+				ix += 2 + od.data[ix + 1];
+			}
+		}
+
+		/* Allocate buffer to hold starting position and length
+		 * of each sub-option.
+		 */
+		if (!(subcmp = calloc(subcnt, sizeof(struct s_optcmp)))) {
+			/* Craps.  Skip this option.
+			 */
+	    		data_string_forget (&od, MDL);
+			return bufix;
+		}
+
+		/* Get the starting positions of each sub-option.
+		 */
+		for (subix = 0, ix = 0; ix < length; ) {
+			if (subix = subcnt) {
+				/* We had more sub-options the second time
+				 * through the option?!?  Craps.  Skip it.
+				 */
+				free(subcmp);
+	    			data_string_forget (&od, MDL);
+				return bufix;
+			}
+
+			/* Keep track of starting position and length.
+			 */
+			subcmp[subix].ix = ix;
+
+			switch (od.data[ix]) {
+			case 0:
+			case 255:
+				subcmp[subix].len = 1;
+				++ix;
+				break;
+
+			default:
+				subcmp[subix].len = 2 + od.data[ix + 1];
+				ix += 2 + od.data[ix + 1];
+			}
+
+			++subix;
+		}
+
+		/* Now, put our sub-options into the buffer.  Create new
+		 * encapsulating options if the encapsulating option would
+		 * grow past 255 bytes or a sub-option would split across
+		 * buffer boundaries.
+		 */
+		for (;;) {
+			/* Incremented everytime a sub-option gets placed
+			 * into the buffer.
+			 */
+			unsigned placed = 0;
+
+			/* Now sort them from longest sub-option to
shortest.
+			 * End if all options have been placed.
+			 */
+			qsort(subcmp, subcnt, sizeof(struct s_optcmp),
+				&_optcmp);
+
+			if (!subcmp[0].len) {
+				break;
+			}	
+
+			/* So, now we have a list of options sorted by
length.
+			 * Start placing the first encapsulating option.
+			 */
+			buffer[optstart] = code;
+			buffer[optstart + 1] = 0;
+			ix = optstart + 2;
+
+			/* Compute amount of space left before end of
buffer.
+			 */
+			if (ix < first_cutoff) {
+				left = first_cutoff - ix;
+			} else if (ix < second_cutoff) {
+				left = second_cutoff - ix;
+			} else {
+				left = buflen - ix;
+			}
+
+			if (left > 255) {
+				left = 255;
+			}
+
+			/* Place as many sub-options as we can, starting
+			 * with the largest one that will fit.
+			 */
+			for (subix = 0; left && subix < subcnt; ++subix) {
+				/* Skip sub-options that have already been
+				 * placed into the buffer.
+				 */
+				if (!subcmp[subix].len) {
+					continue;
+				}
+
+				/* If this sub-option does not fit here,
+				 * try the next sub-option, it might be
+				 * shorter.
+				 */
+				if (left < subcmp[subix].len) {
+					continue;
+				}
+
+				/* Copy this sub-option into the buffer.
+				 */
+				memcpy(&buffer[ix], 
+					&od.data[subcmp[subix].ix],
+					subcmp[subix].len);
+
+				/* Update length of encapsulating option,
+				 * buffer index and space left.
+				 */
+				buffer[optstart + 1] += subcmp[subix].len;
+				ix += subcmp[subix].len;	
+				left -= subcmp[subix].len;
+
+				/* Mark this sub-option placed.
+				 */
+				subcmp[subix].len = 0;
+				++placed;
+			}
+
+			if (!placed) {
+				/* No options were placed, wipe out the
+				 * encapsulating option code in the buffer.
+				 */
+				buffer[optstart] = 0;
+			} else {	
+				/* Options were placed, update the option
+				 * start index.
+				 */
+				optstart = ix;
+			}
+
+			/* Possibly update the option start index again.
+			 * If we are near the end of a buffer or if nothing
+			 * got placed in the current buffer, skip to the
+			 * beginning of the next buffer.  When the last
+			 * buffer is skipped, we are done.
+			 */
+			if (optstart < first_cutoff) {
+				if (!placed || first_cutoff - optstart < 5)
{
+					optstart = first_cutoff;
+				}
+			} else if (optstart < second_cutoff) {
+				if (!placed || second_cutoff - optstart < 5)
{
+					optstart = second_cutoff;
+				}
+			} else {
+				/* If we finish the third buffer, we are
+				 * as done as we are gonna get.
+				 */
+				break;
+			}	
+		}
+
+		/* Done w/ sub-options.  Free up storage and return
+		 * updated buffer index.
+		 */
+		free(subcmp);
+	    	data_string_forget (&od, MDL);
+
+		return bufix = optstart;
+	}
+/* %%PXE end */
+
 	    /* If the option's length is more than 255, we must store it
 	       in multiple hunks.   Store 255-byte hunks first.  However,
 	       in any case, if the option data will cross a buffer
@@ -2128,7 +2465,14 @@
 	}
 }
 
+/* %%PXE begin */
+#if 0
 void do_packet (interface, packet, len, from_port, from, hfrom)
+#else
+void do_packet(interface, packet, len, from_port, to_port, from, hfrom)
+	unsigned int to_port;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	struct dhcp_packet *packet;
 	unsigned len;
@@ -2158,7 +2502,10 @@
 	decoded_packet -> client_addr = from;
 	interface_reference (&decoded_packet -> interface, interface, MDL);
 	decoded_packet -> haddr = hfrom;
-	
+/* %%PXE begin */
+	decoded_packet->server_port = to_port;
+/* %%PXE end */
+
 	if (packet -> hlen > sizeof packet -> chaddr) {
 		packet_dereference (&decoded_packet, MDL);
 		log_info ("Discarding packet with bogus hlen.");
diff -ruN ../dhcp-3.0/common/packet.c ./common/packet.c
--- ../dhcp-3.0/common/packet.c	Thu May 31 12:28:51 2001
+++ ./common/packet.c	Fri Oct  5 10:16:41 2001
@@ -170,7 +170,13 @@
 	*bufix += sizeof ip;
 
 	/* Fill out the UDP header */
+/* %%PXE begin */
+#if 0
 	udp.uh_sport = local_port;		/* XXX */
+#else
+	udp.uh_sport = (port = htons((short)4011)) ? port : local_port;
+#endif
+/* %%PXE end */
 	udp.uh_dport = port;			/* XXX */
 	udp.uh_ulen = htons(sizeof(udp) + len);
 	memset (&udp.uh_sum, 0, sizeof udp.uh_sum);
@@ -219,7 +225,14 @@
 
 /* UDP header and IP header decoded together for convenience. */
 
+/* %%PXE begin */
+#if 0
 ssize_t decode_udp_ip_header (interface, buf, bufix, from, data, buflen)
+#else
+ssize_t decode_udp_ip_header(interface, buf, bufix, from, to, data, buflen)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	unsigned bufix;
@@ -286,6 +299,10 @@
   /* Copy out the IP source address... */
   memcpy (&from -> sin_addr, &ip -> ip_src, 4);
 
+/* %%PXE begin */
+	memcpy(&to->sin_addr, &ip->ip_dst, 4);
+/* %%PXE end */
+
   /* Compute UDP checksums, including the ``pseudo-header'', the UDP
      header and the data.   If the UDP checksum field is zero, we're
      not supposed to do a checksum. */
@@ -342,6 +359,10 @@
 
   /* Copy out the port... */
   memcpy (&from -> sin_port, &udp -> uh_sport, sizeof udp -> uh_sport);
+
+/* %%PXE begin */
+	memcpy(&to->sin_port, &udp->uh_dport, sizeof udp->uh_dport);
+/* %%PXE end */
 
   return ip_len + sizeof *udp;
 }
diff -ruN ../dhcp-3.0/common/parse.c ./common/parse.c
--- ../dhcp-3.0/common/parse.c	Tue Jun 26 11:33:32 2001
+++ ./common/parse.c	Fri Oct  5 10:16:41 2001
@@ -48,6 +48,10 @@
 
 #include "dhcpd.h"
 
+/* %%PXE begin */
+#include <dlfcn.h>
+/* %%PXE end */
+
 /* Enumerations can be specified in option formats, and are used for
    parsing, so we define the routines that manage them here. */
 
@@ -980,6 +984,10 @@
 		log_fatal ("Can't allocate %s option hash table.", nu ->
name);
 	universe_hash_add (universe_hash, nu -> name, 0, nu, MDL);
 	parse_semi (cfile);
+
+/* %%PXE begin */
+	nu->is_vendor = 1;
+/* %%PXE end */
 }
 
 /* This is faked up to look good right now.   Ideally, this should do a
@@ -1031,7 +1039,10 @@
 	int is_signed;
 	char *s;
 	int has_encapsulation = 0;
-	
+/* %%PXE begin */
+	int  array_in_array = 0;
+/* %%PXE end */
+
 	/* Parse the option code. */
 	token = next_token (&val, (unsigned *)0, cfile);
 	if (token != NUMBER) {
@@ -1077,7 +1088,13 @@
 
 	switch (token) {
 	      case ARRAY:
+/* %%PXE begin */
+#if 0
 		if (arrayp) {
+#else
+		if (arrayp && recordp && array_in_array) {
+#endif
+/* %%PXE end */
 			parse_warn (cfile, "no nested arrays.");
 			skip_to_rbrace (cfile, recordp);
 			if (recordp)
@@ -1099,6 +1116,9 @@
 			skip_to_semi (cfile);
 			return 0;
 		}
+/* %%PXE begin */
+		array_in_array = no_more_in_record = 1;
+/* %%PXE end */
 		goto next_type;
 	      case BOOLEAN:
 		type = 'f';
@@ -1158,7 +1178,13 @@
 	      case TEXT:
 		type = 't';
 	      no_arrays:
+/* %%PXE begin */
+#if 0
 		if (arrayp) {
+#else
+		if (arrayp && array_in_array) {
+#endif
+/* %%PXE end */
 			parse_warn (cfile, "arrays of text strings not %s",
 				    "yet supported.");
 			skip_to_rbrace (cfile, recordp);
@@ -1166,7 +1192,11 @@
 				skip_to_semi (cfile);
 			return 0;
 		}
+/* %%PXE begin */
+#if 0
 		no_more_in_record = 1;
+#endif
+/* %%PXE end */
 		break;
 	      case STRING_TOKEN:
 		type = 'X';
@@ -1222,6 +1252,11 @@
 		}
 		if (token = COMMA) {
 			if (no_more_in_record) {
+/* %%PXE begin */
+				if (arrayp && array_in_array)
+					parse_warn(cfile, "array must be at
end of record.");
+				else
+/* %%PXE end */
 				parse_warn (cfile,
 					    "%s must be at end of record.",
 					    type = 't' ? "text" :
"string");
@@ -1257,6 +1292,9 @@
 		has_encapsulation = 0;
 	s = dmalloc (tokix +
 		     (arrayp ? 1 : 0) +
+/* %%PXE begin */
+			(array_in_array ? 1 : 0) +
+/* %%PXE end */
 		     (has_encapsulation ? 1 : 0) + 1, MDL);
 	if (!s)
 		log_fatal ("no memory for option format.");
@@ -1264,6 +1302,11 @@
 		s [0] = 'e';
 	memcpy (s + has_encapsulation, tokbuf, tokix);
 	tokix += has_encapsulation;
+/* %%PXE begin */
+	if (arrayp && array_in_array) {
+		s[tokix++] = 'a';
+	}
+/* %%PXE end */
 	if (arrayp)
 		s [tokix++] = (arrayp > recordp) ? 'a' : 'A';
 	s [tokix] = 0;
@@ -2656,6 +2699,11 @@
 
 	if (!is_boolean_expression (*expr) &&
 	    (*expr) -> op != expr_variable_reference &&
+/* %%PXE begin */
+#ifdef DLL
+		(*expr)->op != expr_dll &&
+#endif /* DLL */
+/* %%PXE end */
 	    (*expr) -> op != expr_funcall) {
 		parse_warn (cfile, "Expecting a boolean expression.");
 		*lose = 1;
@@ -2693,6 +2741,11 @@
 
 	if (!is_data_expression (*expr) &&
 	    (*expr) -> op != expr_variable_reference &&
+/* %%PXE begin */
+#ifdef DLL
+		(*expr)->op != expr_dll &&
+#endif /* DLL */
+/* %%PXE end */
 	    (*expr) -> op != expr_funcall) {
 		parse_warn (cfile, "Expecting a data expression.");
 		*lose = 1;
@@ -2719,6 +2772,11 @@
 
 	if (!is_numeric_expression (*expr) &&
 	    (*expr) -> op != expr_variable_reference &&
+/* %%PXE begin */
+#ifdef DLL
+		(*expr)->op != expr_dll &&
+#endif /* DLL */
+/* %%PXE end */
 	    (*expr) -> op != expr_funcall) {
 		parse_warn (cfile, "Expecting a numeric expression.");
 		*lose = 1;
@@ -2753,6 +2811,11 @@
 
 	if (!is_dns_expression (*expr) &&
 	    (*expr) -> op != expr_variable_reference &&
+/* %%PXE begin */
+#ifdef DLL
+		(*expr)->op != expr_dll &&
+#endif /* DLL */
+/* %%PXE end */
 	    (*expr) -> op != expr_funcall) {
 		parse_warn (cfile, "Expecting a dns update subexpression.");
 		*lose = 1;
@@ -3819,6 +3882,164 @@
 		if (token != RPAREN)
 			goto norparen;
 		break;
+
+/* %%PXE begin */
+		case PROXY:
+	      		token = next_token(&val, (unsigned *)0, cfile);
+			if (!expression_allocate(expr, MDL)) {
+				log_fatal("can't allocate expression");
+			}
+
+			(*expr)->op = expr_proxy;
+			break;
+
+		case BOOTSERVER:
+	      		token = next_token(&val, (unsigned *)0, cfile);
+			if (!expression_allocate(expr, MDL)) {
+				log_fatal("can't allocate expression");
+			}
+
+			(*expr)->op = expr_bootserver;
+			break;
+
+#ifdef DLL
+		case TOKEN_DLL:
+			/* Skip 'dll' token. */
+			token = next_token(&val, (unsigned *)0, cfile);
+
+			/* Allocate expression storage. */
+			if (!expression_allocate(expr, MDL)) {
+				log_fatal("can't allocate expression");
+			}
+
+			(*expr)->op = expr_dll;
+
+			/* Need left parenthesis. */
+			if ((token = next_token(&val, (unsigned *)0, cfile))
!= LPAREN) {
+				parse_warn(cfile, "expecting left
parenthesis.");
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			/* Need DLL library name. */
+			if ((token = next_token(&val, (unsigned *)0, cfile))
!= STRING) {
+				parse_warn(cfile, "expecting DLL library
name.");
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			if (!((*expr)->data.dll.libname +				dmalloc(strlen(val) + 1, MDL)))
+			{
+				log_fatal("cannot allocate DLL library
name");
+			}
+
+			strcpy((*expr)->data.dll.libname, val);
+
+			/* Open DLL library. */
+			(*expr)->data.dll.libhnd +				dlopen((*expr)->data.dll.libname, RTLD_NOW);
+
+			if (val = dlerror()) {
+				parse_warn(cfile, val);
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			/* Need comma. */
+			if ((token = next_token(&val, (unsigned *)0, cfile))
!= COMMA) {
+				parse_warn(cfile, "expecting comma.");
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			/* Need DLL function name. */
+			if ((token = next_token(&val, (unsigned *)0, cfile))
!= STRING) {
+				parse_warn(cfile, "expecting DLL function
name.");
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			if (!((*expr)->data.dll.funcname +				dmalloc(strlen(val) + 1, MDL)))
+			{
+				log_fatal("cannot allocate DLL function
name");
+			}
+
+			strcpy((*expr)->data.dll.funcname, val);
+
+			/* Load DLL function. */
+			(*expr)->data.dll.funcptr +				dlsym((*expr)->data.dll.libhnd,
+					(*expr)->data.dll.funcname);
+
+			if (val = dlerror()) {
+				parse_warn(cfile, val);
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			/* Parse function call parameters. */
+			(*expr)->data.dll.argcnt = 0;
+			ep = &(*expr)->data.dll.arglist;
+
+			while ((token = next_token(&val, (unsigned *)0,
cfile)) = COMMA) {
+				if (!expression_allocate(ep, MDL)) {
+					log_fatal("cannot allocate
expression");
+				}
+
+				(*ep)->op = expr_arg;
+
+				if (!parse_expression(&(*ep)->data.arg.val,
+					cfile, lose, context_any,
+					(struct expression **)0, expr_none))
+				{
+					if (!*lose) {
+						parse_warn(cfile, "expecting
expression.");
+						*lose = 1;
+					}
+
+					skip_to_semi(cfile);
+					expression_dereference(ep, MDL);
+					return 0;
+				}
+
+				++(*expr)->data.dll.argcnt;
+
+				ep = &((*ep)->data.arg.next);
+			}
+
+			/* Need right parenthesis. */
+			if (token != RPAREN) {
+				parse_warn(cfile, "expecting right
parenthesis.");
+				*lose = 1;
+
+				skip_to_semi(cfile);
+				expression_dereference(expr, MDL);
+				return 0;
+			}
+
+			break;
+#endif /* DLL */
+/* %%PXE end */
 
 		/* Not a valid start to an expression... */
 	      default:
diff -ruN ../dhcp-3.0/common/print.c ./common/print.c
--- ../dhcp-3.0/common/print.c	Wed Aug  8 07:49:20 2001
+++ ./common/print.c	Fri Oct  5 10:16:41 2001
@@ -1001,6 +1001,17 @@
 			buf [rv++] = 0;
 			return rv;
 		}
+/* %%PXE begin */
+			break;
+
+		case expr_proxy:
+			s = "proxy";
+			break;
+
+		case expr_bootserver:
+			s = "bootserver";
+			break;
+/* %%PXE end */
 	}
 	return 0;
 }
diff -ruN ../dhcp-3.0/common/socket.c ./common/socket.c
--- ../dhcp-3.0/common/socket.c	Fri Sep 29 18:24:55 2000
+++ ./common/socket.c	Fri Oct  5 10:16:41 2001
@@ -151,13 +151,73 @@
 
 #if defined (HAVE_SO_BINDTODEVICE)
 	/* Bind this socket to this interface. */
-	if (info -> ifp &&
-	    setsockopt (sock, SOL_SOCKET, SO_BINDTODEVICE,
-			(char *)(info -> ifp), sizeof *(info -> ifp)) < 0) {
-		log_fatal ("setsockopt: SO_BINDTODEVICE: %m");
+	if (info->ifp) {
+		if (setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE,
+			(char *)(info->ifp), sizeof *(info->ifp)) < 0)
+		{
+			log_fatal("setsockopt: SO_BINDTODEVICE: %m");
+		}
 	}
 #endif
 
+/* %%PXE begin */
+	if (info->bootserver) {
+		struct ip_mreq ipmreq;
+
+		name.sin_port = htons(4011);
+
+		info->pxe_rfdesc = info->pxe_wfdesc +			socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
+
+		if (info->pxe_rfdesc < 0) {
+			log_fatal("Cannot create PXE socket: %m");
+		}
+
+		flag = 1;
+
+		if (setsockopt(info->pxe_rfdesc, SOL_SOCKET, SO_REUSEADDR,
+			(char *)&flag, sizeof flag) < 0)
+		{
+			log_fatal("Cannot set SO_REUSEADDR option on PXE
socket: %m");
+		}
+
+		if (bind(info->pxe_rfdesc, (struct sockaddr *)&name,
+			sizeof name) < 0)
+		{
+			log_fatal("Can't bind to PXE address: %m");
+		}
+
+		if (mcast_discovery_addr.len) {
+			memcpy(&ipmreq.imr_multiaddr,
+				mcast_discovery_addr.iabuf,
+				sizeof ipmreq.imr_multiaddr);
+
+			memcpy(&ipmreq.imr_interface,
+				&info->primary_address,
+				sizeof ipmreq.imr_interface);
+
+			if (setsockopt(info->pxe_rfdesc, IPPROTO_IP,
+				IP_ADD_MEMBERSHIP, (char *)&ipmreq,
+				sizeof ipmreq) < 0)
+			{
+				log_error("Cannot join multicast session:
%m");
+			}
+		}
+
+#if defined (HAVE_SO_BINDTODEVICE)
+	/* Bind this socket to this interface. */
+	if (info->ifp) {
+		if (setsockopt(info->pxe_rfdesc, SOL_SOCKET,
SO_BINDTODEVICE,
+			(char *)(info->ifp), sizeof *(info->ifp)) < 0)
+		{
+			log_fatal("setsockopt: SO_BINDTODEVICE: pxe %m");
+		}
+	}
+#endif
+
+	}
+/* %%PXE end */
+
 	return sock;
 }
 #endif /* USE_SOCKET_SEND || USE_SOCKET_RECEIVE || USE_SOCKET_FALLBACK */
@@ -248,8 +308,31 @@
 	int retry = 0;
 	do {
 #endif
+/* %%PXE begin */
+#if 0
 		result = sendto (interface -> wfdesc, (char *)raw, len, 0,
 				 (struct sockaddr *)to, sizeof *to);
+#else
+		if (to->sin_port = htons((short)4011) &&
+			interface->pxe_wfdesc != -1)
+		{
+			result = sendto(interface->pxe_wfdesc,
+					(char *)raw,
+					len,
+					0,
+					(struct sockaddr *)to,
+					sizeof *to);
+		} else {
+			result = sendto(interface->wfdesc,
+					(char *)raw,
+					len,
+					0,
+					(struct sockaddr *)to,
+					sizeof *to);
+		}
+#endif
+/* %%PXE end */
+
 #ifdef IGNORE_HOSTUNREACH
 	} while (to -> sin_addr.s_addr = htonl (INADDR_BROADCAST) &&
 		 result < 0 &&
@@ -268,7 +351,15 @@
 #endif /* USE_SOCKET_SEND || USE_SOCKET_FALLBACK */
 
 #ifdef USE_SOCKET_RECEIVE
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet (interface, buf, len, from, hfrom)
+#else
+ssize_t
+receive_packet(interface, buf, len, from, to, hfrom)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	size_t len;
@@ -284,6 +375,17 @@
 #endif
 		result = recvfrom (interface -> rfdesc, (char *)buf, len, 0,
 				   (struct sockaddr *)from, &flen);
+
+/* %%PXE begin */
+		if (to) {
+			if (interface->rfdesc != interface->pxe_rfdesc) {
+				to->sin_port = local_port;
+			} else {
+				to->sin_port = htons(4011);
+			}
+		}
+/* %%PXE end */
+
 #ifdef IGNORE_HOSTUNREACH
 	} while (result < 0 &&
 		 (errno = EHOSTUNREACH ||
@@ -350,14 +452,29 @@
 /* If we have SO_BINDTODEVICE, set up a fallback interface; otherwise,
    do not. */
 
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback ()
+#else
+void
+maybe_setup_fallback(int bootserver)
+#endif
+/* %%PXE end */
 {
 #if defined (USE_SOCKET_FALLBACK)
 	isc_result_t status;
 	struct interface_info *fbi = (struct interface_info *)0;
+
+/* %%PXE begin */
+#if 0
 	if (setup_fallback (&fbi, MDL)) {
+#else
+	if (setup_fallback(&fbi, MDL, bootserver)) {
+#endif
+/* %%PXE end */
 		fbi -> wfdesc = if_register_socket (fbi);
 		fbi -> rfdesc = fbi -> wfdesc;
+
 		log_info ("Sending on   Socket/%s%s%s",
 		      fbi -> name,
 		      (fbi -> shared_network ? "/" : ""),
@@ -370,6 +487,7 @@
 		if (status != ISC_R_SUCCESS)
 			log_fatal ("Can't register I/O handle for %s: %s",
 				   fbi -> name, isc_result_totext (status));
+
 		interface_dereference (&fbi, MDL);
 	}
 #endif
diff -ruN ../dhcp-3.0/common/tables.c ./common/tables.c
--- ../dhcp-3.0/common/tables.c	Thu Jun 21 16:50:51 2001
+++ ./common/tables.c	Fri Oct  5 10:16:41 2001
@@ -1180,6 +1180,9 @@
 				 dhcp_options [i].name, 0,
 				 &dhcp_options [i], MDL);
 	}
+/* %%PXE begin */
+	dhcp_universe.is_vendor = 0;
+/* %%PXE end */
 
 	/* Set up the Novell option universe (for option 63)... */
 	nwip_universe.name = "nwip";
@@ -1207,6 +1210,9 @@
 				 nwip_options [i].name, 0,
 				 &nwip_options [i], MDL);
 	}
+/* %%PXE begin */
+	nwip_universe.is_vendor = 0;
+/* %%PXE end */
 
 	/* Set up the FQDN option universe... */
 	fqdn_universe.name = "fqdn";
@@ -1234,6 +1240,9 @@
 				 fqdn_options [i].name, 0,
 				 &fqdn_options [i], MDL);
 	}
+/* %%PXE begin */
+	fqdn_universe.is_vendor = 0;
+/* %%PXE end */
 
 	/* Set up the hash of universes. */
 	universe_hash = new_hash (0, 0, 1, MDL);
diff -ruN ../dhcp-3.0/common/tree.c ./common/tree.c
--- ../dhcp-3.0/common/tree.c	Thu Oct  4 13:38:22 2001
+++ ./common/tree.c	Fri Oct  5 10:26:23 2001
@@ -444,8 +444,9 @@
 	bv = (struct binding_value *)0;
 
 	if (expr -> op = expr_variable_reference) {
-		if (!scope || !*scope)
+		if (!scope || !*scope) {
 			return 0;
+		}
 
 		binding = find_binding (*scope, expr -> data.variable);
 
@@ -455,8 +456,9 @@
 							 binding -> value,
 							 file, line);
 			return 1;
-		} else
+		} else {
 			return 0;
+		}
 	} else if (expr -> op = expr_funcall) {
 		struct string_list *s;
 		struct expression *arg;
@@ -544,6 +546,211 @@
 
 		if (!bv)
 			return 1;
+/* %%PXE begin */
+#ifdef DLL
+	} else if (expr->op = expr_dll) {
+		struct dll_value **arglist;
+		struct dll_value *rval;
+
+		if (!expr->data.dll.libhnd) {
+			log_error("%s: DLL library handle is NULL.",
+				expr->data.dll.libname);
+
+			return 0;
+		}
+
+		if (!expr->data.dll.funcptr) {
+			log_error("%s:%s: DLL function pointer is NULL.",
+				expr->data.dll.libname,
+				expr->data.dll.funcname);
+
+			return 0;
+		}
+
+		if (expr->data.dll.argcnt) {
+			struct expression *e;
+			unsigned n;
+
+			if (!(arglist = dmalloc(expr->data.dll.argcnt *
+				sizeof(struct dll_value *), MDL)))
+			{
+				log_error("%s:%s: Cannot allocate argument
list.",
+					expr->data.dll.libname,
+					expr->data.dll.funcname);
+
+				return 0;
+			}
+
+		/* %%TBD - evaluate arglist */
+			e = expr->data.dll.arglist;
+
+			for (n = 0; n < expr->data.dll.argcnt; ++n) {
+				struct binding_value *b = 0;
+
+				if (!(status = evaluate_expression(&b,
packet,
+					lease, client_state, in_options,
+					cfg_options, scope, e->data.arg.val,
+					file, line)))
+				{
+					log_error("%s:%s: Cannot evaluate
argument %u.",
+						expr->data.dll.libname,
+						expr->data.dll.funcname,
+						n + 1);
+
+					break;
+				}
+
+				switch (b->type) {
+				case binding_boolean:
+					if (!(arglist[n] dmalloc(sizeof(struct dll_value), MDL))) {
+						log_error("%s:%s: Cannot
allocate argument %u.",
+
expr->data.dll.libname,
+
expr->data.dll.funcname,
+							n + 1);
+
+						status = 0;
+						break;
+					}
+
+					arglist[n]->type = dll_type_boolean;
+
+					arglist[n]->value.boolean +						b->value.boolean ? 1 : 0;
+
+					break;
+
+				case binding_numeric:
+					if (!(arglist[n] dmalloc(sizeof(struct dll_value), MDL))) {
+						log_error("%s:%s: Cannot
allocate argument %u.",
+
expr->data.dll.libname,
+
expr->data.dll.funcname,
+							n + 1);
+
+						status = 0;
+						break;
+					}
+
+					arglist[n]->type = dll_type_numeric;
+
+					arglist[n]->value.numeric +						b->value.intval;
+
+					break;
+
+				case binding_data:
+					if (!(arglist[n] dmalloc(sizeof(struct dll_value) + b->value.data.len, MDL))) {
+						log_error("%s:%s: Cannot
allocate argument %u.",
+
expr->data.dll.libname,
+
expr->data.dll.funcname,
+							n + 1);
+
+						status = 0;
+						break;
+					}
+
+					arglist[n]->type = dll_type_data;
+
+					if (arglist[n]->value.data.len b->value.data.len) {
+
memcpy(arglist[n]->value.data.buf, b->value.data.data, b->value.data.len);
+					}
+
+					break;
+
+				default:
+					status = 0;
+				}
+
+				binding_value_dereference(&b, MDL);
+
+				if (!status) {
+					break;
+				}	
+
+				e = e->data.arg.next;
+			}
+		} else {
+			arglist = NULL;
+		}
+
+		if (status) {
+			rval = (expr->data.dll.funcptr)(
+				expr->data.dll.argcnt, (void *)arglist);
+		}
+
+		if (arglist) {
+			unsigned n;
+
+			for (n = 0; n < expr->data.dll.argcnt; ++n) {
+				if (arglist[n]) {
+					dfree(arglist[n], MDL);
+				}
+			}
+
+			dfree(arglist, MDL);
+		}
+
+		if (!status) {
+			return 0;
+		}
+
+		if (!rval) {
+			log_error("%s:%s: DLL function returned NULL.",
+				expr->data.dll.libname,
+				expr->data.dll.funcname);
+
+			return 0;
+		}
+
+		if (!binding_value_allocate(&bv, MDL)) {
+			return 0;
+		}
+
+		switch (rval->type) {
+		case dll_type_boolean:
+			bv->type = binding_boolean;
+			bv->value.boolean = rval->value.boolean;
+			break;
+
+		case dll_type_data:
+			bv->type = binding_data;
+			bv->value.data.len = rval->value.data.len;
+			bv->value.data.terminated = 0;
+
+			if (!buffer_allocate(&bv->value.data.buffer,
+				bv->value.data.len, MDL))
+			{
+				log_error("%s:%s: Could not allocate return
value storage",
+					expr->data.dll.libname,
+					expr->data.dll.funcname);
+
+				status = 0;
+				break;
+			}
+
+			bv->value.data.data = bv->value.data.buffer->data;
+
+			memcpy(bv->value.data.buffer->data,
+				rval->value.data.buf, bv->value.data.len);
+
+			break;
+
+		case dll_type_numeric:
+			bv->type = binding_numeric;
+			bv->value.intval = rval->value.numeric;
+			break;
+
+		default:
+			log_error("%s:%s: DLL function returned bad type:
%u",
+				expr->data.dll.libname,
+				expr->data.dll.funcname,
+				rval->type);
+
+			status = 0;
+		}
+
+		free(rval);
+#endif /* DLL */
+/* %%PXE end */
         } else if (is_boolean_expression (expr)) {
 		if (!binding_value_allocate (&bv, MDL))
 			return 0;
@@ -832,6 +1039,10 @@
 	      case expr_known:
 	      case expr_exists:
 	      case expr_variable_exists:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		log_error ("Boolean opcode in evaluate_dns_expression: %d",
 		      expr -> op);
 		return 0;
@@ -1198,6 +1409,71 @@
 #endif
 		break;
 
+/* %%PXE begin */
+		case expr_proxy:
+			if (!packet) {
+#if defined (DEBUG_EXPRESSIONS)
+				log_debug("bool: NULL->proxy = FALSE");
+#endif
+				return 0;
+			}
+
+#if defined (DEBUG_EXPRESSIONS)
+			log_debug("bool: packet->proxy = %s",
+			  	packet->proxy ? "true" : "false");
+#endif
+
+			*result = packet->proxy;
+			return 1;
+
+		case expr_bootserver:
+			if (!packet) {
+#if defined (DEBUG_EXPRESSIONS)
+				log_debug("bool: NULL->bootserver = FALSE");
+#endif
+				return 0;
+			}
+
+#if defined (DEBUG_EXPRESSIONS)
+			log_debug("bool: packet->bootserver = %s",
+			  	packet->bootserver ? "true" : "false");
+#endif
+
+			*result = packet->bootserver;
+			return 1;
+
+#ifdef DLL
+		case expr_dll:
+			bv = (struct binding_value *)0;
+			sleft = evaluate_expression(&bv, packet, lease,
+				client_state, in_options, cfg_options,
+				scope, expr, MDL);
+
+			if (sleft) {
+				if (bv->type != binding_boolean) {
+					log_error("dll('%s', '%s') returned
type %d in %s.",
+						expr->data.dll.libname,
+						expr->data.dll.funcname,
+						bv->type,
+
"evaluate_boolean_expression");
+				} else {
+					*result = bv -> value.boolean;
+				}
+
+				binding_value_dereference(&bv, MDL);
+			}
+
+#if defined (DEBUG_EXPRESSIONS)
+			log_debug("boolean: dll('%s', '%s') = %s",
+				expr->data.dll.libname,
+				expr->data.dll.funcname,
+			   	sleft ? (*result ? "true" : "false") :
"NULL");
+#endif
+
+			return sleft;
+#endif /* DLL */
+/* %%PXE end */
+
 	      case expr_none:
 	      case expr_match:
 	      case expr_substring:
@@ -2083,6 +2359,10 @@
 	      case expr_none:
 	      case expr_exists:
 	      case expr_variable_exists:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		log_error ("Boolean opcode in evaluate_data_expression: %d",
 		      expr -> op);
 		return 0;
@@ -2161,6 +2441,10 @@
 	      case expr_none:
 	      case expr_exists:
 	      case expr_variable_exists:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		log_error ("Boolean opcode in evaluate_numeric_expression:
%d",
 		      expr -> op);
 		return 0;
@@ -2947,6 +3231,10 @@
 	      case expr_exists:
 	      case expr_known:
 	      case expr_null:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		break;
 
 	      default:
@@ -2976,6 +3264,10 @@
 		expr -> op = expr_or ||
 		expr -> op = expr_not ||
 		expr -> op = expr_known ||
+/* %%PXE begin */
+		expr->op = expr_proxy ||
+		expr->op = expr_bootserver ||
+/* %%PXE end */
 		expr -> op = expr_static);
 }
 
@@ -3098,6 +3390,10 @@
 	      case expr_arg:
 	      case expr_funcall:
 	      case expr_function:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		/* XXXDPN: Need to assign sane precedences to these. */
 	      case expr_binary_and:
 	      case expr_binary_or:
@@ -3192,6 +3488,10 @@
 	      case expr_arg:
 	      case expr_funcall:
 	      case expr_function:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		return context_any;
 
 	      case expr_equal:
@@ -3698,6 +3998,18 @@
 		col = token_print_indent (file, col, indent, "", "", ")");
 		break;
 
+/* %%PXE begin */
+		case expr_proxy:
+			col = token_print_indent(file, col, indent, "", "",
+				"proxy");
+			break;
+
+		case expr_bootserver:
+			col = token_print_indent(file, col, indent, "", "",
+				"bootserver");
+			break;
+/* %%PXE end */
+
 	      default:
 		log_fatal ("invalid expression type in print_expression:
%d",
 			   expr -> op);
@@ -3944,6 +4256,10 @@
 	      case expr_binary_or:
 	      case expr_binary_xor:
 	      case expr_client_state:
+/* %%PXE begin */
+		case expr_proxy:
+		case expr_bootserver:
+/* %%PXE end */
 		return 0;
 	}
 	return 0;
diff -ruN ../dhcp-3.0/common/upf.c ./common/upf.c
--- ../dhcp-3.0/common/upf.c	Fri Sep  1 16:03:39 2000
+++ ./common/upf.c	Fri Oct  5 10:16:41 2001
@@ -299,7 +299,14 @@
 #endif /* USE_UPF_SEND */
 
 #ifdef USE_UPF_RECEIVE
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet (interface, buf, len, from, hfrom)
+#else
+ssize_t receive_packet (interface, buf, len, from, to, hfrom)
+	struct sockaddr_in *to;
+#endif
+/* %%PXE end */
 	struct interface_info *interface;
 	unsigned char *buf;
 	size_t len;
@@ -331,8 +338,20 @@
 	length -= offset;
 
 	/* Decode the IP and UDP headers... */
+/* %%PXE begin */
+#if 0
 	offset = decode_udp_ip_header (interface, ibuf, bufix,
 				       from, (unsigned char *)0, length);
+#else
+	offset = decode_udp_ip_header(interface,
+				      ibuf,
+				      bufix,
+				      from,
+				      to,
+				      (unsigned char *)0,
+				      length);
+#endif
+/* %%PXE end */
 
 	/* If the IP or UDP checksum was bad, skip the packet... */
 	if (offset < 0)
diff -ruN ../dhcp-3.0/dhcpctl/dhcpctl.c ./dhcpctl/dhcpctl.c
--- ../dhcp-3.0/dhcpctl/dhcpctl.c	Sat May 19 00:29:20 2001
+++ ./dhcpctl/dhcpctl.c	Fri Oct  5 10:16:41 2001
@@ -47,6 +47,11 @@
 omapi_object_type_t *dhcpctl_callback_type;
 omapi_object_type_t *dhcpctl_remote_type;
 
+/* %%PXE begin */
+#include "inet.h"
+struct iaddr mcast_discovery_addr = { 0, 0 };
+/* %%PXE end */
+
 /* dhcpctl_initialize ()
 
    Must be called before any other dhcpctl function. */
diff -ruN ../dhcp-3.0/includes/ctrace.h ./includes/ctrace.h
--- ../dhcp-3.0/includes/ctrace.h	Mon Feb 12 13:21:56 2001
+++ ./includes/ctrace.h	Fri Oct  5 10:16:41 2001
@@ -50,6 +50,9 @@
 	u_int32_t index;
 	struct iaddr from;
 	u_int16_t from_port;
+/* %%PXE begin */
+	u_int16_t to_port;
+/* %%PXE end */
 	struct hardware hfrom;
 	u_int8_t havehfrom;
 } trace_inpacket_t;
diff -ruN ../dhcp-3.0/includes/dhcp.h ./includes/dhcp.h
--- ../dhcp-3.0/includes/dhcp.h	Thu Oct  4 15:02:01 2001
+++ ./includes/dhcp.h	Fri Oct  5 10:16:41 2001
@@ -158,6 +158,11 @@
 #define DHO_USER_CLASS			77
 #define DHO_FQDN			81
 #define DHO_DHCP_AGENT_OPTIONS		82
+/* %%PXE begin */
+#define DHO_PXE_CLIENT_ARCHITECTURE	93
+#define DHO_PXE_NETWORK_INTERFACE	94
+#define DHO_PXE_CLIENT_GUID		97
+/* %%PXE end */
 #define DHO_SUBNET_SELECTION		118 /* RFC3011! */
 /* The DHO_AUTHENTICATE option is not a standard yet, so I've
    allocated an option out of the "local" option space for it on a
diff -ruN ../dhcp-3.0/includes/dhcpd.h ./includes/dhcpd.h
--- ../dhcp-3.0/includes/dhcpd.h	Thu Jun 21 16:57:40 2001
+++ ./includes/dhcpd.h	Fri Oct  5 10:16:41 2001
@@ -232,6 +232,11 @@
 
 	int known;
 	int authenticated;
+/* %%PXE begin */
+	int server_port;
+	int proxy;
+	int bootserver;
+/* %%PXE end */
 };
 
 /* A network interface's MAC address. */
@@ -293,7 +298,15 @@
 	unsigned char uid_buf [7];
 	struct hardware hardware_addr;
 
+/* %%PXE begin */
+#if 0
 	u_int8_t flags;
+#else
+	u_int16_t flags;
+#	define PXE_LEASE		512
+#endif
+/* %%PXE end */
+
 #       define STATIC_LEASE		1
 #	define PERSISTENT_FLAGS		(ON_ACK_QUEUE | ON_UPDATE_QUEUE)
 #	define MS_NULL_TERMINATION	8
@@ -777,6 +790,13 @@
 
 	/* Only used by DHCP client code. */
 	struct client_state *client;
+
+/* %%PXE begin */
+	int bootserver;
+	int pxe_rfdesc;
+	int pxe_wfdesc;
+/* %%PXE end */
+
 # if defined (USE_DLPI_SEND) || defined (USE_DLPI_RECEIVE)
 	int dlpi_sap_length;
 	struct hardware dlpi_broadcast_addr;
@@ -1087,9 +1107,21 @@
 void delete_linked_option (struct universe *, struct option_state *, int);
 struct option_cache *lookup_linked_option (struct universe *,
 					   struct option_state *, unsigned);
+/* %%PXE begin */
+#if 0
 void do_packet PROTO ((struct interface_info *,
 		       struct dhcp_packet *, unsigned,
 		       unsigned int, struct iaddr, struct hardware *));
+#else
+void do_packet PROTO ((struct interface_info *,
+		       struct dhcp_packet *,
+		       unsigned,
+		       unsigned int,
+		       unsigned int,
+		       struct iaddr,
+		       struct hardware *));
+#endif
+/* %%PXE end */
 
 /* dhcpd.c */
 extern TIME cur_time;
@@ -1114,6 +1146,12 @@
 isc_result_t dhcp_set_control_state (control_object_state_t oldstate,
 				     control_object_state_t newstate);
 
+/* %%PXE begin */
+extern int dhcpd_operation;
+extern int bootserver_operation;
+extern struct iaddr mcast_discovery_addr;
+/* %%PXE end */
+
 /* conflex.c */
 isc_result_t new_parse PROTO ((struct parse **, int,
 			       char *, unsigned, const char *, int));
@@ -1550,9 +1588,22 @@
 void if_reinitialize_receive PROTO ((struct interface_info *));
 void if_register_receive PROTO ((struct interface_info *));
 void if_deregister_receive PROTO ((struct interface_info *));
+
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet PROTO ((struct interface_info *,
 			       unsigned char *, size_t,
 			       struct sockaddr_in *, struct hardware *));
+#else
+ssize_t receive_packet PROTO ((struct interface_info *,
+			       unsigned char *,
+			       size_t,
+			       struct sockaddr_in *,
+			       struct sockaddr_in *,
+			       struct hardware *));
+#endif
+/* %%PXE end */
+
 #endif
 
 #if defined (USE_SOCKET_FALLBACK)
@@ -1563,7 +1614,13 @@
 int can_unicast_without_arp PROTO ((struct interface_info *));
 int can_receive_unicast_unconfigured PROTO ((struct interface_info *));
 int supports_multiple_interfaces (struct interface_info *);
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback PROTO ((void));
+#else
+void maybe_setup_fallback PROTO ((int));
+#endif
+/* %%PXE end */
 #endif
 
 /* bpf.c */
@@ -1583,15 +1640,34 @@
 void if_reinitialize_receive PROTO ((struct interface_info *));
 void if_register_receive PROTO ((struct interface_info *));
 void if_deregister_receive PROTO ((struct interface_info *));
+
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet PROTO ((struct interface_info *,
 			       unsigned char *, size_t,
 			       struct sockaddr_in *, struct hardware *));
+#else
+ssize_t receive_packet PROTO ((struct interface_info *,
+			       unsigned char *,
+			       size_t,
+			       struct sockaddr_in *,
+			       struct sockaddr_in *,
+			       struct hardware *));
+#endif
+/* %%PXE end */
+
 #endif
 #if defined (USE_BPF_SEND)
 int can_unicast_without_arp PROTO ((struct interface_info *));
 int can_receive_unicast_unconfigured PROTO ((struct interface_info *));
 int supports_multiple_interfaces (struct interface_info *);
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback PROTO ((void));
+#else
+void maybe_setup_fallback PROTO ((int));
+#endif
+/* %%PXE end */
 #endif
 
 /* lpf.c */
@@ -1611,15 +1687,34 @@
 void if_reinitialize_receive PROTO ((struct interface_info *));
 void if_register_receive PROTO ((struct interface_info *));
 void if_deregister_receive PROTO ((struct interface_info *));
+
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet PROTO ((struct interface_info *,
 			       unsigned char *, size_t,
 			       struct sockaddr_in *, struct hardware *));
+#else
+ssize_t receive_packet PROTO ((struct interface_info *,
+			       unsigned char *,
+			       size_t,
+			       struct sockaddr_in *,
+			       struct sockaddr_in *,
+			       struct hardware *));
+#endif
+/* %%PXE end */
+
 #endif
 #if defined (USE_LPF_SEND)
 int can_unicast_without_arp PROTO ((struct interface_info *));
 int can_receive_unicast_unconfigured PROTO ((struct interface_info *));
 int supports_multiple_interfaces (struct interface_info *);
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback PROTO ((void));
+#else
+void maybe_setup_fallback PROTO ((int));
+#endif
+/* %%PXE end */
 #endif
 
 /* nit.c */
@@ -1640,15 +1735,34 @@
 void if_reinitialize_receive PROTO ((struct interface_info *));
 void if_register_receive PROTO ((struct interface_info *));
 void if_deregister_receive PROTO ((struct interface_info *));
+
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet PROTO ((struct interface_info *,
 			       unsigned char *, size_t,
 			       struct sockaddr_in *, struct hardware *));
+#else
+ssize_t receive_packet PROTO ((struct interface_info *,
+			       unsigned char *,
+			       size_t,
+			       struct sockaddr_in *,
+			       struct sockaddr_in *,
+			       struct hardware *));
+#endif
+/* %%PXE end */
+
 #endif
 #if defined (USE_NIT_SEND)
 int can_unicast_without_arp PROTO ((struct interface_info *));
 int can_receive_unicast_unconfigured PROTO ((struct interface_info *));
 int supports_multiple_interfaces (struct interface_info *);
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback PROTO ((void));
+#else
+void maybe_setup_fallback PROTO ((int));
+#endif
+/* %%PXE end */
 #endif
 
 /* dlpi.c */
@@ -1669,9 +1783,22 @@
 void if_reinitialize_receive PROTO ((struct interface_info *));
 void if_register_receive PROTO ((struct interface_info *));
 void if_deregister_receive PROTO ((struct interface_info *));
+
+/* %%PXE begin */
+#if 0
 ssize_t receive_packet PROTO ((struct interface_info *,
 			       unsigned char *, size_t,
 			       struct sockaddr_in *, struct hardware *));
+#else
+ssize_t receive_packet PROTO ((struct interface_info *,
+			       unsigned char *,
+			       size_t,
+			       struct sockaddr_in *,
+			       struct sockaddr_in *,
+			       struct hardware *));
+#endif
+/* %%PXE end */
+
 #endif
 
 
@@ -1687,7 +1814,13 @@
 int can_unicast_without_arp PROTO ((struct interface_info *));
 int can_receive_unicast_unconfigured PROTO ((struct interface_info *));
 int supports_multiple_interfaces (struct interface_info *);
+/* %%PXE begin */
+#if 0
 void maybe_setup_fallback PROTO ((void));
+#else
+void maybe_setup_fallback PROTO ((int));
+#endif
+/* %%PXE end */
 #endif
 
 /* discover.c */
@@ -1708,10 +1841,22 @@
 extern int (*dhcp_interface_discovery_hook) (struct interface_info *);
 isc_result_t (*dhcp_interface_startup_hook) (struct interface_info *);
 
+/* %%PXE begin */
+#if 0
 extern void (*bootp_packet_handler) PROTO ((struct interface_info *,
 					    struct dhcp_packet *, unsigned,
 					    unsigned int,
 					    struct iaddr, struct hardware
*));
+#else
+extern void (*bootp_packet_handler) PROTO ((struct interface_info *,
+					    struct dhcp_packet *,
+					    unsigned,
+					    unsigned int,
+					    unsigned int,
+					    struct iaddr,
+					    struct hardware *));
+#endif
+/* %%PXE end */
 extern struct timeout *timeouts;
 extern omapi_object_type_t *dhcp_type_interface;
 #if defined (TRACING)
@@ -1723,8 +1868,15 @@
 extern int interface_count;
 extern int interface_max;
 isc_result_t interface_initialize (omapi_object_t *, const char *, int);
+/* %%PXE begin */
+#if 0
 void discover_interfaces PROTO ((int));
 int setup_fallback (struct interface_info **, const char *, int);
+#else
+void discover_interfaces PROTO ((int, int));
+int setup_fallback (struct interface_info **, const char *, int, int);
+#endif
+/* %%PXE end */
 int if_readsocket PROTO ((omapi_object_t *));
 void reinitialize_interfaces PROTO ((void));
 
@@ -1904,9 +2056,22 @@
 				    u_int32_t, unsigned char *, unsigned));
 ssize_t decode_hw_header PROTO ((struct interface_info *, unsigned char *,
 				 unsigned, struct hardware *));
+
+/* %%PXE begin */
+#if 0
 ssize_t decode_udp_ip_header PROTO ((struct interface_info *, unsigned char
*,
 				     unsigned, struct sockaddr_in *,
 				     unsigned char *, unsigned));
+#else
+ssize_t decode_udp_ip_header PROTO ((struct interface_info *,
+				     unsigned char *,
+				     unsigned,
+				     struct sockaddr_in *,
+				     struct sockaddr_in *,
+				     unsigned char *,
+				     unsigned));
+#endif
+/* %%PXE end */
 
 /* ethernet.c */
 void assemble_ethernet_header PROTO ((struct interface_info *, unsigned
char *,
@@ -1986,8 +2151,22 @@
 void parse_reject_statement PROTO ((struct parse *, struct client_config
*));
 
 /* dhcrelay.c */
+
+/* %%PXE begin */
+#if 0
 void relay PROTO ((struct interface_info *, struct dhcp_packet *, unsigned,
 		   unsigned int, struct iaddr, struct hardware *));
+#else
+void relay PROTO ((struct interface_info *,
+		   struct dhcp_packet *,
+		   unsigned,
+		   unsigned int,
+		   unsigned int,
+		   struct iaddr,
+		   struct hardware *));
+#endif
+/* %%PXE end */
+
 int strip_relay_agent_options PROTO ((struct interface_info *,
 				      struct interface_info **,
 				      struct dhcp_packet *, unsigned));
diff -ruN ../dhcp-3.0/includes/dhctoken.h ./includes/dhctoken.h
--- ../dhcp-3.0/includes/dhctoken.h	Mon Jun  4 14:18:40 2001
+++ ./includes/dhctoken.h	Fri Oct  5 10:16:41 2001
@@ -316,6 +316,16 @@
 	REMOVE = 611,
 	REFRESH = 612,
 	DOMAIN_NAME = 613
+/* %%PXE begin */
+	,
+	DHCPD_OPERATION,
+	BOOTSERVER_OPERATION,
+	PROXY,
+	DISABLE,
+	BOOTSERVER,
+	MCAST_DISCOVERY_ADDR,
+	TOKEN_DLL,
+/* %%PXE end */
 };
 
 #define is_identifier(x)	((x) >= FIRST_TOKEN &&	\
diff -ruN ../dhcp-3.0/includes/dll.h ./includes/dll.h
--- ../dhcp-3.0/includes/dll.h	Wed Dec 31 16:00:00 1969
+++ ./includes/dll.h	Fri Oct  5 10:16:41 2001
@@ -0,0 +1,36 @@
+/* %%PXE begin */
+
+struct dll_value {
+	enum {
+		dll_type_unused = 0,
+		dll_type_boolean,
+		dll_type_data,
+		dll_type_numeric,
+		dll_type_last
+	} type;
+
+	union {
+		struct {
+			unsigned len;
+			char buf[1];
+		} data;
+		unsigned long numeric;
+		int boolean;
+	} value;
+};
+
+/*
+ * DLL library functions must be defined thusly:
+ *	struct dll_value *funcname(const unsigned argcnt, const struct
dll_value *arglist[])
+ *
+ * The DLL library functions must allocate the return value storage
+ * using the C library malloc() call.  A return value of NULL will
+ * be treated as an error.
+ *
+ * After consuming the result data the DHCP daemon will release
+ * the return value storage using the C library free() call.
+ *
+ * argcnt will be set to the number of arguments in the argument list.
+ * If there are no arguments, argcnt will be zero and arglist will be NULL.
+ */
+/* %%PXE end */
diff -ruN ../dhcp-3.0/includes/tree.h ./includes/tree.h
--- ../dhcp-3.0/includes/tree.h	Thu Jan 25 00:26:04 2001
+++ ./includes/tree.h	Fri Oct  5 10:16:41 2001
@@ -41,6 +41,12 @@
  * ``http://www.nominum.com''.
  */
 
+/* %%PXE begin */
+#ifdef DLL
+# include "dll.h"
+#endif /* DLL */
+/* %%PXE end */
+
 /* A pair of pointers, suitable for making a linked list. */
 typedef struct _pair {
 	caddr_t car;
@@ -99,7 +105,7 @@
 	context_numeric,
 	context_dns,
 	context_data_or_numeric, /* indefinite */
-	context_function
+	context_function,
 };
 
 struct fundef {
@@ -115,7 +121,7 @@
 		binding_data,
 		binding_numeric,
 		binding_dns,
-		binding_function
+		binding_function,
 	} type;
 	union value {
 		struct data_string data;
@@ -199,7 +205,14 @@
 	expr_binary_and,
 	expr_binary_or,
 	expr_binary_xor,
-	expr_client_state
+	expr_client_state,
+/* %%PXE begin */
+	expr_proxy,
+	expr_bootserver,
+#ifdef DLL
+	expr_dll,
+#endif /* DLL */
+/* %%PXE end */
 };
 
 struct expression {
@@ -280,6 +293,18 @@
 			struct expression *arglist;
 		} funcall;
 		struct fundef *func;
+/* %%PXE begin */
+#ifdef DLL
+		struct {
+			char *libname;
+			void *libhnd;
+			char *funcname;
+			struct dll_value *(*funcptr)(const unsigned argcnt,
const struct dll_value *arglist[]);
+			unsigned argcnt;
+			struct expression *arglist;
+		} dll;
+#endif /* DLL */
+/* %%PXE end */
 	} data;
 	int flags;
 #	define EXPR_EPHEMERAL	1
@@ -336,6 +361,9 @@
 	struct option *options [256];
 	struct option *enc_opt;
 	int index;
+/* %%PXE begin */
+	int is_vendor;
+/* %%PXE end */
 };
 
 struct option {
diff -ruN ../dhcp-3.0/includes/version.h ./includes/version.h
--- ../dhcp-3.0/includes/version.h	Thu Oct  4 20:58:38 2001
+++ ./includes/version.h	Fri Oct  5 10:17:53 2001
@@ -1,3 +1,3 @@
 /* Current version of ISC DHCP Distribution. */
 
-#define DHCP_VERSION	"V3.0"
+#define DHCP_VERSION	"V3.0pxe1"
diff -ruN ../dhcp-3.0/omapip/dispatch.c ./omapip/dispatch.c
--- ../dhcp-3.0/omapip/dispatch.c	Thu May 31 12:45:55 2001
+++ ./omapip/dispatch.c	Fri Oct  5 10:16:41 2001
@@ -78,8 +78,9 @@
 		
 	obj = (omapi_io_object_t *)0;
 	status = omapi_io_allocate (&obj, MDL);
-	if (status != ISC_R_SUCCESS)
+	if (status != ISC_R_SUCCESS) {
 		return status;
+	}
 
 	status = omapi_object_reference (&obj -> inner, h, MDL);
 	if (status != ISC_R_SUCCESS) {
@@ -414,9 +415,10 @@
 		   see if we got input on that socket. */
 		if (io -> readfd &&
 		    (desc = (*(io -> readfd)) (tmp)) >= 0) {
-			if (FD_ISSET (desc, &r))
+			if (FD_ISSET (desc, &r)) {
 				status = ((*(io -> reader)) (tmp));
 				/* XXX what to do with status? */
+			}
 		}
 		
 		/* Same deal for write descriptors. */
diff -ruN ../dhcp-3.0/relay/dhcrelay.c ./relay/dhcrelay.c
--- ../dhcp-3.0/relay/dhcrelay.c	Thu Apr 19 09:48:53 2001
+++ ./relay/dhcrelay.c	Fri Oct  5 10:16:41 2001
@@ -112,6 +112,12 @@
 static char message [] = "Internet Software Consortium DHCP Relay Agent";
 static char url [] = "For info, please visit
http://www.isc.org/products/DHCP";
 
+/* %%PXE begin */
+int dhcpd_operation = NORMAL;
+int bootserver_operation = 0;
+struct iaddr mcast_discovery_addr = { 0, 0 };
+/* %%PXE end */
+
 int main (argc, argv, envp)
 	int argc;
 	char **argv, **envp;
@@ -277,7 +283,13 @@
 	GET_TIME (&cur_time);
 
 	/* Discover all the network interfaces. */
+/* %%PXE begin */
+#if 0
 	discover_interfaces (DISCOVER_RELAY);
+#else
+	discover_interfaces(DISCOVER_RELAY, 0);
+#endif
+/* %%PXE end */
 
 	/* Set up the bootp packet handler... */
 	bootp_packet_handler = relay;
@@ -324,7 +336,14 @@
 	return 0;
 }
 
+/* %%PXE begin */
+#if 0
 void relay (ip, packet, length, from_port, from, hfrom)
+#else
+void relay (ip, packet, length, from_port, to_port, from, hfrom)
+	unsigned int to_port;
+#endif
+/* %%PXE end */
 	struct interface_info *ip;
 	struct dhcp_packet *packet;
 	unsigned length;
diff -ruN ../dhcp-3.0/server/Makefile.dist ./server/Makefile.dist
--- ../dhcp-3.0/server/Makefile.dist	Wed Mar 14 07:34:06 2001
+++ ./server/Makefile.dist	Fri Oct  5 10:16:41 2001
@@ -17,14 +17,19 @@
 # http://www.isc.org for more information.
 #
 
-CATMANPAGES = dhcpd.cat8 dhcpd.conf.cat5 dhcpd.leases.cat5
-SEDMANPAGES = dhcpd.man8 dhcpd.conf.man5 dhcpd.leases.man5
+# CATMANPAGES = dhcpd.cat8 dhcpd.conf.cat5 dhcpd.leases.cat5
+# SEDMANPAGES = dhcpd.man8 dhcpd.conf.man5 dhcpd.leases.man5
+CATMANPAGES = dhcpd.cat8 dhcpd.conf.cat5 dhcpd.leases.cat5 dhcpd.pxe.cat5
+SEDMANPAGES = dhcpd.man8 dhcpd.conf.man5 dhcpd.leases.man5 dhcpd.pxe.man5
+
 SRCS   = dhcpd.c dhcp.c bootp.c confpars.c db.c class.c failover.c \
 	 omapi.c mdb.c stables.c salloc.c ddns.c
 OBJS   = dhcpd.o dhcp.o bootp.o confpars.o db.o class.o failover.o \
 	 omapi.o mdb.o stables.o salloc.o ddns.o
 PROG   = dhcpd
-MAN    = dhcpd.8 dhcpd.conf.5 dhcpd.leases.5
+
+# MAN    = dhcpd.8 dhcpd.conf.5 dhcpd.leases.5
+MAN    = dhcpd.8 dhcpd.conf.5 dhcpd.leases.5 dhcpd.pxe.5
 
 INCLUDES = -I$(TOP) $(BINDINC) -I$(TOP)/includes
 DHCPLIB = ../common/libdhcp.a $(BINDLIB) ../omapip/libomapi.a
../dst/libdst.a
@@ -51,6 +56,8 @@
 			$(DESTDIR)$(FFMANDIR)/dhcpd.conf$(FFMANEXT)
 	$(MANINSTALL) $(MANFROM) dhcpd.leases.$(MANCAT)5 $(MANTO) \
 			$(DESTDIR)$(FFMANDIR)/dhcpd.leases$(FFMANEXT)
+	$(MANINSTALL) $(MANFRMO) dhcpd.leases.$(MANCAT)5 $(MANTO) \
+			$(DESTDIR)$(FFMANDIR).dhcpd.pxe$(FFMANEXT)
 
 depend:
 	$(MKDEP) $(INCLUDES) $(PREDEFINES) $(SRCS)
@@ -96,6 +103,13 @@
 dhcpd.leases.man5:	dhcpd.leases.5
 	sed -e "s#ETCDIR#$(ETC)#g" -e "s#DBDIR#$(VARDB)#g" \
 		-e "s#RUNDIR#$(VARRUN)#g" < dhcpd.leases.5
>dhcpd.leases.man5
+
+dhcpd.pxe.cat5:	dhcpd.pxe.man5
+	nroff -man dhcpd.pxe.man5 >dhcpd.pxe.cat5
+
+dhcpd.pxe.man5:	dhcpd.pxe.5
+	sed -e "s#ETCDIR#$(ETC)#g" -e "s#DBDIR#$(VARDB)#g" \
+		-e "s#RUNDIR#$(VARRUN)#g" < dhcpd.pxe.5 >dhcpd.pxe.man5
 
 dhcpd:	$(OBJS) $(COBJ) $(DHCPLIB)
 	$(CC) $(LFLAGS) -o dhcpd $(OBJS) $(DHCPLIB) $(LIBS)
diff -ruN ../dhcp-3.0/server/bootserver.conf ./server/bootserver.conf
--- ../dhcp-3.0/server/bootserver.conf	Wed Dec 31 16:00:00 1969
+++ ./server/bootserver.conf	Fri Oct  5 10:16:41 2001
@@ -0,0 +1,268 @@
+#
+# /etc/dhcpd.conf - PXE bootserver configuration file.
+#
+# More information about bootserver and client operation and bootserver
+# request and reply packet contents can be found in the PXE specification
+# at: http://developer.intel.com/ial/wfm/wfmspecs.htm
+#
+
+#
+# Briefly, PXE bootservers are intended to be placed about a network as
+# needed and provide PXE clients with remote boot services.  Bootsevers
+# do not provide IP addresses to clients and do not do IP lease management.
+#
+
+#
+# Bootserver request packets are accepted from PXE clients if they meet
+# the following requirements:
+#
+#   - The client IP address (ciaddr) field in the packet header is
+#     filled in with a valid unicast IP address.
+#
+#   - The packet contains a vendor-class-identifier (option 60) that is
+#     at least 9 octets in length with the first 9 characters set to
+#     "PXEClient" (without the quotes).
+#
+#  - The packet contains a client-architecture (option 93) that is 2 octets
+#    in length.
+#
+#  - The packet contains a network-interface-identifier (option 94) that
+#    is 3 octets in length.
+#
+#  - The packet contains vendor-encapsulated-options (option 43) that
+#    contains an encapsulated pxe.boot-item (sub-option 71) that is
+#    4 octets in length.
+#
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Disable proxyDHCP operation.
+#
+
+dhcpd-operation disable;
+# dhcpd-operation normal;
+# dhcpd-operation proxy;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Enable bootserver operation.
+#
+
+bootserver-operation on;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Respond to multicast bootserver discover request packets.
+#
+
+mcast-discovery-addr 224.0.1.2;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Needed by DHCP daemon.
+#
+
+ddns-update-style ad-hoc;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Define PXE client options.
+#
+# Values for these options are defined in the PXE specification.
+# http://developer.intel.com/ial/wfm/wfmspecs.htm
+#
+# Additional values can be found in the EFI specification.
+# http://developer.intel.com/technology/efi/index.htm
+#
+
+#
+# This option is used to determine the client boot-time binary runtime
+# environment.
+#
+
+option client-architecture code 93 +	unsigned integer 16;
+
+#
+# This option is used to determine the version of the UNDI (Universal
+# Network Driver Interface) implemented in the client.
+#
+
+option network-interface-identifier code 94 +	{ unsigned integer 8, unsigned integer 8, unsigned integer 8 };
+
+#
+# This option is used to uniquely identify the booting client.  When
+# possible GUIDs should be used instead of MAC address to identify a
+# client machine.  Think of a docking station with a NIC:  Every laptop
+# inserted into the docking station will have the same MAC address but
+# each laptop will have its own GUID.
+#
+
+option client-guid code 97 +	{ unsigned integer 8, string };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Descibe bootserver vendor-option-space.
+#
+# Values and more detailed descriptions for these sub-options can be found
+# in the PXE specification.
+#
+
+option space bs;
+
+#
+# MTFTP (Multicast Trivial File Transfer Protocol) IP address.
+# This is the MTFTP multicast IP address that is associated with
+# this file.  If MTFTP is not used, do not return this sub-option.
+#
+
+option bs.mtftp-ip code 1 = ip-address;
+
+#
+# MTFTP client listening port.  This is the UDP port that the client
+# must use to listen for and receive MTFTP data packets.  If MTFTP
+# is not used, do not return this sub-option.
+#
+
+option bs.mtftp-cport code 2 = unsigned integer 16;
+
+#
+# MTFTP server listening port.  This is the UDP port that the server
+# must use to accept MTFTP open requests.  If MTFTP is not used, do
+# not return this sub-option.
+#
+
+option bs.mtftp-sport code 3 = unsigned integer 16;
+
+#
+# MTFTP client timeout.  This is the number of seconds that a client
+# must listen for its file before starting a new MTFTP download session.
+# This is also the number of seconds the client must wait before
+# retransmitting an acknowledgement packet if a data packet is not
+# received.  If MTFTP is not used, do not return this sub-option.
+#
+
+option bs.mtftp-tmout code 4 = unsigned integer 8;
+
+#
+# MTFTP client restart delay.  This is the maximum number of seconds
+# that a client must listen before requesting a new MTFTP download
+# sesson of the file it was listening to.  If MTFTP is not used, do
+# not return this sub-options.
+#
+
+option bs.mtftp-delay code 5 = unsigned integer 8;
+
+#
+# This sub-option is sent to the proxyDHCP server if the client supports
+# remote boot security.  The client must send a list of all of the
+# credential types it supports.  More information about remote boot
+# security can be found in the BIS specification.
+# http://developer.intel.com/ial/WfM/tools/BIS/Index.htm
+#
+
+option bs.credential-types code 12 +	{ unsigned integer 16, unsigned integer 16 };
+
+#
+# This sub-option is sent by the client to request a specific bootserver
+# type and image number.  This sub-option is also sent back by the
+# bootserver.  The bootserver type cannot be changed but the image number
+# may be changed.
+#
+
+option bs.boot-item code 71 +	{ unsigned integer 16, unsigned integer 16 };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Simple sample scope.
+#
+
+subnet 192.168.13.0 netmask 255.255.255.0 {
+	range 192.168.13.1 192.168.13.10;
+
+	#
+	# If this is not a valid bootserver packet, do not reply
+	# to the client.
+	#
+
+	if not bootserver {
+		deny booting;
+	}
+
+	#
+	# Send back different information based on client-architecture.
+	# This configuration file is for a bootserver that sends back
+	# images for Intel x86 PC/AT architecture clients.
+	#
+
+	if not (option client-architecture = 00:00) {
+		deny booting;
+	}
+
+	#
+	# Send back different information based on bootserver type.
+	# This configuration file is for a bootserver that sends back
+	# DOS/UNDI remote boot images.
+	#
+
+	if not (substring(option bs.boot-item, 0, 2) = 00:03) {
+		deny booting;
+	}
+
+	#
+	# Only two image layer numbers are supported.
+	#
+
+	if substring(option bs.boot-item, 2, 2) = 00:00 {
+
+		#
+		# Send back the filename for layer zero.
+		#
+
+		filename "X86PC/UNDI/DOSUNDI/dosundi.0";
+
+		#
+		# Send back "PXEClient" so the reply is not ignored by
+		# the client.
+		#
+
+		option vendor-class-identifier "PXEClient";
+
+		#
+		# Send back the image number so the reply is not ignored
+		# by the client.
+		#
+
+		option bs.boot-item 3 0;
+
+		#
+		# Send back the vendor option space.
+		#
+
+		vendor-option-space bs;
+	} else if substring(option bs.boot-item, 2, 2) = 00:01 {
+
+		#
+		# Send back the filename for layer one.
+		#
+
+		filename "X86PC/UNDI/DOSUNDI/dosundi.1";
+
+		#
+		# Send back "PXEClient" so the reply is not ignored by
+		# the client.
+		#
+
+		option vendor-class-identifier "PXEClient";
+
+		#
+		# Send back the image number so the reply is not ignored
+		# by the client.
+		#
+
+		option bs.boot-item 3 1;
+
+		#
+		# Send back the vendor option space.
+		#
+
+		vendor-option-space bs;
+	}
+}
diff -ruN ../dhcp-3.0/server/confpars.c ./server/confpars.c
--- ../dhcp-3.0/server/confpars.c	Thu Oct  4 15:08:35 2001
+++ ./server/confpars.c	Fri Oct  5 10:16:41 2001
@@ -318,6 +318,11 @@
 	       | USE_LEASE_ADDR_FOR_DEFAULT_ROUTE boolean
 	       | AUTHORITATIVE
 	       | NOT AUTHORITATIVE
+%%PXE begin
+		| DHCPD-OPERATION  NORMAL / PROXY / DISABLE  SEMI
+		| BOOTSERVER-OPERATION boolean SEMI
+		| MCAST-DISCOVERY-ADDR ip-addr SEMI
+%%PXE end
 
    declaration := host-declaration
 		 | group-declaration
@@ -348,10 +353,83 @@
 	struct data_string key_id;
 	int known;
 	isc_result_t status;
+/* %%PXE begin */
+	static int had_dhcpd_operation = 0;
+	static int had_bootserver_operation = 0;
+	static int had_mcast_discovery_addr = 0;
+/* %%PXE end */
 
 	token = peek_token (&val, (unsigned *)0, cfile);
 
 	switch (token) {
+/* %%PXE begin */
+		case DHCPD_OPERATION:
+			if (had_dhcpd_operation) {
+				parse_warn(cfile,
+					"already parsed dhcpd-operation.");
+
+				skip_to_semi(cfile);
+				return 1;
+			}
+
+			/* skip dhcpd-operation token */
+		      	next_token(&val, (unsigned *)0, cfile);
+
+			token = next_token(&val, (unsigned *)0, cfile);
+
+			if (token = NORMAL) {
+				dhcpd_operation = NORMAL;
+				parse_semi(cfile);
+			} else if (token = PROXY) {
+				dhcpd_operation = PROXY;
+				parse_semi(cfile);
+			} else if (token = DISABLE) {
+				dhcpd_operation = DISABLE;
+				parse_semi(cfile);
+			} else {
+				parse_warn(cfile,
+					"normal/proxy/disable expected.");
+
+				skip_to_semi(cfile);
+			}
+
+			return had_dhcpd_operation = 1;
+
+		case BOOTSERVER_OPERATION:
+			if (had_bootserver_operation) {
+				parse_warn(cfile,
+					"already parsed
bootserver-operation.");
+
+				skip_to_semi(cfile);
+				return 1;
+			}
+
+			next_token(&val, (unsigned *)0, cfile);
+
+			bootserver_operation = parse_boolean(cfile);
+
+			return had_bootserver_operation = 1;
+
+		case MCAST_DISCOVERY_ADDR:
+			if (had_mcast_discovery_addr) {
+				parse_warn(cfile,
+					"already parsed
mcast-discovery-addr.");
+
+				skip_to_semi(cfile);
+				return 1;
+			}
+
+			next_token(&val, (unsigned *)0, cfile);
+
+			if (parse_ip_addr(cfile, &mcast_discovery_addr)) {
+				parse_semi(cfile);
+			} else {
+				parse_warn(cfile, "expected ip-address.");
+			}
+
+			return had_mcast_discovery_addr = 1;
+/* %%PXE end */
+
 	      case INCLUDE:
 		next_token (&val, (unsigned *)0, cfile);
 		token = next_token (&val, (unsigned *)0, cfile);
diff -ruN ../dhcp-3.0/server/db.c ./server/db.c
--- ../dhcp-3.0/server/db.c	Fri Jun 22 16:58:08 2001
+++ ./server/db.c	Fri Oct  5 10:16:41 2001
@@ -75,6 +75,12 @@
 		if (!new_lease_file ())
 			return 0;
 
+/* %%PXE begin */
+	if (lease->flags & PXE_LEASE) {
+		return 1;
+	}
+/* %%PXE end */
+
 	if (counting)
 		++count;
 	errno = 0;
diff -ruN ../dhcp-3.0/server/dhcp.c ./server/dhcp.c
--- ../dhcp-3.0/server/dhcp.c	Thu Oct  4 15:21:00 2001
+++ ./server/dhcp.c	Fri Oct  5 10:16:41 2001
@@ -111,6 +111,125 @@
 		goto out;
 	}
 
+/* %%PXE begin */
+	packet->proxy = packet->bootserver = 0;
+
+	/*
+	 * Do simple (quick) checks first.  Most non-PXE packets will be
+	 * thrown out by these few checks.
+	 */
+	if (
+		(!packet->raw->ciaddr.s_addr &&
+			(packet->packet_type = DHCPDISCOVER ||
+				packet->packet_type = DHCPREQUEST)) ||
+
+		(packet->raw->ciaddr.s_addr &&
+			(packet->packet_type = DHCPREQUEST ||
+				packet->packet_type = DHCPINFORM))
+	) {
+		unsigned n;
+
+		/*
+		 * All PXE client packets must have a
vendor-class-identifier
+		 * with the first nine characters set to "PXEClient".
+		 */
+		oc = lookup_option(&dhcp_universe, packet->options,
+			DHO_VENDOR_CLASS_IDENTIFIER);
+
+		if (!oc || oc->expression || oc->data.len < 9 ||
+			strncmp(oc->data.data, "PXEClient", 9))
+		{
+			goto pxe_out;
+		}
+
+		/*
+		 * All PXE client packets must have a two-byte client
+		 * architecture option.
+		 */
+		oc = lookup_option(&dhcp_universe, packet->options,
+			DHO_PXE_CLIENT_ARCHITECTURE);
+
+		if (!oc || oc->expression || oc->data.len != 2) {
+			goto pxe_out;
+		}
+
+		/*
+		 * All PXE client packets must have a three-byte network
+		 * interface option.
+		 */
+		oc = lookup_option(&dhcp_universe, packet->options,
+			DHO_PXE_NETWORK_INTERFACE);
+
+		if (!oc || oc->expression || oc->data.len != 3) {
+			goto pxe_out;
+		}
+
+		/*
+		 * PXE clients may have included some PXE vendor data
+		 * in the incoming packet.  Proxy packets will not have
+		 * a PXE boot-item (41) sub-option.
+		 */
+		oc = lookup_option(&dhcp_universe, packet->options,
+			DHO_VENDOR_ENCAPSULATED_OPTIONS);
+
+		if (!oc) {
+			/*
+			 * This may be a proxy packet.
+			 */
+			switch (packet->packet_type) {
+			case DHCPDISCOVER:
+			case DHCPREQUEST:
+				packet->proxy = !packet->raw->ciaddr.s_addr;
+			}
+
+			goto pxe_out;
+		}
+
+		if (oc->expression) {
+			/*
+			 * M(f)J - I do not know what this means so I am
+			 * going to assume that this is not a valid PXE
+			 * packet since I have never seen this happen in
+			 * my testing.
+			 */
+			goto pxe_out;
+		}
+
+		for (n = 0; n < oc->data.len && oc->data.data[n] != 255; ) {
+			switch (oc->data.data[n]) {
+			case 0:
+				++n;
+				continue;
+
+			case 71:
+				switch (packet->packet_type) {
+				case DHCPREQUEST:
+				case DHCPINFORM:
+					packet->bootserver +						(oc->data.data[n + 1] = 4);
+				}
+
+				goto pxe_out;
+
+			default:
+				n += 2 + oc->data.data[n + 1];
+				continue;
+			}
+		}
+
+		packet->proxy = 1;
+	}
+pxe_out:
+
+	if (dhcpd_operation != NORMAL) {
+		goto nolease;
+	}
+
+	if (packet->server_port = htons((short)4011)) {
+		goto nolease;
+	}
+/* %%PXE end */
+
 	/* There is a problem with the relay agent information option,
 	   which is that in order for a normal relay agent to append
 	   this option, the relay agent has to have been involved in
@@ -220,10 +339,6 @@
 		dhcpdiscover (packet, ms_nulltp);
 		break;
 
-	      case DHCPREQUEST:
-		dhcprequest (packet, ms_nulltp, lease);
-		break;
-
 	      case DHCPRELEASE:
 		dhcprelease (packet, ms_nulltp);
 		break;
@@ -232,10 +347,61 @@
 		dhcpdecline (packet, ms_nulltp);
 		break;
 
+/* %%PXE begin */
+#if 0
+	      case DHCPREQUEST:
+		dhcprequest (packet, ms_nulltp, lease);
+		break;
+
 	      case DHCPINFORM:
 		dhcpinform (packet, ms_nulltp);
 		break;
+#else
+	      case DHCPREQUEST:
+		if (packet->server_port = htons((short)4011)) {
+			if (bootserver_operation && packet->bootserver) {
+				dhcpinform(packet, ms_nulltp);
+			}
+
+			break;
+		}
+
+		if (dhcpd_operation != NORMAL && bootserver_operation &&
+			packet->bootserver)
+		{
+			dhcpinform(packet, ms_nulltp);
+			break;
+		}
+
+		if (dhcpd_operation = NORMAL) {
+			dhcprequest(packet, ms_nulltp, lease);
+		}
+
+		break;
 
+	      case DHCPINFORM:
+		if (packet->server_port = htons((short)4011)) {
+			if (bootserver_operation && packet->bootserver) {
+				dhcpinform(packet, ms_nulltp);
+			}
+
+			break;
+		}
+
+		if (dhcpd_operation != NORMAL && bootserver_operation &&
+			packet->bootserver)
+		{
+			dhcpinform(packet, ms_nulltp);
+			break;
+		}
+
+		if (dhcpd_operation = NORMAL) {
+			dhcpinform(packet, ms_nulltp);
+		}
+
+		break;
+#endif
+/* %%PXE end */
 
 	      case DHCPACK:
 	      case DHCPOFFER:
@@ -265,8 +431,17 @@
 	dhcp_failover_state_t *peer;
 #endif
 
+/* %%PXE begin */
+#if 0
 	find_lease (&lease, packet, packet -> shared_network,
 		    0, &allocatedp, (struct lease *)0, MDL);
+#else
+	if (dhcpd_operation = NORMAL) {
+		find_lease(&lease, packet, packet -> shared_network,
+			0, &allocatedp, (struct lease *)0, MDL);
+	}
+#endif
+/* %%PXE end */
 
 	if (lease && lease -> client_hostname &&
 	    db_printable (lease -> client_hostname))
@@ -440,9 +615,18 @@
 
 	subnet = (struct subnet *)0;
 	lease = (struct lease *)0;
+/* %%PXE begin */
+#if 0
 	if (find_subnet (&subnet, cip, MDL))
 		find_lease (&lease, packet,
 			    subnet -> shared_network, &ours, 0, ip_lease,
MDL);
+#else
+	if (find_subnet(&subnet, cip, MDL) && dhcpd_operation = NORMAL) {
+		find_lease(&lease, packet, subnet->shared_network,
+			&ours, 0, ip_lease, MDL);
+	}
+#endif
+/* %%PXE end */
 	/* XXX consider using allocatedp arg to find_lease to see
 	   XXX that this isn't a compliant DHCPREQUEST. */
 
@@ -484,6 +668,22 @@
 		  ? inet_ntoa (packet -> raw -> giaddr)
 		  : packet -> interface -> name);
 
+/* %%PXE begin */
+	if (dhcpd_operation = DISABLE) {
+		log_info("%s: dhcpd-operation disable", msgbuf);
+		return;
+	}
+/* %%PXE end */
+
+/* %%PXE begin */
+	if (dhcpd_operation != NORMAL) {
+		log_info("%s: dhcpd-operation %s", msgbuf,
+			((dhcpd_operation = PROXY) ? "proxy" :
"disabled"));
+
+		return;
+	}
+/* %%PXE end */
+
 #if defined (FAILOVER_PROTOCOL)
 	if (lease && lease -> pool && lease -> pool -> failover_peer) {
 		peer = lease -> pool -> failover_peer;
@@ -915,8 +1115,17 @@
 		memcpy (cip.iabuf, &packet -> raw -> ciaddr, 4);
 	}
 
+/* %%PXE begin */
+#if 0
 	sprintf (msgbuf, "DHCPINFORM from %s via %s",
 		 piaddr (cip), packet -> interface -> name);
+#else
+	sprintf(msgbuf, "%s from %s via %s",
+		 (packet->bootserver ? "BOOTSERVERREQUEST" : "DHCPINFORM"),
+		 piaddr(cip),
+		 packet->interface->name);
+#endif
+/* %%PXE end */
 
 	/* If the IP source address is zero, don't respond. */
 	if (!memcmp (cip.iabuf, "\0\0\0", 4)) {
@@ -939,7 +1148,13 @@
 	   It would be nice if a per-host value could override this, but
 	   there's overhead involved in checking this, so let's see how
people
 	   react first. */
+/* %%PXE begin */
+#if 0
 	if (subnet && !subnet -> group -> authoritative) {
+#else
+	if (subnet && !subnet->group->authoritative && !packet->bootserver)
{
+#endif
+/* %%PXE end */
 		static int eso = 0;
 		log_info ("%s: not authoritative for subnet %s",
 			  msgbuf, piaddr (subnet -> net));
@@ -966,6 +1181,10 @@
 	memset (&raw, 0, sizeof raw);
 	outgoing.raw = &raw;
 
+/* %%PXE begin */
+	outgoing.bootserver = packet->bootserver;
+/* %%PXE end */
+
 	/* Execute statements in scope starting with the subnet scope. */
 	if (subnet)
 		execute_statements_in_scope ((struct binding_value **)0,
@@ -1194,7 +1413,15 @@
 	raw.op = BOOTREPLY;
 
 	/* Report what we're sending... */
+/* %%PXE begin */
+#if 0
 	log_info ("DHCPACK to %s", inet_ntoa (raw.ciaddr));
+#else
+	log_info("%s to %s",
+		(outgoing.bootserver ? "BOOTSERVERREPLY" : "DHCPACK"),
+		inet_ntoa(raw.ciaddr));
+#endif
+/* %%PXE end */
 
 #ifdef DEBUG_PACKET
 	dump_packet (&outgoing);
@@ -1210,7 +1437,13 @@
 
 	/* Use the IP address we derived for the client. */
 	memcpy (&to.sin_addr, cip.iabuf, 4);
+/* %%PXE begin */
+#if 0
 	to.sin_port = remote_port;
+#else
+	to.sin_port = outgoing.bootserver ? htons((short)4011) :
remote_port;
+#endif
+/* %%PXE end */
 
 	errno = 0;
 	send_packet ((fallback_interface
@@ -2565,6 +2798,17 @@
 	/* Hang the packet off the lease state. */
 	packet_reference (&lease -> state -> packet, packet, MDL);
 
+/* %%PXE begin */
+	if (lease->flags & PXE_LEASE) {
+		lease->timestamp = cur_time;
+		/* static_lease_dereference(lease, MDL); */
+		lease_dereference(&lease, MDL); /* M(f)J %% */
+		dhcp_reply(lease);
+		dissociate_lease(lease);
+		return;
+	}
+/* %%PXE end */
+
 	/* If this is a DHCPOFFER, ping the lease address before actually
 	   sending the offer. */
 	if (offer = DHCPOFFER && !(lease -> flags & STATIC_LEASE) &&
@@ -3447,6 +3691,13 @@
 		host_dereference (&host, MDL);
 
 	if (lease) {
+/* %%PXE begin */
+		if (dhcpd_operation = PROXY) {
+			lease->flags |= PXE_LEASE;
+			memset(&lease->ip_addr, 0, sizeof lease->ip_addr);
+		}
+/* %%PXE end */
+
 #if defined (DEBUG_FIND_LEASE)
 		log_info ("Returning lease: %s.",
 		      piaddr (lease -> ip_addr));
@@ -3502,8 +3753,14 @@
 	lease -> binding_state = FTS_FREE;
 	lease_reference (lp, lease, MDL);
 	lease_dereference (&lease, MDL);
+/* %%PXE begin */
+	if (dhcpd_operation = PROXY) {
+		lease->flags |= PXE_LEASE;
+		memset(&lease->ip_addr, 0, sizeof lease->ip_addr);
+	}
+/* %%PxE end */
 	host_dereference (&rhp, MDL);
-	return 1;
+  	return 1;
 }
 
 /* Look through all the pools in a list starting with the specified pool
@@ -3588,6 +3845,14 @@
 			      piaddr (lease -> ip_addr));
 			lease_reference (lp, lease, MDL);
 		}
+
+/* %%PXE begin */
+		if (dhcpd_operation = PROXY) {
+			lease->flags |= PXE_LEASE;
+			memset(&lease->ip_addr, 0, sizeof lease->ip_addr);
+		}
+/* %%PXE end */
+
 		return 1;
 	}
 
@@ -3602,11 +3867,32 @@
 					       peer_has_leases);
 
 		allocate_lease (lp, packet, pool -> next, peer_has_leases);
+/* %%PXE begin */
+#if 0
 		if (*lp)
 			return 1;
+#else
+		if (*lp) {
+			if (dhcpd_operation = PROXY) {
+				lease->flags |= PXE_LEASE;
+				memset(&lease->ip_addr, 0, sizeof
lease->ip_addr);
+			}
+
+			return 1;
+		}
+#endif
+/* %%PXE end */
 	}
 
 	lease_reference (lp, lease, MDL);
+
+/* %%PXE begin */
+	if (dhcpd_operation = PROXY) {
+		lease->flags |= PXE_LEASE;
+		memset(&lease->ip_addr, 0, sizeof lease->ip_addr);
+	}
+/* %%PXE end */
+
 	return 1;
 }
 
diff -ruN ../dhcp-3.0/server/dhcpd.c ./server/dhcpd.c
--- ../dhcp-3.0/server/dhcpd.c	Thu Jun 21 19:12:58 2001
+++ ./server/dhcpd.c	Fri Oct  5 10:16:41 2001
@@ -63,6 +63,12 @@
 struct iaddr server_identifier;
 int server_identifier_matched;
 
+/* %%PXE begin */
+int dhcpd_operation = NORMAL;
+int bootserver_operation = 0;
+struct iaddr mcast_discovery_addr = { 0, 0 };
+/* %%PXE end */
+
 #if defined (NSUPDATE)
 
 /* This stuff is always executed to figure the default values for certain
@@ -513,7 +519,13 @@
 		exit (0);
 
 	/* Discover all the network interfaces and initialize them. */
+/* %%PXE begin */
+#if 0
 	discover_interfaces (DISCOVER_SERVER);
+#else
+	discover_interfaces(DISCOVER_SERVER, bootserver_operation);
+#endif
+/* %%PXE end */
 
 	/* Make up a seed for the random number generator from current
 	   time plus the sum of the last four bytes of each
diff -ruN ../dhcp-3.0/server/dhcpd.pxe.5 ./server/dhcpd.pxe.5
--- ../dhcp-3.0/server/dhcpd.pxe.5	Wed Dec 31 16:00:00 1969
+++ ./server/dhcpd.pxe.5	Fri Oct  5 10:16:41 2001
@@ -0,0 +1,215 @@
+.\"	dhcpd.pxe.5
+.\"
+.TH dhcpd.pxe 5
+.SH NAME
+dhcpd.pxe - pxe extensions in the dhcpd server daemon and configuration
file
+.SH DESCRIPTION
+This document describes the extensions that have been added to the ISC DHCP
+daemon and configuration file to support PXE proxyDHCP and bootserver
+operation.  More information about the DHCP options required for proper
+PXE operation and PXE client/server inter-operation can be found in the
+PXE 2.1 specification located at:
+.PP
+.RS 0.25i
+http://developer.intel.com/ial/wfm/wfmspecs.htm
+.PP
+.RE
+The DHCP options required for PXE operation are:
+.PP
+.RS 0.25i
+.B option client-architecture code 93 +.RS 0.25i
+.B unsigned integer 16;
+.PP
+.RE
+The \fBclient-architecute\fR option identifies the runtime environment
+of the client machine.
+.PP
+.B option network-interface-identifier code 94 +.RS 0.25i
+.B { unsigned integer 8, unsigned integer 8,
+.RS 0.25i
+.B unsigned integer 8 };
+.PP
+.RE
+.RE
+.RE
+The \fBnetwork-interface-identifier\fR option identifies the version of
+the UNDI (Universal Network Driver Interface) that is running on the
+client machine.
+.PP
+Another option that should be present in all DHCPDISCOVER, DHCPREQUEST
+and DHCPINFORM packets sent out by PXE clients is:
+.PP
+.RS 0.25i
+.B option client-guid code 97 +.RS 0.25i
+.B { unsigned integer 8, string };
+.PP
+.RE
+.RE
+The \fBclient-guid\fR option is a unique identifier that should be
+present on all WfM (Wired for Management) compliant systems.  This
+value should be used to uniquely identify a machine instead of a MAC
+address since the MAC address is not always unique.
+.RS .25i
+(e.g.: A laptop docking station with a network adapter installed in it
+will identify each laptopn inserted into the docking station with the 
+same MAC address.)
+.PP
+.RE
+.SH PXE STATEMENTS
+The \fIdhcpd-operation\fR statement
+.RS 0.25i
+.PP
+.B dhcpd-operation \fIstate\fB ;\fR
+.PP
+This statement defines how the DHCP daemon will respond to DHCPDISCOVER
+and DHCPREQUEST packets.  \fIstate\fR must be \fBnormal\fR, \fBproxy\fR or
+\fBdisabled\fR.  If the \fBdhcpd-operation\fR statement is not present in
+the dhcpd.conf file, default state is \fBnormal\fR.  The
\fBdhcpd-operation\fR
+statemant may only appear once in the dhcpd.conf file.
+.PP
+In the \fBnormal\fR state the DHCP daemon will process all valid
+DHCPDISCOVER packets and perform IP lease management as described
+in the dhcpd.conf.5 and dhcpd.leases.5 man pages.
+.PP
+In the \fBproxy\fR state, the daemon will respond to valid DHCPDISCOVER
+packets that contain the required DHCP options for PXE operation.
+DHCPOFFER packets that are sent back will not contain any IP lease
+management information (the client IP address fields will be set to
+0.0.0.0).
+.PP
+In the \fBdisabled\fR state, the daemon will not respond to any
DHCPDISCOVER
+packets.
+.PP
+.RE
+The \fIbootserver-operation\fR statement
+.RS 0.25i
+.PP
+.B bootserver-operation \fIflag\fB ;\fR
+.PP
+This statement controls how the DHCP daemon will respond to PXE bootserver
+request packets.  (A bootserver request packet is a DHCPREQUEST or
DHCPINFORM
+packet with the required PXE DHCP options described above and a
+\fBboot-item\fR DHCP vendor option.  This statement may only appear once
+in the dhcpd.conf file.
+.PP
+.I flag\fR can be set to \fBon\fR or \fBoff\fR.  The default state is
+\fBoff\fR.
+.PP
+In the \fBoff\fR state, the DHCP daemon will not respond to PXE bootserver
+request packets that are multicast or unicast to port 4011.  PXE bootserver
+request packets that are broadcast or unicast to the DHCP daemon local port
+will be treated like normal DHCPREQUEST and DHCPINFORM packets.
+.PP
+In the \fBon\fR state, the DHCP daemon will respond to bootserver packets
+that are multicast and unicast port 4011.  PXE bootserver request packets
+that are broadcast or unicast to the DHCP daemon local port will only be
+processed as bootserver request packets if the \fBdhcpd-operation\fR is
+NOT \fBnormal\fR.
+.PP
+.RE
+The \fImcast-discovery-addr\fR statement
+.RS 0.25i
+.PP
+.B mcast-discovery-addr \fImcast-ip-addr\fB ;\fR
+.PP
+This statement defines the multicast IP address that will be used to 
+listen for multicast bootserver requests.  If this statement is not
+present, multicast bootserver requests will be ignored.  This statement
+can appear only once in the dhcpd.conf file.
+.RE
+.SH PXE EXPRESSIONS
+.B proxy
+.RS 0.25i
+.PP
+This boolean expression returns true if the DHCPDISCOVER or DHCPREQUEST
+packet being processed has come from a client that is not bound (does not
+have an IP address) and the packet contains the required DHCP options
+mentioned above and the packet does not contain a boot-item (sub-option 71)
+in the vendor-encapsulated-options (option 43).
+.PP
+When this expression returns true, the dhcpd.conf file should return
+the PXE client boot information (menu, prompt, etc.) defined in the
+PXE specification.
+.PP
+.RE
+.B bootserver
+.RS 0.25i
+.PP
+This boolean expression returns true if the bootserver request packet
+received is valid (contains the required options and contains a boot-item
+in the vendor-encapsulated-options).
+.PP
+When this expression returns true, the dhcpd.conf file should return
+the requested boot-item if it is available.  If the requested boot-item
+is not available, the dhcpd.conf file should \fBdeny booting\fR.
+.RE
+.SH DLL FUNCTION CALL
+.B dll ( \fIlibname\fB , \fIfuncname\fR [ \fB, \fIarg-list\fR ] \fB)\fR
+.RS 0.25i
+.PP
+A DLL function can be passed and return boolean, data or numeric values.
+DLL functions are called using the above syntax.  \fIlibname\fR is a data
+string that contains the name of a dynamic library (see the \fBdlopen()\fR
+man page).  \fIfuncname\fR is the name of a symbol in the dynamic library.
+Additional parameters are optional and may be boolean, data or numeric
+data types.
+.PP
+DLL function parameters and return values are defined using this structure:
+.nf
+.PP
+.RS 0.25i
+.B struct dll_value {
+.RS 0.25i
+.B   enum {
+.RS 0.25i
+.B     dll_type_unused = 0,
+.B     dll_type_boolean,
+.B     dll_type_data,
+.B     dll_type_numeric,
+.B     dll_type_last
+.RE
+.B   } type;
+.PP
+.B   union {
+.RS 0.25i
+.B     struct {
+.RS 0.25i
+.B       unsigned len;
+.B       char buf[1];
+.RE
+.B     } data;
+
+.B     unsigned long numeric;
+.B     int boolean;
+.RE
+.B   } value;
+.RE
+.B };
+.RE
+.fi
+.PP
+DLL functions must be defined thusly:
+.nf
+.RS 0.25i
+.PP
+.B struct dll_value *funcname(
+.B   const unsigned argcnt,
+.B   const struct dll_value *arglist[]);
+.fi
+.PP
+.RE
+Additional parameters in the DLL function call are evaluated from
+left to right and placed into the \fBarglist\fR.  The third
+parameter is \fBarglist[0]\fR, the fourth is \fBarglist[1]\fR, etc.
+If no additional parameters are given in the DLL function call,
+\fBargcnt\fR will be set to zero and \fBarglist\fR will be set to
+NULL.
+.PP
+DLL library functions must allocate the return value storage using
+the C library call \fBmalloc()\fR.  A return value of NULL will be
+treated as an error.  After consuming the return value, the DHCP
+daemon will release the return value storage using the C library
+call \fBfree()\fR.
diff -ruN ../dhcp-3.0/server/proxydhcp.conf ./server/proxydhcp.conf
--- ../dhcp-3.0/server/proxydhcp.conf	Wed Dec 31 16:00:00 1969
+++ ./server/proxydhcp.conf	Fri Oct  5 10:16:41 2001
@@ -0,0 +1,260 @@
+#
+# /etc/dhcpd.conf - Sample PXE proxyDHCP configuration file.
+#
+# More information about proxyDHCP server and client operation and
+# proxyDHCPOFFER packet contents can be found in the PXE specification
+# at: http://developer.intel.com/ial/wfm/wfmspecs.htm
+#
+
+#
+# Briefly, a proxyDHCP server is intended to sit next to a DHCP server
+# and provide PXE clients with additional remote information.  The
+# difference between a proxyDHCP server and a DHCP server is that the
+# proxyDHCP server does not return IP address or IP lease information
+# and that proxyDHCP servers only respond to DHCPDISCOVER packets that
+# have come from PXE clients.
+#
+# A DHCPDISCOVER packet from a PXE client meets the following requirements:
+#
+#   - Contains a vendor-class-identifier (option 60) that is at least
+#     9 octets in length with the first 9 characters set to "PXEClient"
+#     (without the quotes).
+#
+#  - Contains a client-architecture (option 93) that is 2 octets in length.
+#
+#  - Contains a network-interface-identifier (option 94) that is 3 octets
+#    in length.
+#
+#  - Does not contain vendor-encapsulated-options (option 43) or if it
+#    does contain vendor-encapsulated-options an encapsulated pxe.boot-item
+#    (sub-option 71) is not present in the encapsulated option.
+#
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Enable proxyDHCP operation.
+#
+
+dhcpd-operation proxy;
+# dhcpd-operation normal;
+# dhcpd-operation disable;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Do not enable bootserver operation.
+#
+
+bootserver-operation off;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Do not respond to multicast bootserver discover request packets.
+#
+
+# mcast-discovery-addr 224.0.1.2;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Needed by DHCP daemon.
+#
+
+ddns-update-style ad-hoc;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Define PXE client options.
+#
+# Values for these options are defined in the PXE specification.
+# http://developer.intel.com/ial/wfm/wfmspecs.htm
+#
+# Additional values can be found in the EFI specification.
+# http://developer.intel.com/technology/efi/index.htm
+#
+
+#
+# This option is used to determine the client boot-time binary runtime
+# environment.
+#
+
+option client-architecture code 93 +	unsigned integer 16;
+
+#
+# This option is used to determine the version of the UNDI (Universal
+# Network Driver Interface) implemented in the client.
+#
+
+option network-interface-identifier code 94 +	{ unsigned integer 8, unsigned integer 8, unsigned integer 8 };
+
+#
+# This option is used to uniquely identify the booting client.  When
+# possible GUIDs should be used instead of MAC address to identify a
+# client machine.  Think of a docking station with a NIC:  Every laptop
+# inserted into the docking station will have the same MAC address but
+# each laptop will have its own GUID.
+#
+
+option client-guid code 97 +	{ unsigned integer 8, string };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Describe proxyDHCP vendor-option-space.
+#
+# Values and more detailed descriptions for these sub-options can be found
+# in the PXE specification.
+#
+
+option space proxy;
+
+#
+# This sub-option is a bitfield that defines the types of bootserver
+# discovery requests that can be made by the PXE client.  This sub-option
+# does not need to be present.  If this sub-option is not present, PXE
+# clients assume a default discovery-control of zero (00h).
+#
+# Bit 0 (01h): If set, the client must not do broadcast discovery.
+#
+# Bit 1 (02h): If set, the client must not do multicast discovery.
+# If not set, mcast-discovery-addr must be present.
+#
+# Bit 2 (04h): If set, only accept responses from servers in the
+# boot-servers sub-option.
+#
+# Bit 3 (08h): If set and a bootfile is present in the DHCPACK or
+# proxyDHCPOFFER packet, just download the file using TFTP and run it.
+# Do not try to display a boot-prompt or boot-menu.
+#
+
+option proxy.discovery-control code 6 = unsigned integer 8;
+
+#
+# This sub-option defines the multicast IP address that is being used
+# by all of the bootservers.  When a PXE client transmits a multicast
+# bootserver discovery request it sends the packet to this IP address.
+#
+
+option proxy.mcast-discovery-addr code 7 = ip-address;
+
+#
+# This sub-option serves two purposes.  If the client cannot find a
+# bootserver using multicast and broadcast discovery and this sub-option
+# is present, the client will transmit unicast discovery packets to each
+# bootserver in this list.  If bit 3 in discovery-control is set the
+# client will only accept bootserver discovery replies  if the bootserver
+# IP address is in this list.
+
+option proxy.boot-servers code 8 = array of
+	{ unsigned integer 16, unsigned integer 8, array of ip-address };
+
+#
+# This sub-option provides a boot menu of one or more items that can be
+# displayed by the PXE Client.
+#
+
+option proxy.boot-menu code 9 = array of
+	{ unsigned integer 16, unsigned integer 8, text };
+
+#
+# This sub-option provides the client with an option remote boot prompt
+# and timeout.  A timeout of zero means to auto-select the first item
+# in the remote boot menu.  A timeout of 255 means to display the prompt
+# and the remote boot menu and wait for the user to select (no timeout).
+# All other values are the number of seconds (1 to 254) to wait for
+# user selection.  If no selection is made before the timeout expires
+# the first item in the remote boot menu is auto-selected.
+#
+
+option proxy.boot-prompt code 10 +	{ unsigned integer 8, text };
+
+#
+# This sub-option is sent to the proxyDHCP server if the client supports
+# remote boot security.  The client must send a list of all of the
+# credential types it supports.  More information about remote boot
+# security can be found in the BIS specification.
+# http://developer.intel.com/ial/WfM/tools/BIS/Index.htm
+#
+
+option proxy.credential-types code 12 +	{ unsigned integer 16, unsigned integer 16 };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Simple sample scope.
+#
+
+subnet 192.168.13.0 netmask 255.255.255.0 {
+	range 192.168.13.1 192.168.13.10;
+
+	#
+	# If this is not a valid proxy packet, do not reply to
+	# the client.
+	#
+
+	if not proxy {
+		deny booting;
+	}
+
+	#
+	# Send back different information based on client-architecture.
+	#
+
+	if option client-architecture = 00:00 {
+
+		#
+		# For really old PXE clients we must send back a valid
+		# bootstrap program that will display the remote boot
+		# menu because the old clients do not do this inside
+		# the boot ROM.
+		#
+
+		if option network-interface-identifier = 01:02:00 {
+			filename "X86PC/UNDI/bstrap/bstrap.0";
+		}
+
+		#
+		# We must send back "PXEClient" or the client will
+		# ignore us.
+		#
+
+		option vendor-class-identifier "PXEClient";
+
+		#
+		# All bootserver discovery methods supported.
+		#
+
+		option proxy.discovery-control 0;
+
+		#
+		# All of our bootservers are listening on this multicast
+		# address.
+		#
+
+		option proxy.mcast-discovery-addr 224.0.1.2;
+
+		#
+		# This bootserver list will be used for unicast discovery
+		# if the client does not get any response to its multicast
+		# and broadcast discovery requests.
+		#
+
+		option proxy.boot-servers
+			3 2 192.168.13.253, 192.168.13.252;
+
+		#
+		# Remote boot prompt and timeout.
+		#
+
+		option proxy.boot-prompt
+			30 "Press <F8> or <M> for menu.  Press <Esc> or
<Ctrl+C> to local boot.";
+
+		#
+		# Menu that will be displayed when <F8> or <M> is pressed.
+		#
+
+		option proxy.boot-menu
+			0 10 "Local boot",
+			3 8 "DOS/UNDI";
+
+		#
+		# Include vendor options in reply to client.
+		#
+
+		vendor-option-space proxy;
+	}
+}
diff -ruN ../dhcp-3.0/server/stables.c ./server/stables.c
--- ../dhcp-3.0/server/stables.c	Thu Jun 21 19:35:08 2001
+++ ./server/stables.c	Fri Oct  5 10:16:41 2001
@@ -816,7 +816,9 @@
 				 &agent_options [i], MDL);
 	}
 	agent_universe.enc_opt = &dhcp_options [DHO_DHCP_AGENT_OPTIONS];
-
+/* %%PXE begin */
+	agent_universe.is_vendor = 0;
+/* %%PXE end */
 
 	/* Set up the server option universe... */
 	server_universe.name = "server";
@@ -842,6 +844,9 @@
 				 server_options [i].name, 0,
 				 &server_options [i], MDL);
 	}
+/* %%PXE begin */
+	server_universe.is_vendor = 0;
+/* %%PXE end */
 
 	/* Add the server and agent option spaces to the option space hash.
*/
 	universe_hash_add (universe_hash,
diff -ruN ../dhcp-3.0/server/superdhcp.conf ./server/superdhcp.conf
--- ../dhcp-3.0/server/superdhcp.conf	Wed Dec 31 16:00:00 1969
+++ ./server/superdhcp.conf	Fri Oct  5 10:16:41 2001
@@ -0,0 +1,619 @@
+#
+# /etc/dhcpd.conf - Configuration file that implements DHCP,
+# proxyDHCP and bootserver functionality.
+#
+# More information about proxyDHCP server, bootserver and PXE client
+# operation, proxyDHCPOFFER packet contents and bootserver request and
+# reply packet contents can be found in the PXE specification
+# at: http://developer.intel.com/ial/wfm/wfmspecs.htm
+#
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+#
+# Briefly, a proxyDHCP server is intended to sit next to a DHCP server
+# and provide PXE clients with additional remote information.  The
+# difference between a proxyDHCP server and a DHCP server is that the
+# proxyDHCP server does not return IP address or IP lease information
+# and that proxyDHCP servers only respond to DHCPDISCOVER packets that
+# have come from PXE clients.
+#
+# A DHCPDISCOVER packet from a PXE client meets the following requirements:
+#
+#   - Contains a vendor-class-identifier (option 60) that is at least
+#     9 octets in length with the first 9 characters set to "PXEClient"
+#     (without the quotes).
+#
+#  - Contains a client-architecture (option 93) that is 2 octets in length.
+#
+#  - Contains a network-interface-identifier (option 94) that is 3 octets
+#    in length.
+#
+#  - Does not contain vendor-encapsulated-options (option 43) or if it
+#    does contain vendor-encapsulated-options an encapsulated pxe.boot-item
+#    (sub-option 71) is not present in the encapsulated option.
+#
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Enable proxyDHCP operation.
+#
+
+dhcpd-operation normal;
+# dhcpd-operation proxy;
+# dhcpd-operation disable;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Enable bootserver operation.
+#
+
+bootserver-operation on;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Respond to multicast bootserver discover request packets.
+#
+
+mcast-discovery-addr 224.0.1.2;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Needed by DHCP daemon.
+#
+
+ddns-update-style ad-hoc;
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Define PXE client options.
+#
+# Values for these options are defined in the PXE specification.
+# http://developer.intel.com/ial/wfm/wfmspecs.htm
+#
+# Additional values can be found in the EFI specification.
+# http://developer.intel.com/technology/efi/index.htm
+#
+
+#
+# This option is used to determine the client boot-time binary runtime
+# environment.
+#
+
+option client-architecture code 93 +	unsigned integer 16;
+
+#
+# This option is used to determine the version of the UNDI (Universal
+# Network Driver Interface) implemented in the client.
+#
+
+option network-interface-identifier code 94 +	{ unsigned integer 8, unsigned integer 8, unsigned integer 8 };
+
+#
+# This option is used to uniquely identify the booting client.  When
+# possible GUIDs should be used instead of MAC address to identify a
+# client machine.  Think of a docking station with a NIC:  Every laptop
+# inserted into the docking station will have the same MAC address but
+# each laptop will have its own GUID.
+#
+
+option client-guid code 97 +	{ unsigned integer 8, string };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Describe proxyDHCP vendor-option-space.
+#
+# Values and more detailed descriptions for these sub-options can be found
+# in the PXE specification.
+#
+
+option space proxy;
+
+#
+# This sub-option is a bitfield that defines the types of bootserver
+# discovery requests that can be made by the PXE client.  This sub-option
+# does not need to be present.  If this sub-option is not present, PXE
+# clients assume a default discovery-control of zero (00h).
+#
+# Bit 0 (01h): If set, the client must not do broadcast discovery.
+#
+# Bit 1 (02h): If set, the client must not do multicast discovery.
+# If not set, mcast-discovery-addr must be present.
+#
+# Bit 2 (04h): If set, only accept responses from servers in the
+# boot-servers sub-option.
+#
+# Bit 3 (08h): If set and a bootfile is present in the DHCPACK or
+# proxyDHCPOFFER packet, just download the file using TFTP and run it.
+# Do not try to display a boot-prompt or boot-menu.
+#
+
+option proxy.discovery-control code 6 = unsigned integer 8;
+
+#
+# This sub-option defines the multicast IP address that is being used
+# by all of the bootservers.  When a PXE client transmits a multicast
+# bootserver discovery request it sends the packet to this IP address.
+#
+
+option proxy.mcast-discovery-addr code 7 = ip-address;
+
+#
+# This sub-option serves two purposes.  If the client cannot find a
+# bootserver using multicast and broadcast discovery and this sub-option
+# is present, the client will transmit unicast discovery packets to each
+# bootserver in this list.  If bit 3 in discovery-control is set the
+# client will only accept bootserver discovery replies  if the bootserver
+# IP address is in this list.
+
+option proxy.boot-servers code 8 = array of
+	{ unsigned integer 16, unsigned integer 8, array of ip-address };
+
+#
+# This sub-option provides a boot menu of one or more items that can be
+# displayed by the PXE Client.
+#
+
+option proxy.boot-menu code 9 = array of
+	{ unsigned integer 16, unsigned integer 8, text };
+
+#
+# This sub-option provides the client with an option remote boot prompt
+# and timeout.  A timeout of zero means to auto-select the first item
+# in the remote boot menu.  A timeout of 255 means to display the prompt
+# and the remote boot menu and wait for the user to select (no timeout).
+# All other values are the number of seconds (1 to 254) to wait for
+# user selection.  If no selection is made before the timeout expires
+# the first item in the remote boot menu is auto-selected.
+#
+
+option proxy.boot-prompt code 10 +	{ unsigned integer 8, text };
+
+#
+# This sub-option is sent to the proxyDHCP server if the client supports
+# remote boot security.  The client must send a list of all of the
+# credential types it supports.  More information about remote boot
+# security can be found in the BIS specification.
+# http://developer.intel.com/ial/WfM/tools/BIS/Index.htm
+#
+
+option proxy.credential-types code 12 +	{ unsigned integer 16, unsigned integer 16 };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+#
+# Bootserver request packets are accepted from PXE clients if they meet
+# the following requirements:
+#
+#   - The client IP address (ciaddr) field in the packet header is
+#     filled in with a valid unicast IP address.
+#
+#   - The packet contains a vendor-class-identifier (option 60) that is
+#     at least 9 octets in length with the first 9 characters set to
+#     "PXEClient" (without the quotes).
+#
+#  - The packet contains a client-architecture (option 93) that is 2 octets
+#    in length.
+#
+#  - The packet contains a network-interface-identifier (option 94) that
+#    is 3 octets in length.
+#
+#  - The packet contains vendor-encapsulated-options (option 43) that
+#    contains an encapsulated pxe.boot-item (sub-option 71) that is
+#    4 octets in length.
+#
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Descibe bootserver vendor-option-space.
+#
+# Values and more detailed descriptions for these sub-options can be found
+# in the PXE specification.
+#
+
+option space bs;
+
+#
+# MTFTP (Multicast Trivial File Transfer Protocol) IP address.
+# This is the MTFTP multicast IP address that is associated with
+# this file.  If MTFTP is not used, do not return this sub-option.
+#
+
+option bs.mtftp-ip code 1 = ip-address;
+
+#
+# MTFTP client listening port.  This is the UDP port that the client
+# must use to listen for and receive MTFTP data packets.  If MTFTP
+# is not used, do not return this sub-option.
+#
+
+option bs.mtftp-cport code 2 = unsigned integer 16;
+
+#
+# MTFTP server listening port.  This is the UDP port that the server
+# must use to accept MTFTP open requests.  If MTFTP is not used, do
+# not return this sub-option.
+#
+
+option bs.mtftp-sport code 3 = unsigned integer 16;
+
+#
+# MTFTP client timeout.  This is the number of seconds that a client
+# must listen for its file before starting a new MTFTP download session.
+# This is also the number of seconds the client must wait before
+# retransmitting an acknowledgement packet if a data packet is not
+# received.  If MTFTP is not used, do not return this sub-option.
+#
+
+option bs.mtftp-tmout code 4 = unsigned integer 8;
+
+#
+# MTFTP client restart delay.  This is the maximum number of seconds
+# that a client must listen before requesting a new MTFTP download
+# sesson of the file it was listening to.  If MTFTP is not used, do
+# not return this sub-options.
+#
+
+option bs.mtftp-delay code 5 = unsigned integer 8;
+
+#
+# This sub-option is sent to the proxyDHCP server if the client supports
+# remote boot security.  The client must send a list of all of the
+# credential types it supports.  More information about remote boot
+# security can be found in the BIS specification.
+# http://developer.intel.com/ial/WfM/tools/BIS/Index.htm
+#
+
+option bs.credential-types code 12 +	{ unsigned integer 16, unsigned integer 16 };
+
+#
+# This sub-option is sent by the client to request a specific bootserver
+# type and image number.  This sub-option is also sent back by the
+# bootserver.  The bootserver type cannot be changed but the image number
+# may be changed.
+#
+
+option bs.boot-item code 71 +	{ unsigned integer 16, unsigned integer 16 };
+
+# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
+# Simple sample scope.
+#
+
+subnet 192.168.13.0 netmask 255.255.255.0 {
+	range 192.168.13.1 192.168.13.10;
+
+	#
+	# Check for DHCPDISCOVER and DHCPREQUEST packets that may also
+	# need proxyDHCP information appended to them.
+	#
+
+	if proxy {
+		#
+		# Provide proxyDHCP information for Intel x86 PC/AT
+		# architecture PCs.
+		#
+
+		if option client-architecture = 00:00 {
+
+			#
+			# For really old PXE clients we must send back a
valid
+			# bootstrap program that will display the remote
boot
+			# menu because the old clients do not do this inside
+			# the boot ROM.
+			#
+
+			if option network-interface-identifier = 01:02:00 {
+				filename "X86PC/UNDI/bstrap/bstrap.0";
+			}
+
+			#
+			# We must send back "PXEClient" or the client will
+			# ignore us.
+			#
+
+			option vendor-class-identifier "PXEClient";
+
+			#
+			# With only one machine running DHCP w/ proxyDHCP
+			# and bootserver functionality, broadcast discovery
+			# cannot be used.  This is because the broadcast
+			# bootserver packets look too much like DHCPREQUEST
+			# or DHCPINFORM packets.  This still leaves us
+			# multicast and unicast discovery mechanisms.
+			#
+
+			option proxy.discovery-control 1;
+
+			#
+			# All of our bootservers are listening on this
+			# multicast address.
+			#
+
+			option proxy.mcast-discovery-addr 224.0.1.2;
+
+			#
+			# This bootserver list will be used for unicast
+			# discovery if the client does not get any response
+			# to its multicast discovery requests.
+			#
+
+			option proxy.boot-servers
+				3 2 192.168.13.253, 192.168.13.252;
+
+			#
+			# Remote boot prompt and timeout.
+			#
+
+			option proxy.boot-prompt
+				30 "Press <F8> or <M> for menu.  Press <Esc>
or <Ctrl+C> to local boot.";
+
+			#
+			# Menu that will be displayed when <F8> or <M> is
+			# pressed.
+			#
+
+			option proxy.boot-menu
+				0 10 "Local boot",
+				3 8 "DOS/UNDI";
+
+			#
+			# Include vendor options in reply to client.
+			#
+
+			vendor-option-space proxy;
+		} else
+
+		#
+		# Provide proxyDHCP information for Intel ia64
+		# architecture machines.
+		#
+
+		if option client-architecture = 00:02 {
+
+			#
+			# We must send back "PXEClient" or the client will
+			# ignore us.
+			#
+
+			option vendor-class-identifier "PXEClient";
+
+			#
+			# With only one machine running DHCP w/ proxyDHCP
+			# and bootserver functionality, broadcast discovery
+			# cannot be used.  This is because the broadcast
+			# bootserver packets look too much like DHCPREQUEST
+			# or DHCPINFORM packets.  This still leaves us
+			# multicast and unicast discovery mechanisms.
+			#
+
+			option proxy.discovery-control 1;
+
+			#
+			# All of our bootservers are listening on this
+			# multicast address.
+			#
+
+			option proxy.mcast-discovery-addr 224.0.1.2;
+
+			#
+			# This bootserver list will be used for unicast
+			# discovery if the client does not get any response
+			# to its multicast discovery requests.
+			#
+
+			option proxy.boot-servers
+				3 2 192.168.13.253, 192.168.13.252;
+
+			#
+			# Remote boot prompt and timeout.
+			#
+
+			option proxy.boot-prompt
+				30 "Press <F8> or <M> for menu.  Press <Esc>
or <Ctrl+C> to local boot.";
+
+			#
+			# Menu that will be displayed when <F8> or <M> is
+			# pressed.
+			#
+
+			option proxy.boot-menu
+				0 10 "Local boot",
+				14 8 "RedHat Linux64 Remote Boot";
+
+			#
+			# Include vendor options in reply to client.
+			#
+
+			vendor-option-space proxy;
+		}
+	} else if bootserver {
+		#
+		# Send back different information based on
client-architecture.
+		# This configuration file is for a bootserver that sends
back
+		# images for Intel x86 PC/AT and ia64 architecture clients.
+		#
+
+		if option client-architecture = 00:00 {
+			#
+			# Send back different information based on
bootserver
+			# type.  This configuration file is for a bootserver
+			# that sends back DOS/UNDI remote boot images.
+			#
+
+			if not (substring(option bs.boot-item, 0, 2) 00:03) {
+				deny booting;
+			}
+
+			#
+			# Only two image layer numbers are supported.
+			#
+
+			if substring(option bs.boot-item, 2, 2) = 00:00 {
+
+				#
+				# Send back the filename for layer zero.
+				#
+
+				filename "X86PC/UNDI/DOSUNDI/dosundi.0";
+
+				#
+				# Send back "PXEClient" so the reply is not
+				# ignored by the client.
+				#
+
+				option vendor-class-identifier "PXEClient";
+
+				#
+				# Send back the image number so the reply is
not
+				# ignored by the client.
+				#
+
+				option bs.boot-item 3 0;
+
+				#
+				# Send back the vendor option space.
+				#
+
+				vendor-option-space bs;
+			} else if substring(option bs.boot-item, 2, 2) 00:01 {
+
+				#
+				# Send back the filename for layer one.
+				#
+
+				filename "X86PC/UNDI/DOSUNDI/dosundi.1";
+
+				#
+				# Send back "PXEClient" so the reply is not
+				# ignored by the client.
+				#
+
+				option vendor-class-identifier "PXEClient";
+
+				#
+				# Send back the image number so the reply is
not
+				# ignored by the client.
+				#
+
+				option bs.boot-item 3 1;
+
+				#
+				# Send back the vendor option space.
+				#
+
+				vendor-option-space bs;
+			}
+		} else if option client-architecture = 00:02 {
+			#
+			# Send back different information based on
bootserver
+			# type.  This configuration file is for a bootserver
+			# that sends back RedHat Linux64 remote boot images.
+			#
+
+			if not (substring(option bs.boot-item, 0, 2) 00:0E) {
+				deny booting;
+			}
+
+			#
+			# Only three image layer numbers are supported.
+			#
+
+			if substring(option bs.boot-item, 2, 2) = 00:00 {
+
+				#
+				# Send back the filename for layer zero.
+				# This is the just the eli.efi or lilo.efi
+				# application renamed to linux.0.
+				#
+
+				filename
"ia64-efi/undi/redhat-linux64/linux.0";
+
+				#
+				# Send back "PXEClient" so the reply is not
+				# ignored by the client.
+				#
+
+				option vendor-class-identifier "PXEClient";
+
+				#
+				# Send back the image number so the reply is
not
+				# ignored by the client.
+				#
+
+				option bs.boot-item 14 0;
+
+				#
+				# Send back the vendor option space.
+				#
+
+				vendor-option-space bs;
+			} else if substring(option bs.boot-item, 2, 2) 00:01 {
+
+				#
+				# Send back the filename for layer one.
+				# This is the Linux kernel renamed to
linux.1.
+				#
+
+				filename
"ia64-efi/undi/redhat-linux64/linux.1";
+
+				#
+				# Send back "PXEClient" so the reply is not
+				# ignored by the client.
+				#
+
+				option vendor-class-identifier "PXEClient";
+
+				#
+				# Send back the image number so the reply is
not
+				# ignored by the client.
+				#
+
+				option bs.boot-item 14 1;
+
+				#
+				# Send back the vendor option space.
+				#
+
+				vendor-option-space bs;
+			} else if substring(option bs.boot-item, 2, 2) 00:02 {
+				#
+				# If you do not use initrd then comment out
this
+				# else-if code, if the client gets a reply
for
+				# the linux.2 request it assumes that an
initrd
+				# image is required for remote boot to
succeed.
+				#
+
+				#
+				# Send back the filename for layer one.
+				# This is the Linux initrd renamed to
linux.2.
+				#
+
+				filename
"ia64-efi/undi/redhat-linux64/linux.2";
+
+				#
+				# Send back "PXEClient" so the reply is not
+				# ignored by the client.
+				#
+
+				option vendor-class-identifier "PXEClient";
+
+				#
+				# Send back the image number so the reply is
not
+				# ignored by the client.
+				#
+
+				option bs.boot-item 14 2;
+
+				#
+				# Send back the vendor option space.
+				#
+
+				vendor-option-space bs;
+			}
+		} else {
+			deny booting;
+		}
+	} else {
+		#
+		# Any other normal DHCP stuff can be done here.
+		#
+	}
+}

-----Original Message-----
From: Michael Madore [mailto:mmadore@turbolinux.com]
Sent: Wednesday, January 16, 2002 10:57 AM
To: eranian@hpl.hp.com
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] PXE Boot


Stephane Eranian wrote:
> 
> Mike,
> 
> On Wed, Jan 16, 2002 at 10:57:25AM -0800, Michael Madore wrote:
> >
> > I'm trying to boot a Big Sur workstation (Firmware 117C) via the
> > network.  The workstation receives an address via dhcp and when starting
> > to download elilo.efi I get the following error message:
> >
> > PXE-E05: Download buffer is smaller than requested file.
> > Load of PXE boot failed:  File not found
> >
> Do you get this everytime? I have already seen this problem but it
disappears
> if you retry, if I recall correctly.

I get the same message when I retry.
 
> > Does this message really indicate the buffer is to small, or is this a
> > symptom of a different problem?
> >
> Are you using a PXE-aware DHCP server or a standard DHCP server?

I am using ISC dhcp 3.  I'm not sure if it is exactly PXE aware, but it
does allow vendor options to be specified.  For example, if I put the
following in my dhcpd.conf file:

set client-id=option vendor-class-identifier;

subnet 192.168.1.0 netmask 255.255.255.0 {
   range 192.168.1.100 192.168.1.200;
   filename "/tftpboot/elilo.efi";
}

I get the following in dhcpd.leases (along with the usual info):

set client-id="PXEClient:Arch:00002:UNDI:003000"

Mike

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

