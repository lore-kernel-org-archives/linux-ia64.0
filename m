From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 06 Feb 2023 22:36:32 +0000
Subject: Re: [PATCH 10/22] mips/cpu: Make sure play_dead() doesn't return
Message-Id: <177ee7b1-9954-be71-a1c0-024bed9902db@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1675461757.git.jpoimboe@kernel.org>
 <b131d3e00967034d86692b894a66c6a656e7de3f.1675461757.git.jpoimboe@kernel.org>
In-Reply-To: <b131d3e00967034d86692b894a66c6a656e7de3f.1675461757.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@kernel.org>, linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

On 2/3/23 14:05, Josh Poimboeuf wrote:
> play_dead() doesn't return.  Make that more explicit with a BUG().
> 
> BUG() is preferable to unreachable() because BUG() is a more explicit
> failure mode and avoids undefined behavior like falling off the edge of
> the function into whatever code happens to be next.
> 
> Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
