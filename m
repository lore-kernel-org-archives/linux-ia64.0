From: Qian Cai <cai@lca.pw>
Date: Thu, 04 Jun 2020 09:50:23 +0000
Subject: Re: [PATCH v4 08/14] powerpc: add support for folded p4d page tables
Message-Id: <F85B8F19-D717-411A-AFA8-466A02159F27@lca.pw>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200603120522.7646d56a23088416a7d3fc1a@linux-foundation.org>
In-Reply-To: <20200603120522.7646d56a23088416a7d3fc1a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Russell King <linux@armlinux.org.uk>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org, Mike Rapoport <rppt@kernel.org>



> On Jun 3, 2020, at 3:05 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> A bunch of new material just landed in linux-next/powerpc.
> 
> The timing is awkward!  I trust this will be going into mainline during
> this merge window?  If not, please drop it and repull after -rc1.

I have noticed the same pattern over and over again, i.e., many powerpc new material has only shown up in linux-next for only a few days before sending for a pull request to Linus.

There are absolutely no safe net for this kind of practice. The main problem is that Linus seems totally fine with it.
