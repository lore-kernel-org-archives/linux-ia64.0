From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Tue, 04 Nov 2003 10:22:06 +0000
Subject: Page table mapped and identity segments!
Message-Id: <marc-linux-ia64-106794072219848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,
I am refering to David's and Stephanes's book on the IA64 linux kernel.
From my understanding, 

1) I can see that the PAGE_OFFSET which designates the start of
the identity mapped segment starts at 0xe000000000000000 (region 7).

2) This region has the linux kernel text/data/stack segments.

Now after compiling the linux-2.6.0-test5 on an itanium-2 machine,
the System.map generated contains addresses only starting with
0xa0000..which means all these lie in the page table mapped segments
(region 5).

Why is this happening? 

Apologies if this is too trivial to be asked.

Thanks
Ameya

