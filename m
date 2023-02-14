From: Josh Poimboeuf <jpoimboe@kernel.org>
Date: Tue, 14 Feb 2023 07:05:56 +0000
Subject: [PATCH v2 22/24] objtool: Include weak functions in 'global_noreturns' check
Message-Id: <85c4281eecd9388e7b3b21ef550119caa5305327.1676358308.git.jpoimboe@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1676358308.git.jpoimboe@kernel.org>
In-Reply-To: <cover.1676358308.git.jpoimboe@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: jgross@suse.com, richard.henderson@linaro.org, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, loongarch@lists.linux.dev, f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com, tsbogend@alpha.franken.de, linux-mips@vger.kernel.org, jiaxun.yang@flygoat.com, mpe@ellerman.id.au, npiggin@gmail.com, christophe.leroy@csgroup.eu, linuxppc-dev@lists.ozlabs.org, ysato@users.sourceforge.jp, dalias@libc.org, linux-sh@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, chris@zankel.net, jcmvbkbc@gmail.com, linux-xtensa@linux-xtensa.org, peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com, mgorman@suse.de, bristot@redhat.com, vschneid@redhat.com, paulmck@kernel.org

If a global __noreturn function prototype has a corresponding weak
function, it should also be __noreturn.

Signed-off-by: Josh Poimboeuf <jpoimboe@kernel.org>
---
 tools/objtool/check.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index ba07a8ebaf73..0a1cf867d9b2 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -193,14 +193,14 @@ static bool __dead_end_function(struct objtool_file *file, struct symbol *func,
 	if (!func)
 		return false;
 
-	if (func->bind = STB_WEAK)
-		return false;
-
-	if (func->bind = STB_GLOBAL)
+	if (func->bind = STB_GLOBAL || func->bind = STB_WEAK)
 		for (i = 0; i < ARRAY_SIZE(global_noreturns); i++)
 			if (!strcmp(func->name, global_noreturns[i]))
 				return true;
 
+	if (func->bind = STB_WEAK)
+		return false;
+
 	if (!func->len)
 		return false;
 
-- 
2.39.1
