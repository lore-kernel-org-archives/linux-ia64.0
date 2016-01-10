From: Julian Calaby <julian.calaby@gmail.com>
Date: Sun, 10 Jan 2016 22:13:39 +0000
Subject: Re: [PATCH v3 3/3] checkpatch: add virt barriers
Message-Id: <CAGRGNgXQANbKD=VA0Qx4Wp1+MpZUVV7by8RrKxF9o=qu=vUQqA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452454200-8844-1-git-send-email-mst@redhat.com> <1452454200-8844-4-git-send-email-mst@redhat.com>
In-Reply-To: <1452454200-8844-4-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux <sparclinux@vger.kernel.org>, "Mailing List, Arm" <linux-arm-kernel@lists.infradead.org>, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-

Hi Michael,

On Mon, Jan 11, 2016 at 6:31 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Add virt_ barriers to list of barriers to check for
> presence of a comment.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  scripts/checkpatch.pl | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index 15cfca4..4466579 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -5133,7 +5133,8 @@ sub process {
>                 }x;
>                 my $all_barriers = qr{
>                         $barriers|
> -                       smp_(?:$smp_barrier_stems)
> +                       smp_(?:$smp_barrier_stems)|
> +                       virt_(?:$smp_barrier_stems)

Sorry I'm late to the party here, but would it make sense to write this as:

(?:smp|virt)_(?:$smp_barrier_stems)

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
