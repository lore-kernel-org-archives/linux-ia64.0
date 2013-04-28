From: James Hogan <james.hogan@imgtec.com>
Date: Sun, 28 Apr 2013 10:24:35 +0000
Subject: Re: [PATCH -next] ia64, metag: Do not export min_low_pfn in arch-specific code
Message-Id: <CAAG0J982gbca3XHHSpTHgqPgeGyJRtG8Lm1cWsT0HsThqdFeMw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1367086831-10740-1-git-send-email-geert@linux-m68k.org>
In-Reply-To: <1367086831-10740-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Sanjay Lal <sanjayl@kymasys.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org

On 27 April 2013 19:20, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> As of commit 787dcbe6984b3638e94f60d807dcb51bb8a07211 ("MIPS: Export
> symbols used by KVM/MIPS module"), min_low_pfn is already exported by
> the generic mm/bootmem.c, causing:
>
> WARNING: vmlinux: 'min_low_pfn' exported twice. Previous export was in vmlinux
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

This has been pointed out several times and needs fixing in the mips
tree where the warning was introduced.

Acked-by: James Hogan <james.hogan@imgtec.com>

Cheers
James
