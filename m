From: markw@osdl.org
Date: Fri, 26 Mar 2004 22:00:01 +0000
Subject: PostgreSQL block size vs. LVM2 stripe width
Message-Id: <200403262200.i2QM04223972@mail.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: pgsql-hackers@postgresql.org
Cc: linux-ia64@vger.kernel.org, linux-lvm@redhat.com

I have some results from DBT-2 testing PostgreSQL with difference block
sizes against different lvm stripe widths on Linux.  I've found that
iostat appears to report more erratic numbers as the block size of the
database increases but I'm not able to see any reason for it.

I have pg_xlog on a separate set of drives from the rest of the database
and was wondering if having different block sizes for the log and the
data has been discusses?

Or does anyone have any tips for an optimal combination of settings?

Here's a summary from an Itanium2 system, where bigger is better:

                        Linux-2.6.3, LVM2 Stripe Width
                        (going across)
PostgreSQL
BLCKSZ
(going down)    16 KB   32 KB   64 KB   128 KB  256 KB  512 KB
2 KB            2617    2656    2652    2664    2667    2642
4 KB            4393    4486    4577    4557    4511    4448
8 KB            4337    4423    4471    4576    4111    3642
16 KB           4412    4495    4532    4536    2985    2312
32 KB           3705    3784    3886    3925    2936    2362

Links to more data:
	http://developer.osdl.org/markw/lvm2/blocks.html

Mark
