From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Thu, 14 Nov 2002 08:30:37 +0000
Subject: [Linux-ia64] [Fwd: memcpy failure]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------A8F147D39BD9FC4BE5987695"
Message-Id: <marc-linux-ia64-105590709805422@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805421@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------A8F147D39BD9FC4BE5987695
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

ditto.
--------------A8F147D39BD9FC4BE5987695
Content-Type: message/rfc822
Content-Disposition: inline

Received: from ecbull20.frec.bull.fr (ecbull20.frec.bull.fr [129.183.4.3])
	by isatis.frec.bull.fr (AIX4.3/8.9.3/8.9.3) with ESMTP id TAA208530
	for <ccb@isatis.frec.bull.fr>; Tue, 12 Nov 2002 19:48:12 +0100
Received: from ecsweep.frec.bull.fr (ecsweep [129.183.4.101])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id TAA24402
	for <Christian.Cotte-Barrot@frec.bull.fr>; Tue, 12 Nov 2002 19:48:14 +0100
Received: from odin.bull.net (unverified) by ecsweep.frec.bull.fr
 (Content Technologies SMTPRS 4.1.5) with ESMTP id <T81b7046510f5e8623c0d2@ecsweep.frec.bull.fr> for <Christian.Cotte-Barrot@frec.bull.fr>;
 Tue, 12 Nov 2002 19:30:15 +0100
Received: from petasus.ch.intel.com (petasus.ch.intel.com [143.182.124.5])
	by odin.bull.net (8.9.3/8.9.3) with ESMTP id TAA60312
	for <Christian.Cotte-Barrot@bull.net>; Tue, 12 Nov 2002 19:30:17 +0100
Received: from fmsmsxvs043.fm.intel.com (fmsmsxvs043.fm.intel.com [132.233.42.129])
	by petasus.ch.intel.com (8.11.6/8.11.6/d: solo.mc,v 1.48 2002/10/16 23:47:34 dmccart Exp $) with SMTP id gACIUeD23006
	for <Christian.Cotte-Barrot@bull.net>; Tue, 12 Nov 2002 18:30:41 GMT
Received: from fmsmsx331.fm.intel.com ([132.233.42.156])
 by fmsmsxvs043.fm.intel.com (NAVGW 2.5.2.11) with SMTP id M2002111210273600732
 ; Tue, 12 Nov 2002 10:27:37 -0800
Received: from fmsmsx331.amr.corp.intel.com ([132.233.42.135]) by fmsmsx331.fm.intel.com with Microsoft SMTPSVC(5.0.2195.5329);
	 Tue, 12 Nov 2002 10:29:23 -0800
Received: from fmsmsx405.amr.corp.intel.com ([132.233.42.209]) by fmsmsx331.amr.corp.intel.com with Microsoft SMTPSVC(5.0.2195.5329);
	 Tue, 12 Nov 2002 10:29:23 -0800
content-class: urn:content-classes:message
Subject: RE: memcpy failure
Date: Tue, 12 Nov 2002 10:29:23 -0800
Message-ID: <51568623CC066847A1DC7EB0D95B587A181FC0@fmsmsx405.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Thread-Topic: memcpy failure
X-MimeOLE: Produced By Microsoft Exchange V6.0.6249.0
Thread-Index: AcKKZBACViz3hfZWEdaNBwBQi+Bs2AAFTiGg
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
To: "Christian Cotte-Barrot" <Christian.Cotte-Barrot@bull.net>
Cc: "David Mosberger" <davidm@napali.hpl.hp.com>,
        "Stephane Eranian" <eranian@frankl.hpl.hp.com>
X-OriginalArrivalTime: 12 Nov 2002 18:29:23.0855 (UTC) FILETIME=[6CA9F9F0:01C28A79]
X-MIME-Autoconverted: from quoted-printable to 8bit by isatis.frec.bull.fr id TAA208530
X-Mozilla-Status2: 00000000
Content-Transfer-Encoding: 8bit

The retrun value for memcpy doesn't follow the user space memcpy exactly.
kernel memcpy always return 0.
- Ken

-----Original Message-----
From: Christian Cotte-Barrot [mailto:Christian.Cotte-Barrot@bull.net]
Sent: Tuesday, November 12, 2002 7:51 AM
To: Chen, Kenneth W
Cc: David Mosberger; Stephane Eranian; Cotte-Barrot Christian
Subject: memcpy failure


Hi Ken,

sorry to disturb you directly, but I found your name in the source file
I have some concern with (./arch/ia64/lib/memcpy_mck.S)
I am currently porting a serial line driver to linux IA64 release 2.4.19
on a tiger machine.
This driver checks the return from the memcpy function that should be
a pointer to dest as the man says.
The return from the memcpy function seems to be always null.
I put some printk traces in the driver and it appeared that although
the return does not comply with the man the copy is correctly (hopefully) done
(the printk reports the first three and the last three bytes of the dest
area before and after the memcpy call and we can see that they have been
overwritten).
Is it right to check the return from memcpy ?

Here are some typical outputs picked up in /var/log/messages:
...
Nov  8 16:13:51 bza kernel: epca: receive_data : dest before memcpy  0x72 0x77 0x2D ...
0x6B 0x20 0x20
Nov  8 16:13:51 bza kernel: epca: receive_data : memcpy failed, dest 0xE000000071112468
src 0xC0000000E2C1A9DC n 512 rdest 0x0000000000000000
Nov  8 16:13:51 bza kernel: epca: receive_data : dest after memcpy  0x33 0x33 0x3B ...
0x20 0x20 0x20
...

From memcpy_mck.S, both memcpy and __copy_user functions return
the same null value initialized in the common_code part:
  ./arch/ia64/lib/memcpy_mck.S
    ...
  GLOBAL_ENTRY(memcpy)
          and     r28=0x7,in0
          and     r29=0x7,in1
          mov     f6=f0
          br.cond.sptk .common_code
          ;;
  END(memcpy)
  GLOBAL_ENTRY(__copy_user)
          .prologue
  // check dest alignment
          and     r28=0x7,in0
          and     r29=0x7,in1
          mov     f6=f1
          mov     saved_in0=in0   // save dest pointer
          mov     saved_in1=in1   // save src pointer
          mov     saved_in2=in2   // save len
          ;;
  .common_code:
          cmp.gt  p15,p0=8,in2    // check for small size
          cmp.ne  p13,p0=0,r28    // check dest alignment
          cmp.ne  p14,p0=0,r29    // check src alignment
          add     src0=0,in1
          sub     r30=8,r28       // for .align_dest
          mov     retval=r0       // initialize return value
          ;;
    ...

But According to the old sources memcpy.S and copy_user.S they
used to return different values, dest for memcpy and null for copy_user
  ./arch/ia64/lib/memcpy.S
    ...
    GLOBAL_ENTRY(memcpy)
    ...
          .body
          cmp.eq p6,p0=in2,r0     // zero length?
          mov retval=in0          // return dst
    ...

  ./arch/ia64/lib/copy_user.S
    ...
    GLOBAL_ENTRY(__copy_user)
    ...
          adds len2=-1,len        // br.ctop is repeat/until
          mov ret0=r0
    ...

It's certainly not the better way to modify memcpy_mck.S but
here is a simple and trivial patch I tried and that corrects
the problem:
  ./arch/ia64/lib/memcpy_mck.S
    ...
  GLOBAL_ENTRY(memcpy)
          and     r28=0x7,in0
          and     r29=0x7,in1
          mov     f6=f0
          mov retval=in0          // return dst
          br.cond.sptk .common_code
          ;;
  END(memcpy)
  GLOBAL_ENTRY(__copy_user)
          .prologue
  // check dest alignment
          and     r28=0x7,in0
          and     r29=0x7,in1
          mov     f6=f1
          mov     saved_in0=in0   // save dest pointer
          mov     saved_in1=in1   // save src pointer
          mov     saved_in2=in2   // save len
          mov     retval=r0       // initialize return value
          ;;
  .common_code:
          cmp.gt  p15,p0=8,in2    // check for small size
          cmp.ne  p13,p0=0,r28    // check dest alignment
          cmp.ne  p14,p0=0,r29    // check src alignment
          add     src0=0,in1
          sub     r30=8,r28       // for .align_dest
          ;;
    ...

Regards.
-- 
+===========+=======================+==================================+
|  |\/\/\/| |                       |                                  |
|  |      | |Christian Cotte-Barrot |org.  :BULL/                      |
|  | (~)(o) |Bull S.A.              |office:FREC/B1-401                |
| C      _) |1, rue de Provence     |mailto:                           |
|  | ,___|  |B.P. 208               |   Christian.Cotte-Barrot@bull.net|
|  |   /    |38432 ECHIROLLES CEDEX |phone :+33 (0)476297725 (229 7725)|
| /----\    |FRANCE                 |fax   :+33 (0)476297891 (229 7891)|
+===========+=======================+==================================+


--------------A8F147D39BD9FC4BE5987695--


