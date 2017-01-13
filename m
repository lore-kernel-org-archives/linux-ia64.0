From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 13 Jan 2017 10:55:50 +0000
Subject: Re: [PATCH v3 3/8] nios2: put setup.h in uapi
Message-Id: <20170113105550.GD1201@distanz.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <1484304406-10820-4-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <1484304406-10820-4-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: arnd@arndb.de, mmarek@suse.com, linux-kbuild@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.orglinux-ar

On 2017-01-13 at 11:46:41 +0100, Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> This header file is exported, but from a userland pov, it's just a wrapper
> to asm-generic/setup.h.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
