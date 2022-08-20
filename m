From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 20 Aug 2022 22:14:38 +0000
Subject: Re: [PATCH] ia64: fix clock_getre(CLOCK_MONOTONIC) to report ITC frequency
Message-Id: <20220820151438.d55718d341df99d5747caebb@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220815054944.4130786-1-slyich@gmail.com>
        <20220817122103.ecbd08bd545385e5bf8e0d72@linux-foundation.org>
        <6d07209d000b671a3bc48003905652e8@matoro.tk>
In-Reply-To: <6d07209d000b671a3bc48003905652e8@matoro.tk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: matoro <matoro_mailinglist_kernel@matoro.tk>
Cc: Sergei Trofimovich <slyich@gmail.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 17 Aug 2022 17:57:42 -0400 matoro <matoro_mailinglist_kernel@matoro.tk> wrote:

> Hi Andrew, I came up with the prototype for this patch, but it was based 
> entirely on Sergei's investigation which was documented in 
> https://bugs.gentoo.org/596382.  I asked him to send it upstream because 
> I'm unable to attach my realname to it due to my job.

In that case it's unclear that your Signed-off-by: is appropriate?

: Developer's Certificate of Origin 1.1
: ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
: 
: By making a contribution to this project, I certify that:
: 
:         (a) The contribution was created in whole or in part by me and I
:             have the right to submit it under the open source license
:             indicated in the file; or
: 
:         (b) The contribution is based upon previous work that, to the best
:             of my knowledge, is covered under an appropriate open source
:             license and I have the right under that license to submit that
:             work with modifications, whether created in whole or in part
:             by me, under the same open source license (unless I am
:             permitted to submit under a different license), as indicated
:             in the file; or
: 
:         (c) The contribution was provided directly to me by some other
:             person who certified (a), (b) or (c) and I have not modified
:             it.
: 
:         (d) I understand and agree that this project and the contribution
:             are public and that a record of the contribution (including all
:             personal information I submit with it, including my sign-off) is
:             maintained indefinitely and may be redistributed consistent with
:             this project or the open source license(s) involved.


>  I can place a 
> signed-off-by with my handle but I understand that's normally against 
> kernel policy which is why I didn't.  Either way the bulk of the work 
> belongs to Sergei, I just scribbled it down, and he cleaned it up for 
> this submission.

I think I'll switch it to a Cc: :)
