From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Mar 2002 19:41:58 +0000
Subject: [Linux-ia64] forwarded message from Russell King
MIME-Version: 1
Content-Type: multipart/mixed; boundary="zwykVQheeQ"
Message-Id: <marc-linux-ia64-105590701905296@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--zwykVQheeQ
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

I thought I'd forward this bug-report as I won't be able to act on it
before leaving for vacation.

	--david


--zwykVQheeQ
Content-Type: message/rfc822
Content-Description: forwarded message
Content-Transfer-Encoding: 7bit

Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Return-Path: <linux-kernel-owner@vger.kernel.org>
Received: from hplms2.hpl.hp.com (root@hplms2.hpl.hp.com [15.0.152.33])
	by napali.hpl.hp.com (8.12.1/8.12.1/Debian -5) with ESMTP id g2FDWhf7007188
	for <davidm@napali.hpl.hp.com>; Fri, 15 Mar 2002 05:32:43 -0800
Received: from deimos.hpl.hp.com (deimos.hpl.hp.com [15.0.48.190])
	by hplms2.hpl.hp.com (8.10.2/8.10.2 HPL-PA Hub) with ESMTP id g2FDWf209373
	for <davidm@hpl.hp.com>; Fri, 15 Mar 2002 05:32:42 -0800 (PST)
Received: from vger.kernel.org (vger.kernel.org [12.107.208.194])
	by deimos.hpl.hp.com (8.9.3 (PHNE_24419)/HPL-PA Relay) with ESMTP id FAA15002
	for <davidm@hpl.hp.com>; Fri, 15 Mar 2002 05:32:41 -0800 (PST)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id <S292368AbSCON3O>; Fri, 15 Mar 2002 08:29:14 -0500
Received: (majordomo@vger.kernel.org) by vger.kernel.org
	id <S292339AbSCON3C>; Fri, 15 Mar 2002 08:29:02 -0500
Received: from www.deepbluesolutions.co.uk ([212.18.232.186]:64268 "EHLO
	caramon.arm.linux.org.uk") by vger.kernel.org with ESMTP
	id <S291279AbSCON2o>; Fri, 15 Mar 2002 08:28:44 -0500
Received: from [3ffe:8260:2002:1:201:2ff:fe14:8fad] (helo=flint.arm.linux.org.uk)
	by caramon.arm.linux.org.uk with esmtp (Exim 3.16 #1)
	id 16lrl8-0008OG-00; Fri, 15 Mar 2002 13:28:38 +0000
Received: from rmk by flint.arm.linux.org.uk with local (Exim 3.16 #1)
	id 16lrl7-0006vK-00; Fri, 15 Mar 2002 13:28:37 +0000
Message-ID: <20020315132837.D24984@flint.arm.linux.org.uk>
User-Agent: Mutt/1.2.5i
Precedence: bulk
X-Mailing-List: linux-kernel@vger.kernel.org
From: Russell King <rmk@arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@transmeta.com>,
   Marcelo Tosatti <marcelo@conectiva.com.br>, davej@suse.de
Subject: [PATCH] 2.4 and 2.5: fix /proc/kcore
Date: Fri, 15 Mar 2002 13:28:37 +0000

As mentioned on May 11 on LKML, here is a patch to fix /proc/kcore for
architectures which do not have RAM located at physical address 0.

I did say I'd send this on Monday, however I only got feedback from the
ia64 people, and /proc/kcore is already broken on their machines anyway.
(They need to fix it up; they place modules below PAGE_OFFSET, which
breaks our generated ELF core header).

So I've decided to send it a few days early.

Please apply.

--- orig/fs/proc/kcore.c	Fri Mar 15 10:14:44 2002
+++ linux/fs/proc/kcore.c	Fri Mar 15 11:18:21 2002
@@ -381,8 +381,13 @@
 			return tsz;
 	}
 #endif
-	/* fill the remainder of the buffer from kernel VM space */
-	start = (unsigned long)__va(*fpos - elf_buflen);
+	
+	/*
+	 * Fill the remainder of the buffer from kernel VM space.
+	 * We said in the ELF header that the data which starts
+	 * at 'elf_buflen' is virtual address PAGE_OFFSET. --rmk
+	 */
+	start = PAGE_OFFSET + (*fpos - elf_buflen);
 	if ((tsz = (PAGE_SIZE - (start & ~PAGE_MASK))) > buflen)
 		tsz = buflen;
 		


-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--zwykVQheeQ--

