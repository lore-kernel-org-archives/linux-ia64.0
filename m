From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Thu, 14 Nov 2002 08:31:18 +0000
Subject: [Linux-ia64] [Fwd: memcpy failure]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------B39A4D8D3076814165662918"
Message-Id: <marc-linux-ia64-105590709805423@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805421@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------B39A4D8D3076814165662918
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

ditto.
--------------B39A4D8D3076814165662918
Content-Type: message/rfc822
Content-Disposition: inline

Received: from ecbull20.frec.bull.fr (ecbull20.frec.bull.fr [129.183.4.3])
	by isatis.frec.bull.fr (AIX4.3/8.9.3/8.9.3) with ESMTP id HAA157692
	for <ccb@isatis.frec.bull.fr>; Thu, 14 Nov 2002 07:03:43 +0100
Received: from ecsweep.frec.bull.fr (ecsweep [129.183.4.101])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id HAA14160
	for <Christian.Cotte-Barrot@frec.bull.fr>; Thu, 14 Nov 2002 07:03:43 +0100
Received: from odin.bull.net (unverified) by ecsweep.frec.bull.fr
 (Content Technologies SMTPRS 4.1.5) with ESMTP id <T81b7046510f5e8dbb0319@ecsweep.frec.bull.fr> for <Christian.Cotte-Barrot@frec.bull.fr>;
 Thu, 14 Nov 2002 06:52:49 +0100
Received: from deimos.hpl.hp.com (deimos.hpl.hp.com [192.6.19.190])
	by odin.bull.net (8.9.3/8.9.3) with ESMTP id GAA50572
	for <Christian.Cotte-Barrot@bull.net>; Thu, 14 Nov 2002 06:52:45 +0100
Received: from hplms2.hpl.hp.com (hplms2.hpl.hp.com [15.0.152.33])
	by deimos.hpl.hp.com (8.9.3 (PHNE_24419)/HPL-PA Relay) with ESMTP id VAA29035;
	Wed, 13 Nov 2002 21:52:14 -0800 (PST)
Received: from napali.hpl.hp.com (napali.hpl.hp.com [15.4.89.123])
	by hplms2.hpl.hp.com (8.10.2/8.10.2 HPL-PA Hub) with ESMTP id gAE5qDS09168;
	Wed, 13 Nov 2002 21:52:13 -0800 (PST)
Received: from napali.hpl.hp.com (napali [127.0.0.1])
	by napali.hpl.hp.com (8.12.3/8.12.3/Debian -4) with ESMTP id gAE5qDHW021129;
	Wed, 13 Nov 2002 21:52:13 -0800
Received: (from davidm@localhost)
	by napali.hpl.hp.com (8.12.3/8.12.3/Debian -4) id gAE5qC8e021125;
	Wed, 13 Nov 2002 21:52:12 -0800
From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <15827.14860.687278.896618@napali.hpl.hp.com>
Date: Wed, 13 Nov 2002 21:52:12 -0800
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: "Christian Cotte-Barrot" <Christian.Cotte-Barrot@bull.net>,
        "David Mosberger" <davidm@napali.hpl.hp.com>,
        "Stephane Eranian" <eranian@frankl.hpl.hp.com>
Subject: RE: memcpy failure
In-Reply-To: <51568623CC066847A1DC7EB0D95B587A181FC0@fmsmsx405.fm.intel.com>
References: <51568623CC066847A1DC7EB0D95B587A181FC0@fmsmsx405.fm.intel.com>
X-Mailer: VM 7.07 under Emacs 21.2.1
Reply-To: davidm@hpl.hp.com
X-URL: http://www.hpl.hp.com/personal/David_Mosberger/
X-Mozilla-Status2: 00000000
Content-Transfer-Encoding: 7bit

>>>>> On Tue, 12 Nov 2002 10:29:23 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> The retrun value for memcpy doesn't follow the user space
  Ken> memcpy exactly.  kernel memcpy always return 0.

Why are you saying this?  As far as I know, the kernel memcpy() is
expected to return the (initial) destination address.  Perhaps you're
thinking of copy_user()?

(If it was up to me, memcpy() would be returning void...).

	--david


--------------B39A4D8D3076814165662918--


