From: Grant Grundler <iod00d@hp.com>
Date: Fri, 27 Aug 2004 22:26:52 +0000
Subject: Re: high resolution timer on ia64
Message-Id: <20040827222652.GA960@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <082720042204.7248.412FAFEE0005A00000001C502200735834040104040E05@comcast.net>
In-Reply-To: <082720042204.7248.412FAFEE0005A00000001C502200735834040104040E05@comcast.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 27, 2004 at 10:04:30PM +0000, kallol@comcast.net wrote:
> Hello,
>            Is there an official patch for high resolution timer support
> on IA64?

Does CONFIG_HPET cover what you need?
That's already included in the 2.6.8.1 kernels.

| HPET - High Precision Event Timer (HPET) [N/y/?] (NEW) ?
| 
| If you say Y here, you will have a miscdevice named "/dev/hpet/".  Each
| open selects one of the timers supported by the HPET.  The timers are
| non-periodioc and/or periodic.

hth,
grant
