From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 14 Sep 2021 14:38:46 +0000
Subject: [PATCH -tip v11 02/27] kprobes: Use helper to parse boolean input from userspace
Message-Id: <163163032637.489837.10678039554832855327.stgit@devnote2>
List-Id: <linux-ia64.vger.kernel.org>
References: <163163030719.489837.2236069935502195491.stgit@devnote2>
In-Reply-To: <163163030719.489837.2236069935502195491.stgit@devnote2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Rostedt <rostedt@goodmis.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: X86 ML <x86@kernel.org>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Xu <dxu@dxuuu.xyz>, linux-kernel@vger.kernel.org, bpf@vger.kernel.org, kuba@kernel.org, mingo@redhat.com, ast@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, kernel-team@fb.com, yhs@fb.com, linux-ia64@vger.kernel.org, Abhishek Sagar <sagar.abhishek@gmail.com>, Andrii Nakryiko <andrii.nakryiko@gmail.com>, Paul McKenney <paulmck@kernel.org>

From: Punit Agrawal <punitagrawal@gmail.com>

The "enabled" file provides a debugfs interface to arm / disarm
kprobes in the kernel. In order to parse the buffer containing the
values written from userspace, the callback manually parses the user
input to convert it to a boolean value.

As taking a string value from userspace and converting it to boolean
is a common operation, a helper kstrtobool_from_user() is already
available in the kernel. Update the callback to use the common helper
to parse the write buffer from userspace.

Signed-off-by: Punit Agrawal <punitagrawal@gmail.com>
Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 kernel/kprobes.c |   28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 1cf8bca1ea86..26fc9904c3b1 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -2770,30 +2770,14 @@ static ssize_t read_enabled_file_bool(struct file *file,
 static ssize_t write_enabled_file_bool(struct file *file,
 	       const char __user *user_buf, size_t count, loff_t *ppos)
 {
-	char buf[32];
-	size_t buf_size;
-	int ret = 0;
-
-	buf_size = min(count, (sizeof(buf)-1));
-	if (copy_from_user(buf, user_buf, buf_size))
-		return -EFAULT;
+	bool enable;
+	int ret;
 
-	buf[buf_size] = '\0';
-	switch (buf[0]) {
-	case 'y':
-	case 'Y':
-	case '1':
-		ret = arm_all_kprobes();
-		break;
-	case 'n':
-	case 'N':
-	case '0':
-		ret = disarm_all_kprobes();
-		break;
-	default:
-		return -EINVAL;
-	}
+	ret = kstrtobool_from_user(user_buf, count, &enable);
+	if (ret)
+		return ret;
 
+	ret = enable ? arm_all_kprobes() : disarm_all_kprobes();
 	if (ret)
 		return ret;
 
