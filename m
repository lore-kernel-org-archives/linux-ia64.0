From: Nathan Scott <nathans@sgi.com>
Date: Wed, 15 Oct 2003 06:34:09 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619986021272@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 11:21:09PM -0700, David Mosberger wrote:
> >>>>> On Wed, 15 Oct 2003 16:06:02 +1000, Nathan Scott <nathans@sgi.com> said:
> 
>   Nathan> It turns out that neither is a problem for us in practice.
> 
> Sounds find to me, then.  Except, I'd replace #ifdef __ia64__ with
> #ifdef CONFIG_IA64, so you're relying (less) on compiler magic.
> 

Oh.  I had avoided that because it requires any sources including
these headers to have already included linux/config.h, which they
may not be doing.  linux/types.h is included by userspace code too,
I believe, so may be an issue there too.

cheers.

-- 
Nathan
