From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 16 Oct 2001 06:16:05 +0000
Subject: [Linux-ia64] lost printk's
Message-Id: <marc-linux-ia64-105590698805347@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi everybody!

I want to write a low level driver for linux on ia64. During testing the
machine often crashes very heavily. After reboot most of the printk's
that have been done before the crash are lost. Maybe they are hold in
the disk cache when the crash occurs. Does anybody know how to get the
printk's written on disk?

Christian


