From: Keith Owens <kaos@sgi.com>
Date: Thu, 06 Oct 2005 00:30:58 +0000
Subject: Re: [PATCH] - Avoid kernel hang during CMC interrupt storm
Message-Id: <21184.1128558658@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128531726.27874.36.camel@xw.sutula>
In-Reply-To: <1128531726.27874.36.camel@xw.sutula>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 05 Oct 2005 11:02:06 -0600, 
Bryan Sutula <Bryan.Sutula@hp.com> wrote:
>The following patch immediately disables CMC interrupts for the current
>CPU.  This then allows (at least) one CPU to ignore CMC interrupts,
>execute the schedule_work() code, and disable CMC interrupts on the rest
>of the CPUs.

Ack-by: Keith Owens <kaos@sgi.com>

