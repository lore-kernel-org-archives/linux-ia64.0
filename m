From: Richard Hirst <rhirst@linuxcare.com>
Date: Wed, 19 Sep 2001 22:27:46 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805229@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 19, 2001 at 02:49:28PM -0700, David Mosberger wrote:
> Glad to see you're making progress on this, but the patch looks
> suspicious to me.  There shouldn't be anything ia64 specific in this
> code.  It would be good to understand why the keyboard interrupt gets
> lost.

I agree, this patch is most likely just masking the real problem.

Richard


