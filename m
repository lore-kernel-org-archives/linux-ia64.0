From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 11 Mar 2004 00:30:29 +0000
Subject: [Fwd: Re: Virtual memory leaking through IA32 emulation layer for
Message-Id: <404FB325.9040502@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070306070906050501050108"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070306070906050501050108
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


[ I mistyped the email address for linux-ia64 ]

--------------070306070906050501050108
Content-Type: message/rfc822;
 name="Re: Virtual memory leaking through IA32 emulation layer for mmap   and munmap"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Re: Virtual memory leaking through IA32 emulation layer for mmap   and munmap"

Received: from scsmsx402.amr.corp.intel.com ([10.3.90.16]) by scsmsx401.amr.corp.intel.com with Microsoft SMTPSVC(5.0.2195.6713);
	 Wed, 10 Mar 2004 11:45:04 -0800
Received: from fmsmsx312.amr.corp.intel.com ([132.233.42.227]) by scsmsx402.amr.corp.intel.com with Microsoft SMTPSVC(5.0.2195.6713);
	 Wed, 10 Mar 2004 11:45:03 -0800
Received: from fmsmsx332.amr.corp.intel.com ([132.233.42.148]) by fmsmsx312.amr.corp.intel.com with Microsoft SMTPSVC(5.0.2195.6713);
	 Wed, 10 Mar 2004 11:45:01 -0800
Received: from azsmsxvs041.ch.intel.com ([143.182.252.55]) by fmsmsx332.amr.corp.intel.com with Microsoft SMTPSVC(5.0.2195.6713);
	 Wed, 10 Mar 2004 11:45:01 -0800
Received: from fcicdmzmail01.cs.intel.com ([192.55.36.23])
 by azsmsxvs041.ch.intel.com (SAVSMTP 3.1.2.35) with SMTP id M2004031012450029904
 for <arun.sharma@intel.com>; Wed, 10 Mar 2004 12:45:00 -0700
Received: from janus1.fc.hp.com ([15.232.16.17])
 by fcicdmzmail01.cs.intel.com (SAVSMTP 3.1.2.35) with SMTP id M2004031012451425446
 for <linux-ia64@vger.intel.com>; Wed, 10 Mar 2004 12:45:14 -0700
Received: from palrel10.hp.com (palrel10.hp.com [15.81.168.20])
	by janus1.fc.hp.com (Postfix) with ESMTP
	id 3F79063087; Wed, 10 Mar 2004 12:18:42 -0700 (MST)
Received: from hplms2.hpl.hp.com (hplms2.hpl.hp.com [15.0.152.33])
	by palrel10.hp.com (Postfix) with ESMTP
	id 223FD1C006B7; Wed, 10 Mar 2004 11:44:58 -0800 (PST)
Received: from napali.hpl.hp.com (napali.hpl.hp.com [15.4.89.123])
	by hplms2.hpl.hp.com (8.12.10/8.12.10/HPL-PA Hub) with ESMTP id i2AJiq7u007518;
	Wed, 10 Mar 2004 11:44:53 -0800 (PST)
Received: from napali.hpl.hp.com (napali [127.0.0.1])
	by napali.hpl.hp.com (8.12.11/8.12.11/Debian-1) with ESMTP id i2AJiq7h002381;
	Wed, 10 Mar 2004 11:44:52 -0800
Received: (from davidm@localhost)
	by napali.hpl.hp.com (8.12.11/8.12.11/Debian-1) id i2AJiqks002377;
	Wed, 10 Mar 2004 11:44:52 -0800
From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16463.28724.277502.132751@napali.hpl.hp.com>
Date: Wed, 10 Mar 2004 11:44:52 -0800
To: Arun Sharma <arun.sharma@intel.com>
Cc: davidm@hpl.hp.com, linux-ia64@vger.intel.com
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
   and munmap
In-Reply-To: <404F6D26.8010502@intel.com>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
	<16461.2968.682582.139300@wombat.chubb.wattle.id.au>
	<16461.3733.809634.212327@napali.hpl.hp.com>
	<16461.5771.740526.489351@wombat.chubb.wattle.id.au>
	<16461.6191.949155.778550@napali.hpl.hp.com>
	<20040310035801.GC23596@tlaloc.n0ano.com>
	<Pine.LNX.4.58.0403101614500.22838@sutekh.progsoc.uts.edu.au>
	<mailman.1078940988.14439@unix-os.sc.intel.com>
	<404F6D26.8010502@intel.com>
X-Mailer: VM 7.18 under Emacs 21.3.1
Reply-To: davidm@hpl.hp.com
X-URL: http://www.hpl.hp.com/personal/David_Mosberger/
Return-Path: davidm@napali.hpl.hp.com
X-OriginalArrivalTime: 10 Mar 2004 19:45:01.0709 (UTC) FILETIME=[2D5E8BD0:01C406D8]

>>>>> On Wed, 10 Mar 2004 11:31:50 -0800, Arun Sharma <arun.sharma@intel.com> said:

  Arun> Yes, I'd really like to see this problem fixed. I think, the
  Arun> patch needs to be as memory efficient as possible - we're
  Arun> using non-pageable kernel memory. So some numbers on the two
  Arun> level bitmap scheme vs keeping lists of head/tail pages for
  Arun> common ia32 workloads would be good.

Agreed.  The good news is that the track is only needed for parially
allocated pages, so the overhead should, in the worst-case, be
proportional to the number of vmareas, not to the amount of memory
mapped.

	--david

--------------070306070906050501050108--
