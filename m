From: <ameya.mitragotri@wipro.com>
Date: Fri, 30 Jan 2004 12:49:29 +0000
Subject: Problem with interrupts + lkcd on IA64!
Message-Id: <CC7A2BA2F1CA9E43B2B62C4783B42C7B9A88EE@blr-ec-msg05.wipro.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I am working on an IA64 Itanium machine with an MPT SCSI
adapter. 

1) I have patched my kernel (2.6.1) with lkcd and I am trying
to dump using the keyboard combination of Alt+SysRq+d.
This always ends up in a hung kernel.

2) The kernel does not hang if the dump starts from a non
interrupt/bottom half context.

3) Dumping, however, is successful on an X86 machine
(no scsi here) in both the above scenarios.

It is an observation that with Alt+SysRq+d, dumping progresses from
the bottom half of the keyboard interrupt. The same would 
imply that, all interrupts would be enabled and dumping should 
progress.

4) I noticed that the values of psr.i and psr.ic are 1 when
we are waiting for the interrupt (psr.i and psr.ic are the same
for points 1 and 2 mentioned above)

Any suggestions as to what may be going wrong here?

Thanks
Ameya

