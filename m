From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Thu, 14 Nov 2002 08:28:45 +0000
Subject: [Linux-ia64] [Fwd: memcpy failure]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------8B895613766A1B691CD05BE3"
Message-Id: <marc-linux-ia64-105590709805421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------8B895613766A1B691CD05BE3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Forwarded this here because it looks like really a bug.
--------------8B895613766A1B691CD05BE3
Content-Type: message/rfc822
Content-Disposition: inline

Received: from ecbull20.frec.bull.fr (ecbull20.frec.bull.fr [129.183.4.3])
	by isatis.frec.bull.fr (AIX4.3/8.9.3/8.9.3) with ESMTP id QAA121780
	for <ccb@isatis.frec.bull.fr>; Tue, 12 Nov 2002 16:51:26 +0100
Received: from isatis.frec.bull.fr (isatis.frec.bull.fr [129.183.144.1])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id QAA27144;
	Tue, 12 Nov 2002 16:51:26 +0100
Received: from bull.net (localhost [127.0.0.1])
	by isatis.frec.bull.fr (AIX4.3/8.9.3/8.9.3) with ESMTP id QAA233902;
	Tue, 12 Nov 2002 16:51:19 +0100
Sender: Christian.Cotte-Barrot@bull.net
Message-ID: <3DD12376.AC558193@bull.net>
Date: Tue, 12 Nov 2002 16:51:19 +0100
From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Organization: Bull S.A.
X-Mailer: Mozilla 4.78 [en] (X11; U; AIX 4.3)
X-Accept-Language: fr, en
MIME-Version: 1.0
To: Ken Chen <kenneth.w.chen@intel.com>
CC: David Mosberger <davidm@napali.hpl.hp.com>,
        Stephane Eranian <eranian@frankl.hpl.hp.com>,
        Cotte-Barrot Christian <Christian.Cotte-Barrot@bull.net>
Subject: memcpy failure
Content-Type: text/plain; charset=us-ascii
X-Mozilla-Status2: 00000000
Content-Transfer-Encoding: 7bit

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


--------------8B895613766A1B691CD05BE3--


