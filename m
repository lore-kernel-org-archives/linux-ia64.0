From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 16 Mar 2001 23:03:33 +0000
Subject: Re: [Linux-ia64] Status of 64K pagesize support
Message-Id: <marc-linux-ia64-105590693005294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 Mar 2001 15:07:53 -0600 (CST), Jack Steiner <steiner@sgi.com> said:

  Jack> What is the status of support for 64K pagesizes in IA64. Is
  Jack> anyone actively working this??

  Jack> I built a 2.4.2 kernel with 64K pages & immediately hit 2
  Jack> problems:

  Jack> 	- gcc doesnt support 64K alignment (perhaps I am using
  Jack> an old gcc??)

  Jack> 	- drivers/scsi/scsi_dma.c has a bitmap that overflows
  Jack> with 64K pages.


  Jack> I dont mind working on these issues but first wanted to check
  Jack> if anyone else is working on them.

  Jack> What other issues are people aware of that are lurking.....

There shouldn't be any.  The VM system should handle it just fine.

	--david

