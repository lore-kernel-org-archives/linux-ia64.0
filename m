From: Doug Chapman <doug.chapman@hp.com>
Date: Mon, 13 Apr 2009 19:47:49 +0000
Subject: Re: squashfs broken on ia64
Message-Id: <1239652069.1127.7.camel@oberon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1239390803.21349.13.camel@oberon>
In-Reply-To: <1239390803.21349.13.camel@oberon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 2009-04-10 at 15:13 -0400, Doug Chapman wrote:
> It appears that squashfs 4.0 doesn't work on ia64.  I am not sure what
> could be arch specific here but the same kernel versions work OK on
> x86_64.
> 

Found the problem.  This is actually broken on any arch with a pagesize
> 8192.  Will send the patch to the main linux list since this is wider
than just ia64.

- Doug


