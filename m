From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 03 Jun 2004 17:39:58 +0000
Subject: Re: Who owns those locks ?
Message-Id: <200406031139.58964.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org>
In-Reply-To: <40A1F4BE.4A298352@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wednesday 12 May 2004 3:56 am, Zoltan Menyhart wrote:
> Got a dead lock ?
> No idea how you got there ?
> 
> Why don't you put the ID of the owner of the lock in the lock word ?
> Here is your patch for IA-64.
> Doesn't cost any additional instruction, you can have it in your
> "production" kernel, too.

Whatever happened with this patch?  I really like the idea, but
it seems like it died on the vine.  Maybe it's time to clean it
up, pull all the bits together, and repost it.
