From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 18 Jul 2002 20:36:52 +0000
Subject: [Linux-ia64] forwarded message from Rusty Trivial Russell
MIME-Version: 1
Content-Type: multipart/mixed; boundary="vLr0uSZoR4"
Message-Id: <marc-linux-ia64-105590701905781@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--vLr0uSZoR4
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

Could someone from SGI take care of this?

Thanks,

	--david


--vLr0uSZoR4
Content-Type: message/rfc822
Content-Description: forwarded message
Content-Transfer-Encoding: 7bit

Return-Path: <rusty@samba.org>
Received: from hplms2.hpl.hp.com (root@hplms2.hpl.hp.com [15.0.152.33])
	by napali.hpl.hp.com (8.12.2/8.12.2/Debian -5) with ESMTP id g6I3Mpuh007784
	for <davidm@napali.hpl.hp.com>; Wed, 17 Jul 2002 20:22:51 -0700
Received: from deimos.hpl.hp.com (deimos.hpl.hp.com [15.0.48.190])
	by hplms2.hpl.hp.com (8.10.2/8.10.2 HPL-PA Hub) with ESMTP id g6I3Mok16455
	for <davidm@hpl.hp.com>; Wed, 17 Jul 2002 20:22:51 -0700 (PDT)
Received: from lists.samba.org (samba.sourceforge.net [198.186.203.85])
	by deimos.hpl.hp.com (8.9.3 (PHNE_24419)/HPL-PA Relay) with ESMTP id UAA09300
	for <davidm@hpl.hp.com>; Wed, 17 Jul 2002 20:22:50 -0700 (PDT)
Received: by lists.samba.org (Postfix, from userid 1080)
	id A35FA4474; Wed, 17 Jul 2002 20:23:29 -0700 (PDT)
Message-Id: <20020718032329.A35FA4474@lists.samba.org>
From: Rusty Trivial Russell <rusty@rustcorp.com.au>
Sender: rusty@rustcorp.com.au
To: davidm@hpl.hp.com
Subject: [TRIVIAL] PATCH 2.5: kconfig spurious bool default value (1_3)
Date: Thu, 18 Jul 2002 13:08:30 +1000

From: (via Rusty) Greg Banks <gnb@alphalink.com.au>

  
  Some CML1 rule contributors seem to think that the "bool" statement
  takes a third argument which is the default value.  It doesn't.
  

--- trivial-2.5.26/arch/ia64/config.in.orig	Thu Jul 18 13:00:51 2002
+++ trivial-2.5.26/arch/ia64/config.in	Thu Jul 18 13:00:51 2002
@@ -71,15 +71,15 @@
 
 if [ "$CONFIG_IA64_SGI_SN1" = "y" -o  "$CONFIG_IA64_SGI_SN2" = "y" ]; then
 	define_bool CONFIG_IA64_SGI_SN y
-	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG n
+	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
 	bool '  Enable autotest (llsc). Option to run cache test instead of booting' \
-			CONFIG_IA64_SGI_AUTOTEST n
+			CONFIG_IA64_SGI_AUTOTEST
 	define_bool CONFIG_DEVFS_FS y
 	if [ "$CONFIG_DEVFS_FS" = "y" ]; then
-	  bool '    Enable DEVFS Debug Code' CONFIG_DEVFS_DEBUG n
+	  bool '    Enable DEVFS Debug Code' CONFIG_DEVFS_DEBUG
 	fi
-	bool '  Enable protocol mode for the L1 console' CONFIG_SERIAL_SGI_L1_PROTOCOL y
+	bool '  Enable protocol mode for the L1 console' CONFIG_SERIAL_SGI_L1_PROTOCOL
 	define_bool CONFIG_DISCONTIGMEM y
 	define_bool CONFIG_IA64_MCA y
 	define_bool CONFIG_NUMA y
-- 
  Don't blame me: the Monkey is driving

--vLr0uSZoR4--

