From: umut aymakoglu <umutaymak@yahoo.com>
Date: Fri, 16 Jan 2004 18:31:11 +0000
Subject: shared memory segment size alignment
Message-Id: <20040116183111.96883.qmail@web60002.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi -
In some kernel versions the SHMLBA is defined as
1MB(1024*1024) and in some as 16K. What would be the
difference between aligning the shared memory segment
size on 1MB versus 16K before calling shmget()? Would
there be any performance gain/lose? We are aligning
the segment address on 1MB.

thanks,
Umut

__________________________________
Do you Yahoo!?
Yahoo! Hotjobs: Enter the "Signing Bonus" Sweepstakes
http://hotjobs.sweepstakes.yahoo.com/signingbonus
