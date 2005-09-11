From: Keith Owens <kaos@sgi.com>
Date: Sun, 11 Sep 2005 03:47:13 +0000
Subject: Re: [PATCH 2.6.13 8/7 respin 1] MCA/INIT: tweaks
Message-Id: <22319.1126410433@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <22055.1126409801@ocs3.ocs.com.au>
In-Reply-To: <22055.1126409801@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 11 Sep 2005 13:36:41 +1000, 
Keith Owens <kaos@sgi.com> wrote:
>Respin 1 of the tweaks to the previous MCA/INIT patch sets.
>
>* Remove the requirement that kernel stacks be aligned on KERNEL_STACK_SIZE.
>* Remove the serialization of MCA/INIT handlers returning to SAL.  The
>  problem looked like a race but was really caused by a broken prom
>  doing cacheable accesses to the minstate area.
>* Print the cpu number and monarch status in the INIT handler.
>* Workaround for broken proms that access the minstate area using
>  cacheable addresses.
>* Remove the export of the scheduler hooks until we have modular code
>  that needs them.
>* Remove the final reference to MINSTATE_VIRT.
>* Workaround for broken proms that drive all INIT events as slaves.
>* Workaround for broken proms that drive all INIT events as monarchs.

Tony, that is all the changes that I have planned for the (fast
approaching) 2.6.14-rc1.  The scheduler hooks have already been posted
to linux-kernel for discussion[1], the patch got just one query which
has been answered.

Do you want me to reissue a new complete patch set or are you happy
with appending the tweaks to the existing patch set?  Whatever is
easier for your git tree.

[1] http://lkml.org/lkml/2005/9/8/315/

