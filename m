From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 22 Oct 2014 15:31:36 +0000
Subject: Re: [PATCH v2 08/47] kernel: Move pm_power_off to common code
Message-Id: <20141022153136.GA11045@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413864783-3271-1-git-send-email-linux@roeck-us.net>
 <1413864783-3271-9-git-send-email-linux@roeck-us.net>
In-Reply-To: <1413864783-3271-9-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon, Oct 20, 2014 at 09:12:24PM -0700, Guenter Roeck wrote:

> pm_power_off is defined for all architectures. Move it to common code.
> 
> Have all architectures call do_kernel_power_off instead of pm_power_off.
> Some architectures point pm_power_off to machine_power_off. For those,
> call do_kernel_power_off from machine_power_off instead.
> 
> Acked-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Hirokazu Takata <takata@linux-m32r.org>
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
> Acked-by: Max Filippov <jcmvbkbc@gmail.com>
> Acked-by: Rafael J. Wysocki <rjw@rjwysocki.net>
> Acked-by: Richard Weinberger <richard@nod.at>
> Acked-by: Xuetao Guan <gxt@mprc.pku.edu.cn>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Ralf Baechle <ralf@linux-mips.org>
