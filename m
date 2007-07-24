From: Jes Sorensen <jes@sgi.com>
Date: Tue, 24 Jul 2007 08:30:51 +0000
Subject: Re: Linus' tree broken?
Message-Id: <46A5B8BB.3000703@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> Neither Linus' tree (2.6.23-rc1) nor Tony's test tree (2.6.22) boot on the 
> three SN2 systems I tried booting on (SLES 10 roots).  Tony's test tree
> from ~3 weeks ago does boot.
> 
> The last boot message is "Starting udevd".  
> 
> The cpu LEDs are toggling between 0 & 1 "Kernel: CPU idle".
> It doesn't panic.
> 

Yeah I see the same, I can hit return on the console and it reacts but
doesn't get any further.

git commit 7dcca30a32aadb0520417521b0c44f42d09fe05c works for me - thats
the 2.6.22 Sun Jul 8 marker from Linus. And I know git
f695baf2df9e0413d3521661070103711545207a is hosed - Sun Jul 22.

Sorry just sitting waiting for a plane, don't have much time to look at
it right now.

Wonder if Tony's .config is much different from everyone else's? Mine is
an SN2 specific kernel, haven't tried GENERIC yet.

Cheers,
Jes
