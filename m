From: Olof Johansson <olof@lixom.net>
Date: Sat, 24 Dec 2005 18:13:26 +0000
Subject: Re: [PATCH] - Fix memory ordering problem in wake_futex()
Message-Id: <20051224181325.GH24601@pb15.lixom.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051223163816.GA30906@sgi.com> <20051224134523.GA7187@sgi.com>
In-Reply-To: <20051224134523.GA7187@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi,

On Sat, Dec 24, 2005 at 07:45:23AM -0600, Jack Steiner wrote:
> This patch is identical to the first patch except I used smp_wmb() instead
> of wmb(). Ordering doen't matter on non-SMP kernels.

Ok, I guess I was wrong -- there's no guarantee that protects stuff from
bleeding into a critical region from after it. Comments in line 54-58 of
kernel/wait.c seems to imply this. Nevermind the fact that most other
architectures seem to protect it anyway. :-)

However, please do fix the comment earlier in the function that implies
that the unlock does indeed do enough barriers while you're at it,
since it seems to be incorrect and misleading.


-Olof
