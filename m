From: Martin Pool <mbp@samba.org>
Date: Wed, 14 May 2003 23:59:29 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705812@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 14 May 2003, David Mosberger <davidm@napali.hpl.hp.com> wrote:
> 
>   >> I see the same thing, but it's only for asm-ia64/offsets.h.  After
>   >> that, parallel makes work just fine.  I tend to be able to live with
>   >> such "minor" build issues for a loooong time, giving others ample
>   >> chance to get impatient first... ;-)
> 
>   Eric> Don't wait, do it now:
>   Eric> make prepare
>   Eric> make -j4 compressed

(Advertorial): Now you've got make -j4, you should try ccache and
distcc.  They make development on big trees enormously more
enjoyable.  Andrew Morton and other kernel developers love them.

  http://distcc.samba.org/
  http://ccache.samba.org/

-- 
Martin 

