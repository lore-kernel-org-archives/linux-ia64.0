From: Bill Nottingham <notting@redhat.com>
Date: Fri, 12 Dec 2003 15:37:16 +0000
Subject: [jakub@redhat.com: Re: [brian.j.vandecoevering@intel.com: RE: [Linux-ia64] problems with ppp/pppd: p
Message-Id: <marc-linux-ia64-107124350029067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Back long ago, I reported a problem with PPP on ia64:

 http://www.gelato.unsw.edu.au/linux-ia64/0105/1641.html

We added the workaround in our tree for earlier releases,
and promptly forgot about it; however, someone reported that
RHEL 3 has the same issue (as we took the workaround out.)

Jakub noticed the following - does this explain the problem?

Bill

----- Forwarded message from Jakub Jelinek <jakub@redhat.com> -----

From: Jakub Jelinek <jakub@redhat.com>
To: notting@redhat.com
Subject: Re: [brian.j.vandecoevering@intel.com: RE: [Linux-ia64] problems with ppp/pppd: put_user/copy_to_user]
Reply-To: Jakub Jelinek <jakub@redhat.com>
User-Agent: Mutt/1.4.1i
X-Reply-To: Jakub Jelinek <jakub@redhat.com>
Date: Fri, 12 Dec 2003 07:32:59 -0500

On Thu, Dec 11, 2003 at 09:16:50PM -0800, David S. Miller wrote:
> On Thu, 11 Dec 2003 22:58:48 -0500
> Bill Nottingham <notting@redhat.com> wrote:
> 
> > According to Intel, this patch is *still* needed to fix ppp on
> > ia64 in RHEL3. We should probably verify this, although I'm
> > still at a loss as to why it works.
> 
> Either a compiler problem or their put_user() implementation
> is busted.

The latter I guess.
At least linux-2.4.22-1.2108.nptl I have unpacked on my box
has in asm-ia64/uaccess.h:

#define put_user(x,ptr) __put_user_check((__typeof__(*(ptr)))(x),(ptr),sizeof(*(ptr)),get_fs())

#define __put_user_check(x,ptr,size,segment)                    \
({                                                              \
        register long __pu_err asm ("r8") = -EFAULT;            \
        __typeof__(*(ptr)) *__pu_addr = (ptr);                  \
        if (__access_ok((long)__pu_addr,size,segment)) {        \
                __pu_err = 0;                                   \
                switch (size) {                                 \
                  case 1: __put_user_8(x,__pu_addr); break;     \
                  case 2: __put_user_16(x,__pu_addr); break;    \
                  case 4: __put_user_32(x,__pu_addr); break;    \
                  case 8: __put_user_64(x,__pu_addr); break;    \
                  default: __put_user_unknown(); break;         \
                }                                               \
        }                                                       \
        __pu_err;                                               \
})

#define __put_user_32(x,addr)                                                           \
        asm volatile (                                                                  \
                "\n"_LL"\tst4 %1=%r2%P1\t// %0 gets overwritten by exception handler\n" \
                "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"                    \
                _LL                                                                     \
                : "=r"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))

But, a function call clobbers r8.
Guess a
__typeof(x) __x = (x);
before __pu_err and
s/x/__x/ is needed.
Probably __pu_addr decl should be moved before __pu_err is initialized too,
otherwise
extern int *foo ();
put_user (0, foo ());
might not work properly.

	Jakub



----- End forwarded message -----
