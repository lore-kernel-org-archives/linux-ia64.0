From: Christoph Lameter <christoph@lameter.com>
Date: Fri, 27 Aug 2004 23:23:59 +0000
Subject: Re: high resolution timer on ia64
Message-Id: <Pine.LNX.4.58.0408271622230.32498@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <082720042204.7248.412FAFEE0005A00000001C502200735834040104040E05@comcast.net>
In-Reply-To: <082720042204.7248.412FAFEE0005A00000001C502200735834040104040E05@comcast.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patches in Tony Luckes tree contain a high resolution implementation of
the system timer and provides nanosecond resolution. See my earlier
posts/patches on this mailing list. Also look at the existing
CONFIG_TIME_INTERPOLATOR option in the kernel source.

On Fri, 27 Aug 2004 kallol@comcast.net wrote:

> Hello,
>            Is there an official patch for high resolution timer support on IA64?     There is a
> sourceforge project on high resolution timers but it looks like that it is for i386 architecture.
>
> Kallol Biswas
> --
> NucleoDyne Systems Inc.
> kallol@nucleodyne.com
> www.nucleodyne.com
> Phone: 408-718-8164
> Fax:408-732-2284
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
