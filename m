From: Goutham Rao <goutham.rao@intel.com>
Date: Tue, 08 Feb 2000 08:41:15 +0000
Subject: Re: [Linux-ia64] booting? or is this list dead? ;-)
Message-Id: <marc-linux-ia64-105590678204917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204916@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204916@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It will depend on your system configuration... if all you have on IDE is
the ls120 and CD, then I think the CD would be /dev/hdc so you should be
able to use
"eli <vmlinux> root=/dev/hdc"

On Tue, 8 Feb 2000, Tim Riker wrote:

> What is the eli command to mount the CD as / and boot?
> -- 
> Tim Riker - http://rikers.org/ - short SIGs! <g>
> All I need to know I could have learned in Kindergarten
> ... if I'd just been paying attention.
> 
> 
> _______________________________________________
> Linux-ia64 mailing list
> Linux-ia64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 




