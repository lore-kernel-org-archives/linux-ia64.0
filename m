From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 20 Jun 2003 20:51:00 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105614226628682@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 20, 2003 at 01:39:44PM -0700, Jesse Barnes wrote:
> #	arch/ia64/sn/io/drivers/Makefile	1.3     -> 1.4    

Related topic.
Why do you put drivers hare.
Kernel policy is to put even architecture specific drivers in drivers/,
not somewhere below arch/.

	Sam
