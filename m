From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 17 Feb 2005 01:24:04 +0000
Subject: Re: Allow to change SD_NODES_PER_DOMAIN at configuration or boot time
Message-Id: <200502161724.05184.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, February 16, 2005 5:07 pm, Luck, Tony wrote:
> Summary: I like the command-line settable value.  But the CONFIG
> option still looks like it does the wrong thing as often as it helps.
> The command line option needs to add some text to kernel-parameters.txt
> to explain what this does, and how to pick the right value.

I completely agree and like the idea of a tunable too.  I'm not sure what the 
default should be though--I don't think 6 makes much sense, but 4, as you 
said, is capable of causing harm...  I guess we should just pick something.

Jesse
