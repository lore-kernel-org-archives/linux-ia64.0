From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 26 Jun 2003 05:02:57 +0000
Subject: Re: IA-32 support patch: fcntl64 calls are broken
Message-Id: <marc-linux-ia64-105660379711836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105649509512709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105649509512709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 25 June 2003 3:06 pm, I wrote:
> On Tuesday 24 June 2003 4:51 pm, Arun Sharma wrote:
> > Currently, sys32_fcntl64() is broken, because it passes F_*64 commands to sys_fcntl(), which it doesn't understand. The F_XXX64 commands need to be converted to F_XXX before calling sys_fcntl().
> 
> As far as I can tell, this is almost equivalent to, but uglier than,
> the mips64 version:

Never mind.  Besides being unnecessarily rude, I had obviouisly
forgotten the fragment from 2.5 that I just quoted.  Your patch
looks very much like the 2.5 code, which I think is the best
approach.  Even though I think the switch is more readable than
the nested ternary expressions, it's better to follow 2.5.
I apologize.

Bjorn

