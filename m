From: Keith Owens <kaos@sgi.com>
Date: Wed, 26 Apr 2006 23:54:01 +0000
Subject: Re: [patch] Add mca recovery failure messages
Message-Id: <13920.1146095641@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200604262006.k3QK6AA5287600@efs.americas.sgi.com>
In-Reply-To: <200604262006.k3QK6AA5287600@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson (on Wed, 26 Apr 2006 15:06:10 -0500 (CDT)) wrote:
>When the mca recovery code encounters a condition that makes
>the MCA non-recoverable, print the reason it could not recover.
>This will make it easier to identify why the recovery code did
>not recover.
>
>+int
>+fatal_mca(const char *fmt, ...)
>+{
>+	va_list args;

Make fatal_mca() static.

