From: Aaron Burt <aaron@osdl.org>
Date: Fri, 01 Feb 2002 17:37:23 +0000
Subject: Re: [Linux-ia64] 2.4.17 on Azusa box
Message-Id: <marc-linux-ia64-105590698805979@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805969@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805969@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 1 Feb 2002, Erich Focht wrote:
> Just a minor remark:
>
> On Wed, 30 Jan 2002, Aaron Burt wrote:
>
> > - The kernel page size needs to be 16KB.
>
> What you certainly mean is: set the "Physical memory granularity" to 16MB
> in the "Kernel hacking" menu.

You are correct.  That's what my notes said, but I second-guessed myself
after checking under make menuconfig.  Feh.


