From: Grant Grundler <iod00d@hp.com>
Date: Sat, 29 Oct 2005 00:49:02 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051029004902.GH22677@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 28, 2005 at 04:23:27PM -0700, Luck, Tony wrote:
...
> The worst-case loser from this might be a benchmark that runs
> oodles of small processes (partly from the overhead of the extra
> page, and partly because I suspect that fork/exec/exit might see
> the most impact).  So I'd like to see some AIM7 numbers too.

Just curious...is osdl-aim7 the nearest thing we have to SDET?
Anyone know?

thanks,
grant
