From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Aug 2004 13:07:14 +0000
Subject: Re: writing to "/proc/irq/xxxx/smp_affinity" produces a kernel crash
Message-Id: <16674.770.492550.634976@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4121FF26.70102@Ext.Bull.Net>
In-Reply-To: <4121FF26.70102@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Aug 2004 14:50:46 +0200, Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net> said:

  Francois> Apparently a little bug was introduced in 2.6.7 kernel dealing with IRQ
  Francois> redirection managemant via proc filesystem.
  Francois> The behavior is quite simple, just type :

  Francois> echo "r 00000001" > /proc/irq/{xy}/smp_affinity

  Francois> where {xy} is a valid irq, and your kernel will crash.

Already fixed.  See:

 http://linux.bkbits.net:8080/linux-2.5/cset@1.1807.3.42

	--david
