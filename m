From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 09 Aug 2007 22:22:24 +0000
Subject: Re: mmap broken?
Message-Id: <ed5aea430708091522k5517cae6ub0369ab4ab9d78a8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430708091102q26cc5a39uf67210652e7354c2@mail.gmail.com>
In-Reply-To: <ed5aea430708091102q26cc5a39uf67210652e7354c2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Never mind: with MAP_SHARED, the ia64 linux kernel will try to align
the mapping to a 1MB boundary to avoid potentially bad performance due
to false sharing, so the kernel is doing the Right Thing and it's the
app that should have used MAP_PRIVATE instead.

  --david

On 8/9/07, David Mosberger-Tang <dmosberger@gmail.com> wrote:
> There is a libunwind test-case that used to work fine but fails with
> recent kernels (e.g., 2.6.23-rc2).  The problem is exhibited by the
> attached test program.  It attempts to map the page right after the
> register-backing-store area with a no-access page.  The mmap call
> succeeds, but the kernel incorrectly maps the no-access page not at
> the desired location, but at the next page.  If I specify MAP_FIXED,
> the mmap() call succeeds, but I don't think MAP_FIXED should be
> necessary here.  Anybody can think of any patches that would explain
> this change of behavior?
>
>   --david
> --
> Mosberger Consulting LLC, http://www.mosberger-consulting.com/
>
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
