From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 04 Feb 2005 06:55:49 +0000
Subject: Re: Which 2.4 kernel tree I should use for ia64?
Message-Id: <42031C75.3050702@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050203201846.GA27365@lucon.org>
In-Reply-To: <20050203201846.GA27365@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas schrieb:

>The most recent 2.4 patch for ia64 is here:
>
>    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.26-ia64-040510.diff.bz2
>
>I haven't been producing 2.4 patches recently because I don't
>think anyone would actually use them.
>
>My assumption is that most people using 2.4 kernels on ia64 are
>running distro kernels, and distros are only interested in backports
>of specific bugfixes, not in ia64 patches for new 2.4 kernels.
>
>If my assumption is incorrect, and somebody does care about new
>ia64 patches for 2.4, please speak up!
>
Ok, we are using 2.4 kernels with ia64 patches. I cannot imagine the 
efford to make patches for newer kernels. But we shouldn't loose contact 
to the current tree. Or could you recommend prefering unpatched 2.4.29 
against patched 2.4.26?

Christian

