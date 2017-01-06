From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Fri, 06 Jan 2017 20:50:34 +0000
Subject: Re: [PATCH v2 4/7] x86: put msr-index.h in uapi
Message-Id: <CAHp75VdDfopdSy-7oy87ZeosDB9+FN4zFBhErPWLQB7tH81zTw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com> <1483695839-18660-5-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1483695839-18660-5-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Arnd Bergmann <arnd@arndb.de>, mmarek@suse.com, linux-kbuild@vger.kernel.org, Linux Documentation List <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, Cris <linux-cris-kernel@axis.com>, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, LINUX

On Fri, Jan 6, 2017 at 11:43 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> This header file is exported, thus move it to uapi.

Just hint for the future:
-M (move)
-C (copy)
-D (delete) [though this is NOT for applying]

-- 
With Best Regards,
Andy Shevchenko
