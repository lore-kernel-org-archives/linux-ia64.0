From: Keith Owens <kaos@sgi.com>
Date: Wed, 15 Sep 2004 07:16:47 +0000
Subject: Re: INIT dumps broken?
Message-Id: <16344.1095232607@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 14 Sep 2004 07:50:55 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>I noticed that with kernel v2.6.9-rc1 INIT dumps appear not to work
>anymore.  The machine just hangs, without ever (visibly) control
>reaching the OS INIT handler.  v2.6.7-rc3 was OK.  Anybody know what
>broke?

cpu 0 is using init_task's original address.

2.6.7-rc3, kdb ps A

Task Addr               Pid   Parent [*] cpu State Thread             Command
0xe0000430148dc000        0        0  1    0   I  0xe0000430148dc4b0 *swapper
0xe00004b43be70000        0        1  1    1   I  0xe00004b43be704b0  swapper
0xe00004b43bd68000        0        1  1    2   I  0xe00004b43bd684b0  swapper
0xe0000430067b0000        0        1  1    3   I  0xe0000430067b04b0  swapper

2.6.8.1, kdb ps A

Task Addr               Pid   Parent [*] cpu State Thread             Command
0xa0000001008e8000        0        0  1    0   I  0xa0000001008e84d0 *swapper   <=0xe00004b43bd38000        0        1  1    1   I  0xe00004b43bd384d0  swapper
0xe00004b43bd00000        0        1  1    2   I  0xe00004b43bd004d0  swapper
0xe00004b0037e0000        0        1  1    3   I  0xe00004b0037e04d0  swapper

The use of 0xa.. for cpu 0 is causing an MCA when cpu 0 receives INIT.

